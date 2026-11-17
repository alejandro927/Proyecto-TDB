-- =====================================================================
-- 04_database_link.sql  -  RutaSur (Oracle) -> FlotaMax (MySQL)
-- Database link heterogeneo con DG4ODBC (Heterogeneous Services)
--
-- Cadena: Oracle -> listener -> dg4odbc -> unixODBC -> MySQL ODBC -> MySQL
--
-- IMPORTANTE: este archivo NO lleva contrasenas ni IPs reales.
--   <HOST_MYSQL>, <PUERTO_MYSQL> y <CLAVE_REPL_MYSQL> se reemplazan
--   solo en el servidor, nunca en el repositorio.
-- =====================================================================

-- ---------------------------------------------------------------------
-- PARTE A. Configuracion del sistema operativo (no es SQL; se hace en la
-- VM de Oracle). Se deja documentada aqui como referencia.
-- ---------------------------------------------------------------------
/*
A1. Paquetes (como azureuser):
    sudo dnf install -y unixODBC mysql-connector-odbc mysql
    odbcinst -q -d          -- ver nombre exacto del driver ANSI

A2. /etc/odbc.ini  (DSN)
    [FLOTAMAX]
    Description = MySQL FlotaMax
    Driver      = <NOMBRE DEL DRIVER ANSI>
    SERVER      = <HOST_MYSQL>
    PORT        = <PUERTO_MYSQL>
    DATABASE    = flotamax
    SSLMODE     = REQUIRED          -- con ca.pem: VERIFY_CA + SSLCA = /ruta/ca.pem
    CHARSET     = utf8mb4

    Prueba:  read -s PW ; isql -v FLOTAMAX repl_mysql "$PW" ; unset PW

A3. $ORACLE_HOME/hs/admin/initFLOTAMAX.ora  (como usuario oracle)
    HS_FDS_CONNECT_INFO = FLOTAMAX
    HS_FDS_SHAREABLE_NAME = /usr/lib64/libodbc.so
    HS_FDS_SUPPORT_STATISTICS = FALSE
    HS_LANGUAGE = AMERICAN_AMERICA.AL32UTF8
    HS_NLS_NCHAR = UCS2
    HS_FDS_TRACE_LEVEL = OFF
    set ODBCINI = /etc/odbc.ini

A4. Agregado al final de $ORACLE_HOME/network/admin/listener.ora
    SID_LIST_LISTENER =
      (SID_LIST =
        (SID_DESC =
          (SID_NAME = FLOTAMAX)
          (ORACLE_HOME = /opt/oracle/product/26ai/dbhomeFree)
          (PROGRAM = dg4odbc)
          (ENVS = "LD_LIBRARY_PATH=/usr/lib64:/opt/oracle/product/26ai/dbhomeFree/lib")
        )
      )

A5. Agregado al final de $ORACLE_HOME/network/admin/tnsnames.ora
    FLOTAMAX =
      (DESCRIPTION =
        (ADDRESS = (PROTOCOL = TCP)(HOST = <HOST_INTERNO_VM_ORACLE>)(PORT = 1521))
        (CONNECT_DATA = (SID = FLOTAMAX))
        (HS = OK)
      )

A6. Recargar y comprobar
    lsnrctl reload
    lsnrctl status        -- Service "FLOTAMAX" ... status UNKNOWN (normal)
    tnsping FLOTAMAX      -- OK
*/

-- ---------------------------------------------------------------------
-- PARTE B. Crear el database link  (conectado como REPLICADOR en FREEPDB1)
--   sqlplus replicador@//<HOST_INTERNO_VM_ORACLE>:1521/freepdb1
-- El link es privado de REPLICADOR: los triggers ignoran a ese usuario
-- (evita la replicacion circular / eco).
-- ---------------------------------------------------------------------
-- CREATE DATABASE LINK flotamax
--   CONNECT TO "repl_mysql" IDENTIFIED BY "<CLAVE_REPL_MYSQL>"
--   USING 'FLOTAMAX';

-- Notas del gateway:
--  * Tablas y columnas de MySQL van entre comillas dobles y en minuscula.
--  * Hacer COMMIT despues de cada cambio remoto.
--  * Funciones como CAST no se envian a MySQL (ORA-02070): se calculan
--    antes en Oracle (variable PL/SQL) y se manda solo el valor.
--  * Homologacion: eliminado es BOOLEAN (0/1) en MySQL y 'S'/'N' en Oracle;
--    las fechas en MySQL estan en UTC.

-- ---------------------------------------------------------------------
-- PARTE C. Prueba de SELECT, INSERT, UPDATE y DELETE (repetible)
-- Ejecutar como REPLICADOR:  @04_database_link.sql
-- Al terminar, en MySQL reiniciar el AUTO_INCREMENT de centros_operacion
-- (lo hace el 04_database_link.sql del lado MySQL).
-- ---------------------------------------------------------------------
SET ECHO ON
SET LINESIZE 150
COLUMN nombre FORMAT A32
COLUMN fecha_utc FORMAT A20
ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD HH24:MI:SS';

PROMPT ===== 0. Limpieza previa =====
DELETE FROM "centros_operacion"@flotamax WHERE "centro_id" = 9998;
COMMIT;

PROMPT ===== 1. SELECT =====
SELECT COUNT(*) AS paises FROM "catalogo_pais"@flotamax;

PROMPT ===== 2. INSERT =====
DECLARE
  v_utc DATE := CAST(SYS_EXTRACT_UTC(SYSTIMESTAMP) AS DATE);
BEGIN
  INSERT INTO "centros_operacion"@flotamax
    ("centro_id", "nombre_centro", "municipio", "pais_operacion", "categoria",
     "capacidad_maxima", "version_registro", "fecha_ultima_mod_utc", "eliminado")
  VALUES
    (9998, 'PRUEBA DB LINK', 'Tegucigalpa', 'Honduras', 'Patio', 10, 1, v_utc, 0);
  COMMIT;
END;
/
SELECT "centro_id" AS id, "nombre_centro" AS nombre, "capacidad_maxima" AS capacidad,
       "version_registro" AS version, "fecha_ultima_mod_utc" AS fecha_utc
FROM "centros_operacion"@flotamax WHERE "centro_id" = 9998;

PROMPT ===== 3. UPDATE =====
DECLARE
  v_utc DATE := CAST(SYS_EXTRACT_UTC(SYSTIMESTAMP) AS DATE);
BEGIN
  UPDATE "centros_operacion"@flotamax
     SET "capacidad_maxima" = 20,
         "nombre_centro" = 'PRUEBA DB LINK (actualizado)',
         "version_registro" = "version_registro" + 1,
         "fecha_ultima_mod_utc" = v_utc
   WHERE "centro_id" = 9998;
  COMMIT;
END;
/
SELECT "centro_id" AS id, "nombre_centro" AS nombre, "capacidad_maxima" AS capacidad,
       "version_registro" AS version, "fecha_ultima_mod_utc" AS fecha_utc
FROM "centros_operacion"@flotamax WHERE "centro_id" = 9998;

PROMPT ===== 4. DELETE =====
DELETE FROM "centros_operacion"@flotamax WHERE "centro_id" = 9998;
COMMIT;
SELECT COUNT(*) AS quedan FROM "centros_operacion"@flotamax WHERE "centro_id" = 9998;

SET ECHO OFF
