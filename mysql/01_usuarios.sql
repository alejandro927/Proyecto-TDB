SET NAMES utf8mb4;
-- 1. Base de datos
CREATE DATABASE IF NOT EXISTS flotamax
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;
-- 2. Estrategia de identificadores: rangos por nodo (PARES en MySQL)
-- auto_increment_increment = 2 -> los ids avanzan de 2 en 2
-- auto_increment_offset    = 2 -> el primer id es 2
-- Resultado: 2, 4, 6, 8...
-- Así los dos motores insertan al mismo tiempo sin chocar
SET PERSIST auto_increment_increment = 2;
SET PERSIST auto_increment_offset    = 2;

-- FlotaMax guarda las fechas en UTC
SET PERSIST time_zone = '+00:00';

-- 3. Usuario de operación normal (FlotaMax)
CREATE USER IF NOT EXISTS 'flotamax_app'@'%'
  IDENTIFIED BY 'FlotaMax#2026db';

-- 4. Usuario de replicacion  y la password (el que usa el database link de Oracle)
CREATE USER IF NOT EXISTS 'repl_mysql'@'%'
  IDENTIFIED BY 'Repl#MySQL2026'
  REQUIRE SSL;

-- Nota sobre el host '%': permite conectarse desde cualquier IP. Cuando
-- este la IP fija del servidor Oracle se cambia

-- 5. Verificación
SELECT user, host, ssl_type
FROM   mysql.user
WHERE  user IN ('flotamax_app', 'repl_mysql');

SHOW GLOBAL VARIABLES WHERE Variable_name IN
  ('auto_increment_increment', 'auto_increment_offset', 'time_zone', 'version');
