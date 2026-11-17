-- bitacora de MySQL
-- aqui se guarda cada cambio que se hace en las 10 tablas para que
-- despues los jobs de Oracle lo lean por el link y lo pasen a Oracle
-- FALTA: los triggers que llenan la bitacora (van en otro archivo)
-- FALTA: el EVENT que borra los eventos viejos (mas de 7 dias)
SET NAMES utf8mb4;
USE flotamax;

DROP TABLE IF EXISTS eventos_aplicados;
DROP TABLE IF EXISTS bitacora_replicacion;


-- 1. BITACORA
-- un registro por cada INSERT, UPDATE o DELETE en las tablas de negocio
CREATE TABLE bitacora_replicacion (
    -- identificador del evento (UUID), no se repite en ninguna base
    id_evento               CHAR(36)       NOT NULL DEFAULT (UUID()),
    -- numero en orden para saber cual cambio fue primero
    orden_evento            BIGINT         NOT NULL AUTO_INCREMENT,

    -- para agrupar los cambios de una misma transaccion (ej. finalizar
    -- contrato cambia contrato, unidad y posicion) y su orden adentro
    id_transaccion          CHAR(36)       NOT NULL,
    secuencia               INT            NOT NULL DEFAULT 1,

    -- que cambio
    tabla_afectada          VARCHAR(30)    NOT NULL,
    id_registro             VARCHAR(30)    NOT NULL,
    tipo_operacion          ENUM('INSERT','UPDATE','DELETE') NOT NULL,
    columnas_modificadas    VARCHAR(1000)  NULL,

    -- como estaba antes y como quedo despues
    datos_anteriores_json   VARCHAR(4000)  NULL,
    datos_nuevos_json       VARCHAR(4000)  NULL,

    -- cuando, de donde y quien
    fecha_hora_utc          DATETIME(6)    NOT NULL DEFAULT (UTC_TIMESTAMP(6)),
    nodo_origen             ENUM('ORACLE','MYSQL') NOT NULL DEFAULT 'MYSQL',
    usuario_bd              VARCHAR(100)   NULL,
    ip_origen               VARCHAR(60)    NULL,

    -- version del registro antes y despues del cambio (para los conflictos)
    version_anterior        INT            NULL,
    version_nueva           INT            NULL,

    -- huella SHA-256 de como quedo el registro, para comparar que lo que
    -- se aplico en Oracle es lo mismo que se mando
    hash_registro           CHAR(64)       NULL,

    -- control de la replicacion
    estado_replicacion      ENUM('PENDIENTE','EN_PROCESO','APLICADO','CONFLICTO','ERROR','DLQ','DESCARTADO')
                                           NOT NULL DEFAULT 'PENDIENTE',
    intentos_replicacion    INT            NOT NULL DEFAULT 0,
    proximo_intento         DATETIME(6)    NULL,
    procesado_por           VARCHAR(100)   NULL,
    fecha_aplicacion        DATETIME(6)    NULL,
    mensaje_error           VARCHAR(1000)  NULL,

    CONSTRAINT pk_bitacora_replicacion  PRIMARY KEY (id_evento),
    CONSTRAINT uq_bitacora_orden        UNIQUE (orden_evento),
    CONSTRAINT uq_bitacora_transaccion  UNIQUE (id_transaccion, secuencia),
    CONSTRAINT ck_bitacora_tabla        CHECK (tabla_afectada IN
        ('clientes_flota','centros_operacion','tipos_vehiculo','unidades','posicion_flota',
         'contratos','facturas','extras','factura_extras','movimientos_flota')),
    CONSTRAINT ck_bitacora_secuencia    CHECK (secuencia >= 1),
    CONSTRAINT ck_bitacora_intentos     CHECK (intentos_replicacion >= 0),
    CONSTRAINT ck_bitacora_columnas     CHECK (columnas_modificadas IS NULL OR JSON_VALID(columnas_modificadas)),
    CONSTRAINT ck_bitacora_antes        CHECK (datos_anteriores_json IS NULL OR JSON_VALID(datos_anteriores_json)),
    CONSTRAINT ck_bitacora_despues      CHECK (datos_nuevos_json IS NULL OR JSON_VALID(datos_nuevos_json))
) ENGINE = InnoDB;

-- indices para que los jobs encuentren rapido lo pendiente
CREATE INDEX ix_bitacora_estado   ON bitacora_replicacion (estado_replicacion, proximo_intento, orden_evento);
-- para revisar los cambios de un mismo registro en orden
CREATE INDEX ix_bitacora_registro ON bitacora_replicacion (tabla_afectada, id_registro, orden_evento);
-- para ver que eventos agarro cada job
CREATE INDEX ix_bitacora_job      ON bitacora_replicacion (procesado_por, estado_replicacion);


-- 2. EVENTOS APLICADOS
-- aqui se anota cada evento que vino de Oracle y ya se aplico en MySQL
-- si el job se cae a la mitad y lo vuelve a mandar
CREATE TABLE eventos_aplicados (
    id_evento               CHAR(36)       NOT NULL,
    id_transaccion          CHAR(36)       NULL,
    tabla_afectada          VARCHAR(30)    NOT NULL,
    id_registro             VARCHAR(30)    NOT NULL,
    nodo_origen             ENUM('ORACLE','MYSQL') NOT NULL DEFAULT 'ORACLE',
    hash_registro           CHAR(64)       NULL,
    fecha_aplicacion        DATETIME(6)    NOT NULL DEFAULT (UTC_TIMESTAMP(6)),
    aplicado_por            VARCHAR(100)   NULL,
    CONSTRAINT pk_eventos_aplicados PRIMARY KEY (id_evento)
) ENGINE = InnoDB;


-- 3. PERMISOS
-- repl_mysql lee la bitacora y la marca (EN_PROCESO, APLICADO, ERROR...)
-- no lleva DELETE, la limpieza la hace el EVENT de MySQL
GRANT SELECT, UPDATE ON flotamax.bitacora_replicacion TO 'repl_mysql'@'%';
-- y anota los eventos que ya aplico
GRANT SELECT, INSERT ON flotamax.eventos_aplicados    TO 'repl_mysql'@'%';
-- flotamax_app no necesita permisos aqui, los triggers son los que
-- escriben en la bitacora

-- 4. REVISION
-- tienen que salir las 2 tablas
SELECT table_name
FROM   information_schema.tables
WHERE  table_schema = 'flotamax'
AND    table_name IN ('bitacora_replicacion', 'eventos_aplicados');
