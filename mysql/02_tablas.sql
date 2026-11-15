SET NAMES utf8mb4;
USE flotamax;

-- borro las tablas si ya existen para poder correr el script otra vez
-- (primero las hijas y al final las padres por las FK)
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS movimientos_flota;
DROP TABLE IF EXISTS factura_extras;
DROP TABLE IF EXISTS facturas;
DROP TABLE IF EXISTS contratos;
DROP TABLE IF EXISTS posicion_flota;
DROP TABLE IF EXISTS unidades;
DROP TABLE IF EXISTS extras;
DROP TABLE IF EXISTS tipos_vehiculo;
DROP TABLE IF EXISTS centros_operacion;
DROP TABLE IF EXISTS clientes_flota;
DROP TABLE IF EXISTS parametros_replicacion;
DROP TABLE IF EXISTS catalogo_pais;
SET FOREIGN_KEY_CHECKS = 1;

  -- A. CATÁLOGOS
-- A.1 catalogo_pais
-- catalogo de paises, se carga igual en las dos bases y no se replica
-- nombre_pais es UNIQUE porque las otras tablas hacen la FK por el nombre
-- del pais (Honduras) y no por el codigo (HN)
CREATE TABLE catalogo_pais (
    codigo_iso   CHAR(2)      NOT NULL COMMENT 'Código ISO de 2 letras, ej. HN',
    nombre_pais  VARCHAR(50)  NOT NULL COMMENT 'Nombre en español, ej. Honduras',
    CONSTRAINT pk_catalogo_pais        PRIMARY KEY (codigo_iso),
    CONSTRAINT uq_catalogo_pais_nombre UNIQUE (nombre_pais),
    CONSTRAINT ck_catalogo_pais_iso    CHECK (REGEXP_LIKE(codigo_iso, '^[A-Z]{2}$', 'c'))
) ENGINE = InnoDB
  COMMENT = 'Catálogo de países. No se replica.';

-- parametros de replicacion
-- A.2 parametros_replicacion
-- Valores fijos de las transformaciones (tasa de cambio, offset horario,
-- ISV...).
CREATE TABLE parametros_replicacion (
    nombre_parametro  VARCHAR(50)    NOT NULL,
    valor_numerico    DECIMAL(12,4)  NULL,
    valor_texto       VARCHAR(100)   NULL,
    descripcion       VARCHAR(200)   NOT NULL,
    fecha_vigencia    DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_parametros_replicacion PRIMARY KEY (nombre_parametro),
    -- cada parámetro debe tener al menos un valor
    CONSTRAINT ck_parametros_valor CHECK (valor_numerico IS NOT NULL OR valor_texto IS NOT NULL)
) ENGINE = InnoDB
  COMMENT = 'Parámetros fijos de la replicación (tasa, ISV, etc.).';



-- B. TABLAS DE NEGOCIO
-- todas las tablas llevan al final las columnas tecnicas:
--   version_registro      empieza en 1 y sube con cada cambio
--   fecha_ultima_mod_utc  fecha del ultimo cambio en UTC
--   eliminado             para borrar logico (TRUE = borrado)
-- los id son AUTO_INCREMENT y salen pares (2, 4, 6...) por lo que
-- configure en 01_usuarios.sql

-- 1. clientes_flota
CREATE TABLE clientes_flota (
    cliente_id            INT           NOT NULL AUTO_INCREMENT,
    nombre_cliente        VARCHAR(150)  NOT NULL,
    tipo_doc              ENUM('Identidad','Pasaporte','RTN') NOT NULL,
    documento             VARCHAR(25)   NOT NULL,
    telefono_contacto     VARCHAR(25)   NULL,
    email                 VARCHAR(120)  NULL,
    pais                  VARCHAR(50)   NOT NULL COMMENT 'Nombre del país (FK a catalogo_pais)',
    licencia_valida       BOOLEAN       NOT NULL,
    es_corporativo        BOOLEAN       NOT NULL DEFAULT FALSE COMMENT 'TRUE si el cliente es empresa',
    fecha_alta            DATETIME      NOT NULL COMMENT 'UTC',
    -- columnas tecnicas
    version_registro      INT           NOT NULL DEFAULT 1,
    fecha_ultima_mod_utc  DATETIME(6)   NOT NULL DEFAULT (UTC_TIMESTAMP(6)),
    eliminado             BOOLEAN       NOT NULL DEFAULT FALSE,
    CONSTRAINT pk_clientes_flota           PRIMARY KEY (cliente_id),
    CONSTRAINT uq_clientes_flota_documento UNIQUE (tipo_doc, documento),
    CONSTRAINT fk_clientes_flota_pais      FOREIGN KEY (pais) REFERENCES catalogo_pais (nombre_pais),
    CONSTRAINT ck_clientes_flota_version   CHECK (version_registro >= 1)
) ENGINE = InnoDB
  COMMENT = 'Clientes de FlotaMax.';

-- centros de operacion
CREATE TABLE centros_operacion (
    centro_id             INT           NOT NULL AUTO_INCREMENT,
    nombre_centro         VARCHAR(120)  NOT NULL,
    municipio             VARCHAR(100)  NOT NULL,
    pais_operacion        VARCHAR(50)   NOT NULL COMMENT 'Nombre del país (FK a catalogo_pais)',
    categoria             ENUM('Aeropuerto','Urbana','Patio','Taller') NOT NULL,
    capacidad_maxima      INT           NOT NULL,
    -- columnas tecnicas
    version_registro      INT           NOT NULL DEFAULT 1,
    fecha_ultima_mod_utc  DATETIME(6)   NOT NULL DEFAULT (UTC_TIMESTAMP(6)),
    eliminado             BOOLEAN       NOT NULL DEFAULT FALSE,
    CONSTRAINT pk_centros_operacion           PRIMARY KEY (centro_id),
    CONSTRAINT fk_centros_operacion_pais      FOREIGN KEY (pais_operacion) REFERENCES catalogo_pais (nombre_pais),
    CONSTRAINT ck_centros_operacion_capacidad CHECK (capacidad_maxima > 0),
    CONSTRAINT ck_centros_operacion_version   CHECK (version_registro >= 1)
) ENGINE = InnoDB
  COMMENT = 'Centros de operación de FlotaMax.';

-- tipos de vehiculo
CREATE TABLE tipos_vehiculo (
    tipo_id               INT           NOT NULL AUTO_INCREMENT,
    fabricante            VARCHAR(50)   NOT NULL,
    linea                 VARCHAR(50)   NOT NULL,
    segmento              ENUM('Económico','Sedán','SUV','Pickup','Van') NOT NULL,
    pasajeros             TINYINT       NOT NULL,
    tarifa_dia_usd        DECIMAL(10,2) NOT NULL COMMENT 'Tarifa por día en USD',
    -- columnas tecnicas
    version_registro      INT           NOT NULL DEFAULT 1,
    fecha_ultima_mod_utc  DATETIME(6)   NOT NULL DEFAULT (UTC_TIMESTAMP(6)),
    eliminado             BOOLEAN       NOT NULL DEFAULT FALSE,
    CONSTRAINT pk_tipos_vehiculo           PRIMARY KEY (tipo_id),
    CONSTRAINT uq_tipos_vehiculo_linea     UNIQUE (fabricante, linea),
    CONSTRAINT ck_tipos_vehiculo_pasajeros CHECK (pasajeros > 0),
    CONSTRAINT ck_tipos_vehiculo_tarifa    CHECK (tarifa_dia_usd >= 0),
    CONSTRAINT ck_tipos_vehiculo_version   CHECK (version_registro >= 1)
) ENGINE = InnoDB
  COMMENT = 'Tipos de vehículo de FlotaMax.';

-- 4. unidades (vehículos)
-- la placa va con formato PCB-1234. Como la base de datos
-- no distingue mayúsculas (ai_ci), 'pcb-1234' también pasaría. Por eso
-- use REGEXP_LIKE con la opción 'c' (case sensitive), que es la
-- misma expresión pero obliga a que las letras sean MAYÚSCULAS.
CREATE TABLE unidades (
    unidad_id             INT           NOT NULL AUTO_INCREMENT,
    placa                 VARCHAR(12)   NOT NULL COMMENT 'Formato PCB-1234',
    vin                   CHAR(17)      NOT NULL,
    tipo_id               INT           NOT NULL,
    anio_fabricacion      YEAR          NOT NULL,
    odometro_km           INT           NOT NULL COMMENT 'Nunca disminuye',
    es_automatico         BOOLEAN       NOT NULL,
    estado                ENUM('Disponible','Rentado','Mantenimiento','Retenido','Baja') NOT NULL,
    -- columnas tecnicas
    version_registro      INT           NOT NULL DEFAULT 1,
    fecha_ultima_mod_utc  DATETIME(6)   NOT NULL DEFAULT (UTC_TIMESTAMP(6)),
    eliminado             BOOLEAN       NOT NULL DEFAULT FALSE,
    CONSTRAINT pk_unidades          PRIMARY KEY (unidad_id),
    CONSTRAINT uq_unidades_placa    UNIQUE (placa),
    CONSTRAINT uq_unidades_vin      UNIQUE (vin),
    CONSTRAINT fk_unidades_tipo     FOREIGN KEY (tipo_id) REFERENCES tipos_vehiculo (tipo_id),
    CONSTRAINT ck_unidades_placa    CHECK (REGEXP_LIKE(placa, '^[A-Z]{3}-[0-9]{4}$', 'c')),
    CONSTRAINT ck_unidades_vin      CHECK (CHAR_LENGTH(vin) = 17),
    CONSTRAINT ck_unidades_anio     CHECK (anio_fabricacion >= 2000),
    CONSTRAINT ck_unidades_odometro CHECK (odometro_km >= 0),
    CONSTRAINT ck_unidades_version  CHECK (version_registro >= 1)
) ENGINE = InnoDB
  COMMENT = 'Unidades (vehículos) de FlotaMax.';

-- 5. posicion_flota
-- donde esta cada unidad ahorita, solo un registro por unidad (UNIQUE)
CREATE TABLE posicion_flota (
    posicion_id           INT           NOT NULL AUTO_INCREMENT,
    unidad_id             INT           NOT NULL,
    centro_id             INT           NOT NULL,
    combustible           ENUM('Vacío','1/4','1/2','3/4','Lleno') NOT NULL,
    fecha_modificacion    DATETIME      NOT NULL COMMENT 'UTC',
    -- columnas tecnicas
    version_registro      INT           NOT NULL DEFAULT 1,
    fecha_ultima_mod_utc  DATETIME(6)   NOT NULL DEFAULT (UTC_TIMESTAMP(6)),
    eliminado             BOOLEAN       NOT NULL DEFAULT FALSE,
    CONSTRAINT pk_posicion_flota         PRIMARY KEY (posicion_id),
    CONSTRAINT uq_posicion_flota_unidad  UNIQUE (unidad_id),
    CONSTRAINT fk_posicion_flota_unidad  FOREIGN KEY (unidad_id) REFERENCES unidades (unidad_id),
    CONSTRAINT fk_posicion_flota_centro  FOREIGN KEY (centro_id) REFERENCES centros_operacion (centro_id),
    CONSTRAINT ck_posicion_flota_version CHECK (version_registro >= 1)
) ENGINE = InnoDB
  COMMENT = 'Ubicación actual de cada unidad.';


-- 6. contratos
-- los contratos no se borran, solo se cancelan
CREATE TABLE contratos (
    contrato_id           INT           NOT NULL AUTO_INCREMENT,
    cliente_id            INT           NOT NULL,
    unidad_id             INT           NOT NULL,
    centro_salida         INT           NOT NULL,
    centro_retorno        INT           NOT NULL,
    fecha_salida          DATETIME      NOT NULL COMMENT 'UTC',
    fecha_retorno         DATETIME      NOT NULL COMMENT 'UTC',
    estatus               ENUM('Reservado','En curso','Cerrado','Cancelado') NOT NULL,
    nivel_prioridad       TINYINT       NOT NULL COMMENT '1 a 5, 5 = alta',
    -- columnas tecnicas
    version_registro      INT           NOT NULL DEFAULT 1,
    fecha_ultima_mod_utc  DATETIME(6)   NOT NULL DEFAULT (UTC_TIMESTAMP(6)),
    eliminado             BOOLEAN       NOT NULL DEFAULT FALSE,
    CONSTRAINT pk_contratos            PRIMARY KEY (contrato_id),
    CONSTRAINT fk_contratos_cliente    FOREIGN KEY (cliente_id)     REFERENCES clientes_flota (cliente_id),
    CONSTRAINT fk_contratos_unidad     FOREIGN KEY (unidad_id)      REFERENCES unidades (unidad_id),
    CONSTRAINT fk_contratos_salida     FOREIGN KEY (centro_salida)  REFERENCES centros_operacion (centro_id),
    CONSTRAINT fk_contratos_retorno    FOREIGN KEY (centro_retorno) REFERENCES centros_operacion (centro_id),
    CONSTRAINT ck_contratos_fechas     CHECK (fecha_retorno > fecha_salida),
    CONSTRAINT ck_contratos_prioridad  CHECK (nivel_prioridad BETWEEN 1 AND 5),
    CONSTRAINT ck_contratos_version    CHECK (version_registro >= 1)
) ENGINE = InnoDB
  COMMENT = 'Contratos de FlotaMax. Nunca se eliminan, solo se cancelan.';

-- Índice de apoyo para buscar contratos por unidad y fechas
CREATE INDEX ix_contratos_unidad_fechas ON contratos (unidad_id, fecha_salida, fecha_retorno);

-- 7. facturas
-- un contrato solo se puede facturar una vez (UNIQUE contrato_id)
CREATE TABLE facturas (
    factura_id            INT           NOT NULL AUTO_INCREMENT,
    contrato_id           INT           NOT NULL,
    fecha                 DATETIME      NOT NULL COMMENT 'UTC',
    subtotal_usd          DECIMAL(12,2) NOT NULL,
    impuesto_usd          DECIMAL(12,2) NOT NULL COMMENT 'ISV 15 % de las líneas que incluyen impuesto',
    monto_total_usd       DECIMAL(12,2) NOT NULL,
    comentarios           TEXT          NULL,
    -- columnas tecnicas
    version_registro      INT           NOT NULL DEFAULT 1,
    fecha_ultima_mod_utc  DATETIME(6)   NOT NULL DEFAULT (UTC_TIMESTAMP(6)),
    eliminado             BOOLEAN       NOT NULL DEFAULT FALSE,
    CONSTRAINT pk_facturas           PRIMARY KEY (factura_id),
    CONSTRAINT uq_facturas_contrato  UNIQUE (contrato_id),      -- un contrato se factura una sola vez
    CONSTRAINT fk_facturas_contrato  FOREIGN KEY (contrato_id) REFERENCES contratos (contrato_id),
    CONSTRAINT ck_facturas_subtotal  CHECK (subtotal_usd >= 0),
    CONSTRAINT ck_facturas_impuesto  CHECK (impuesto_usd >= 0),
    CONSTRAINT ck_facturas_total     CHECK (monto_total_usd = subtotal_usd + impuesto_usd),
    CONSTRAINT ck_facturas_version   CHECK (version_registro >= 1)
) ENGINE = InnoDB
  COMMENT = 'Facturas en USD. Solo inserción.';

-- 8. extras
CREATE TABLE extras (
    extra_id              INT           NOT NULL AUTO_INCREMENT,
    detalle               VARCHAR(150)  NOT NULL,
    costo_dia_usd         DECIMAL(10,2) NOT NULL COMMENT 'Costo por día en USD',
    autorizacion_previa   BOOLEAN       NOT NULL,
    categoria             ENUM('Renta','Seguro','Equipo','Chofer','Entrega') NOT NULL,
    -- columnas tecnicas
    version_registro      INT           NOT NULL DEFAULT 1,
    fecha_ultima_mod_utc  DATETIME(6)   NOT NULL DEFAULT (UTC_TIMESTAMP(6)),
    eliminado             BOOLEAN       NOT NULL DEFAULT FALSE,
    CONSTRAINT pk_extras          PRIMARY KEY (extra_id),
    CONSTRAINT ck_extras_costo    CHECK (costo_dia_usd >= 0),
    CONSTRAINT ck_extras_version  CHECK (version_registro >= 1)
) ENGINE = InnoDB
  COMMENT = 'Servicios extra de FlotaMax.';

-- 9. factura_extras  
-- PK compuesta (factura_id, extra_id). La renta base de la unidad se
-- registra como una línea con un extra de categoría 'Renta'.
-- incluye_impuesto = TRUE significa que a esa línea SÍ se le cobra ISV

CREATE TABLE factura_extras (
    factura_id            INT           NOT NULL,
    extra_id              INT           NOT NULL,
    dias                  INT           NOT NULL,
    subtotal_usd          DECIMAL(12,2) NOT NULL,
    incluye_impuesto      BOOLEAN       NOT NULL COMMENT 'TRUE = se le cobra ISV',
    -- columnas tecnicas
    version_registro      INT           NOT NULL DEFAULT 1,
    fecha_ultima_mod_utc  DATETIME(6)   NOT NULL DEFAULT (UTC_TIMESTAMP(6)),
    eliminado             BOOLEAN       NOT NULL DEFAULT FALSE,
    CONSTRAINT pk_factura_extras          PRIMARY KEY (factura_id, extra_id),
    CONSTRAINT fk_factura_extras_factura  FOREIGN KEY (factura_id) REFERENCES facturas (factura_id),
    CONSTRAINT fk_factura_extras_extra    FOREIGN KEY (extra_id)   REFERENCES extras (extra_id),
    CONSTRAINT ck_factura_extras_dias     CHECK (dias > 0),
    CONSTRAINT ck_factura_extras_subtotal CHECK (subtotal_usd >= 0),
    CONSTRAINT ck_factura_extras_version  CHECK (version_registro >= 1)
) ENGINE = InnoDB
  COMMENT = 'Líneas de factura en USD. Solo inserción.';

-- 10. movimientos_flota
-- historial de traslados, nunca se modifica ni se borra
CREATE TABLE movimientos_flota (
    movimiento_id         INT           NOT NULL AUTO_INCREMENT,
    unidad_id             INT           NOT NULL,
    centro_origen         INT           NOT NULL,
    centro_destino        INT           NOT NULL,
    km_recorridos         INT           NOT NULL,
    motivo                ENUM('Rebalanceo','Mantenimiento','Devolución') NOT NULL,
    fecha_movimiento      DATETIME      NOT NULL COMMENT 'UTC',
    -- columnas tecnicas
    version_registro      INT           NOT NULL DEFAULT 1,
    fecha_ultima_mod_utc  DATETIME(6)   NOT NULL DEFAULT (UTC_TIMESTAMP(6)),
    eliminado             BOOLEAN       NOT NULL DEFAULT FALSE,
    CONSTRAINT pk_movimientos_flota          PRIMARY KEY (movimiento_id),
    CONSTRAINT fk_movimientos_flota_unidad   FOREIGN KEY (unidad_id)      REFERENCES unidades (unidad_id),
    CONSTRAINT fk_movimientos_flota_origen   FOREIGN KEY (centro_origen)  REFERENCES centros_operacion (centro_id),
    CONSTRAINT fk_movimientos_flota_destino  FOREIGN KEY (centro_destino) REFERENCES centros_operacion (centro_id),
    CONSTRAINT ck_movimientos_flota_destino  CHECK (centro_destino <> centro_origen),
    CONSTRAINT ck_movimientos_flota_km       CHECK (km_recorridos > 0),
    CONSTRAINT ck_movimientos_flota_version  CHECK (version_registro >= 1)
) ENGINE = InnoDB
  COMMENT = 'Historial de traslados. Solo inserción.';


-- C. PERMISOS
-- los permisos los doy tabla por tabla y no con flotamax.* para que cada
-- usuario solo tenga lo que necesita

-- usuario de operacion normal de FlotaMax
GRANT SELECT ON flotamax.catalogo_pais          TO 'flotamax_app'@'%';
GRANT SELECT ON flotamax.parametros_replicacion TO 'flotamax_app'@'%';
GRANT SELECT, INSERT, UPDATE ON flotamax.clientes_flota    TO 'flotamax_app'@'%';
GRANT SELECT, INSERT, UPDATE ON flotamax.centros_operacion TO 'flotamax_app'@'%';
GRANT SELECT, INSERT, UPDATE ON flotamax.tipos_vehiculo    TO 'flotamax_app'@'%';
GRANT SELECT, INSERT, UPDATE ON flotamax.unidades          TO 'flotamax_app'@'%';
GRANT SELECT, INSERT, UPDATE ON flotamax.posicion_flota    TO 'flotamax_app'@'%';
GRANT SELECT, INSERT, UPDATE ON flotamax.contratos         TO 'flotamax_app'@'%';
GRANT SELECT, INSERT, UPDATE ON flotamax.extras            TO 'flotamax_app'@'%';
-- facturas, detalle y traslados son "solo inserción"
GRANT SELECT, INSERT         ON flotamax.facturas          TO 'flotamax_app'@'%';
GRANT SELECT, INSERT         ON flotamax.factura_extras    TO 'flotamax_app'@'%';
GRANT SELECT, INSERT         ON flotamax.movimientos_flota TO 'flotamax_app'@'%';

-- usuario de replicacion
GRANT SELECT ON flotamax.catalogo_pais          TO 'repl_mysql'@'%';
GRANT SELECT ON flotamax.parametros_replicacion TO 'repl_mysql'@'%';
-- le deje DELETE para poder borrar los registros de prueba, en la
-- replicacion el borrado es logico (eliminado = TRUE)
GRANT SELECT, INSERT, UPDATE, DELETE ON flotamax.clientes_flota    TO 'repl_mysql'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON flotamax.centros_operacion TO 'repl_mysql'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON flotamax.tipos_vehiculo    TO 'repl_mysql'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON flotamax.unidades          TO 'repl_mysql'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON flotamax.posicion_flota    TO 'repl_mysql'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON flotamax.contratos         TO 'repl_mysql'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON flotamax.facturas          TO 'repl_mysql'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON flotamax.extras            TO 'repl_mysql'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON flotamax.factura_extras    TO 'repl_mysql'@'%';
-- traslados: solo inserción (nunca se modifican ni se eliminan)
GRANT SELECT, INSERT                 ON flotamax.movimientos_flota TO 'repl_mysql'@'%';
-- cuando haga la bitacora hay que darle permisos a repl_mysql sobre
-- esas tablas tambien

-- revision rapida: tienen que salir 12 tablas
SELECT table_name, table_rows, table_comment
FROM   information_schema.tables
WHERE  table_schema = 'flotamax'
ORDER  BY table_name;
