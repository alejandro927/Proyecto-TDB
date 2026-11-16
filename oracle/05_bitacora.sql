-- =====================================================================
-- RutaSur · Oracle · Bitácora de replicación
-- Ejecutar como RUTASUR en FREEPDB1.
-- Misma estructura que la bitácora de MySQL (mysql/05_bitacora.sql).
-- Aquí se guarda cada cambio de las 10 tablas de RutaSur, para que el job
-- de envío lo lea y lo aplique en MySQL por el database link.
-- FALTA: los triggers que llenan la bitácora (van en otro archivo)
-- FALTA: el job que borra los eventos viejos (más de 7 días)
-- =====================================================================
-- SQL*Plus corta una sentencia en la primera línea en blanco, esto lo evita
SET SQLBLANKLINES ON

-- ---------------------------------------------------------------------
-- 1. BITÁCORA
-- un registro por cada INSERT, UPDATE o DELETE en las tablas de negocio
-- ---------------------------------------------------------------------
CREATE TABLE bitacora_replicacion (
  -- identificador del evento (UUID con guiones, igual formato que UUID() de MySQL).
  -- SYS_GUID() da 32 hex, se le ponen los guiones 8-4-4-4-12
  id_evento               VARCHAR2(36)
                          DEFAULT LOWER(REGEXP_REPLACE(RAWTOHEX(SYS_GUID()),
                                  '^(.{8})(.{4})(.{4})(.{4})(.{12})$', '\1-\2-\3-\4-\5'))
                          NOT NULL,
  -- número en orden para saber cuál cambio fue primero (no se replica, no usa pares/impares)
  orden_evento            NUMBER(18) GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
  -- para agrupar los cambios de una misma transacción (ej. finalizar
  -- contrato cambia contrato, vehículo y ubicación) y su orden adentro
  id_transaccion          VARCHAR2(36)   NOT NULL,
  secuencia               NUMBER(6)      DEFAULT 1 NOT NULL,
  -- qué cambió
  tabla_afectada          VARCHAR2(30)   NOT NULL,
  -- en detalle_factura va 'id_factura-id_servicio', ej. '3-5'
  id_registro             VARCHAR2(30)   NOT NULL,
  tipo_operacion          VARCHAR2(6)    NOT NULL,
  -- solo en UPDATE, lista JSON, ej. ["estado_operacion"]
  columnas_modificadas    VARCHAR2(1000),
  -- cómo estaba antes y cómo quedó después
  datos_anteriores_json   VARCHAR2(4000),
  datos_nuevos_json       VARCHAR2(4000),
  -- cuándo, de dónde y quién
  fecha_hora_utc          TIMESTAMP(6)   DEFAULT SYS_EXTRACT_UTC(SYSTIMESTAMP) NOT NULL,
  nodo_origen             VARCHAR2(6)    DEFAULT 'ORACLE' NOT NULL,
  usuario_bd              VARCHAR2(100)  DEFAULT SYS_CONTEXT('USERENV','SESSION_USER'),
  ip_origen               VARCHAR2(60)   DEFAULT SYS_CONTEXT('USERENV','IP_ADDRESS'),
  -- versión del registro antes y después del cambio (para los conflictos)
  version_anterior        NUMBER(10),
  version_nueva           NUMBER(10),
  -- huella SHA-256 de cómo quedó el registro, para comparar que lo que
  -- se aplicó en MySQL es lo mismo que se mandó
  hash_registro           CHAR(64),
  -- control de la replicación
  estado_replicacion      VARCHAR2(10)   DEFAULT 'PENDIENTE' NOT NULL,
  intentos_replicacion    NUMBER(3)      DEFAULT 0 NOT NULL,
  proximo_intento         TIMESTAMP(6),
  -- job que tomó el evento
  procesado_por           VARCHAR2(100),
  fecha_aplicacion        TIMESTAMP(6),
  mensaje_error           VARCHAR2(1000),
  CONSTRAINT pk_bitacora_replicacion  PRIMARY KEY (id_evento),
  CONSTRAINT uq_bitacora_orden        UNIQUE (orden_evento),
  CONSTRAINT uq_bitacora_transaccion  UNIQUE (id_transaccion, secuencia),
  CONSTRAINT ck_bitacora_tabla        CHECK (tabla_afectada IN
      ('cliente_renta','sucursal','modelo_vehiculo','vehiculo','ubicacion_vehiculo',
       'contrato_renta','factura','servicio_renta','detalle_factura','traslado_vehiculo')),
  CONSTRAINT ck_bitacora_operacion    CHECK (tipo_operacion IN ('INSERT','UPDATE','DELETE')),
  CONSTRAINT ck_bitacora_nodo         CHECK (nodo_origen IN ('ORACLE','MYSQL')),
  CONSTRAINT ck_bitacora_estado       CHECK (estado_replicacion IN
      ('PENDIENTE','EN_PROCESO','APLICADO','CONFLICTO','ERROR','DLQ','DESCARTADO')),
  CONSTRAINT ck_bitacora_secuencia    CHECK (secuencia >= 1),
  CONSTRAINT ck_bitacora_intentos     CHECK (intentos_replicacion >= 0),
  CONSTRAINT ck_bitacora_columnas     CHECK (columnas_modificadas IS JSON),
  CONSTRAINT ck_bitacora_antes        CHECK (datos_anteriores_json IS JSON),
  CONSTRAINT ck_bitacora_despues      CHECK (datos_nuevos_json IS JSON)
);

COMMENT ON TABLE bitacora_replicacion IS 'Bitácora de cambios de Oracle que el job de envío aplica en MySQL.';

-- índices para que los jobs encuentren rápido lo pendiente
CREATE INDEX ix_bitacora_estado   ON bitacora_replicacion (estado_replicacion, proximo_intento, orden_evento);
-- para revisar los cambios de un mismo registro en orden
CREATE INDEX ix_bitacora_registro ON bitacora_replicacion (tabla_afectada, id_registro, orden_evento);
-- para ver qué eventos tomó cada job
CREATE INDEX ix_bitacora_job      ON bitacora_replicacion (procesado_por, estado_replicacion);


-- ---------------------------------------------------------------------
-- 2. EVENTOS APLICADOS
-- aquí se anota cada evento que vino de MySQL y ya se aplicó en Oracle,
-- para no aplicarlo dos veces si el job se cae a la mitad y lo vuelve a traer
-- ---------------------------------------------------------------------
CREATE TABLE eventos_aplicados (
  -- el mismo id_evento de la bitácora de MySQL
  id_evento               VARCHAR2(36)   NOT NULL,
  id_transaccion          VARCHAR2(36),
  tabla_afectada          VARCHAR2(30)   NOT NULL,
  id_registro             VARCHAR2(30)   NOT NULL,
  nodo_origen             VARCHAR2(6)    DEFAULT 'MYSQL' NOT NULL,
  hash_registro           CHAR(64),
  fecha_aplicacion        TIMESTAMP(6)   DEFAULT SYS_EXTRACT_UTC(SYSTIMESTAMP) NOT NULL,
  -- job que lo aplicó
  aplicado_por            VARCHAR2(100),
  CONSTRAINT pk_eventos_aplicados PRIMARY KEY (id_evento),
  CONSTRAINT ck_eventos_nodo      CHECK (nodo_origen IN ('ORACLE','MYSQL'))
);

COMMENT ON TABLE eventos_aplicados IS 'Eventos de MySQL ya aplicados en Oracle (para no duplicar).';


-- ---------------------------------------------------------------------
-- 3. PERMISOS
-- REPLICADOR (dueño de los jobs) lee la bitácora y la marca
-- (EN_PROCESO, APLICADO, ERROR...). No lleva DELETE: la limpieza la hace un job de RUTASUR.
-- ---------------------------------------------------------------------
GRANT SELECT, UPDATE ON bitacora_replicacion TO replicador;
-- y anota los eventos de MySQL que ya aplicó
GRANT SELECT, INSERT ON eventos_aplicados    TO replicador;
-- los usuarios de la aplicación no necesitan permisos aquí:
-- los triggers son los que escriben en la bitácora


-- ---------------------------------------------------------------------
-- 4. REVISIÓN: tienen que salir las 2 tablas
-- ---------------------------------------------------------------------
SELECT table_name FROM user_tables
 WHERE table_name IN ('BITACORA_REPLICACION', 'EVENTOS_APLICADOS');
