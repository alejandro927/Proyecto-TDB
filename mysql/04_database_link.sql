-- revisiones de MySQL para el link de Oracle
-- datos de conexion:
--   host:      129.146.55.161
--   puerto:    3306
--   base:      flotamax
--   usuario:   repl_mysql
--   password:  la de repl_mysql en 01_usuarios.sql
--   SSL:       obligatorio 

SET NAMES utf8mb4;


-- 1. CONFIGURACION EN LA NUBE
-- dato interesante: si cambia la IP de su VM hay que cambiar la regla en Oracle Cloud


-- 2. REVISAR QUE MYSQL ESTE LISTO
SELECT VERSION() AS version_mysql;

SHOW VARIABLES WHERE Variable_name IN
  ('have_ssl', 'tls_version', 'ssl_cert', 'require_secure_transport', 'bind_address', 'port');

SELECT user, host, ssl_type, account_locked
FROM   mysql.user
WHERE  user = 'repl_mysql';

SHOW GRANTS FOR 'repl_mysql'@'%';

SHOW VARIABLES WHERE Variable_name IN ('auto_increment_increment', 'auto_increment_offset');


-- 3. TABLA QUE USA ORACLE PARA LA PRUEBA (centro 9998)
USE flotamax;

SELECT centro_id, nombre_centro, municipio, pais_operacion, categoria, capacidad_maxima,
       version_registro, fecha_ultima_mod_utc, eliminado
FROM   centros_operacion
ORDER  BY centro_id;


-- 4. REVISAR LO QUE HIZO ORACLE

-- despues del INSERT y del UPDATE
SELECT * FROM centros_operacion WHERE centro_id = 9998;

-- que la conexion de Oracle vaya cifrada (TLS)
SELECT t.PROCESSLIST_USER  AS usuario,
       t.PROCESSLIST_HOST  AS desde_host,
       s.VARIABLE_NAME     AS variable,
       s.VARIABLE_VALUE    AS valor
FROM   performance_schema.threads t
JOIN   performance_schema.status_by_thread s ON s.THREAD_ID = t.THREAD_ID
WHERE  t.PROCESSLIST_USER = 'repl_mysql'
AND    s.VARIABLE_NAME IN ('Ssl_cipher', 'Ssl_version');

-- despues de que Oracle lo borre, tiene que dar 0
SELECT COUNT(*) AS debe_ser_cero FROM centros_operacion WHERE centro_id = 9998;

-- IMPORTANTE: correr siempre al final, si no el siguiente centro sale 10000
ALTER TABLE centros_operacion AUTO_INCREMENT = 1;


-- 5. posibles errores de conexion
-- Access denied            -> password mal o IP no permitida
-- insecure transport       -> Oracle se conecto sin SSL
-- Can't connect (timeout)  -> puerto 3306 cerrado o cambio la IP
-- command denied           -> falta el GRANT (final del 02_tablas.sql)
