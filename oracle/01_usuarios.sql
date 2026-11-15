-- =====================================================================
-- RutaSur · Oracle AI Database 26ai Free · Usuarios del proyecto
-- Ejecutar UNA vez conectado como SYSTEM a la PDB:
--   sqlplus system@localhost:1521/FREEPDB1
-- Las contraseñas reales NO se guardan en el repositorio:
-- reemplazar <CLAVE_RUTASUR> y <CLAVE_REPLICADOR> al ejecutar.
-- =====================================================================

-- Dueño del esquema: tablas, triggers, paquetes y jobs de RutaSur
CREATE USER rutasur IDENTIFIED BY "<CLAVE_RUTASUR>"
  DEFAULT TABLESPACE users QUOTA UNLIMITED ON users;

GRANT CREATE SESSION, CREATE TABLE, CREATE SEQUENCE, CREATE TRIGGER,
      CREATE PROCEDURE, CREATE VIEW, CREATE JOB, CREATE DATABASE LINK
  TO rutasur;

-- Usuario dedicado de replicación: dueño de los jobs y del database link.
-- Los jobs de DBMS_SCHEDULER se ejecutan como su dueño, así que los cambios
-- que aplican en Oracle quedan hechos por REPLICADOR. Los triggers ignoran
-- los cambios de este usuario (SESSION_USER) para evitar la replicación circular.
-- Sus permisos sobre las tablas y la bitácora los otorga RUTASUR más adelante.
CREATE USER replicador IDENTIFIED BY "<CLAVE_REPLICADOR>";
GRANT CREATE SESSION, CREATE JOB, CREATE DATABASE LINK, CREATE PROCEDURE
  TO replicador;

-- Verificación
SELECT username, account_status FROM dba_users
 WHERE username IN ('RUTASUR','REPLICADOR');
