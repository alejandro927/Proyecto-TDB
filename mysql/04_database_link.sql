-- conexion del link de Oracle hacia MySQL
-- el link se crea del lado de Oracle, aqui solo dejo MySQL listo y reviso
-- que lo que hace Oracle por el link sea correcto
-- datos que hay que pasarle al companero de Oracle:
--   host:      FALTA (IP o DNS del MySQL en la nube)
--   puerto:    3306
--   base:      flotamax
--   usuario:   repl_mysql
--   password:  FALTA (pasarsela en persona, no subirla al repo)

SET NAMES utf8mb4;


-- 1. LO QUE FALTA CONFIGURAR 
-- FALTA: subir la base a la nube (Oracle Cloud)
-- FALTA: abrir el puerto 3306 solo para la IP del servidor de Oracle
-- FALTA: que el servidor acepte conexiones de afuera (en la nube ya viene,
--        en un servidor propio es bind-address = 0.0.0.0 en my.cnf)
-- FALTA: probar desde la maquina de Oracle antes de crear el link:
--        mysql -h <host> -P 3306 -u repl_mysql -p --ssl-mode=REQUIRED flotamax
--        SELECT COUNT(*) FROM catalogo_pais;   -- tiene que dar 195
-- el TLS ya viene con MySQL 8, no hay que hacer nada extra


-- 2. REVISAR QUE MYSQL ESTE LISTO

-- version, tiene que ser 8.0.16 o mayor para que funcionen los CHECK
SELECT VERSION() AS version_mysql;

-- que tenga TLS (have_ssl = YES)
SHOW VARIABLES WHERE Variable_name IN
  ('have_ssl', 'tls_version', 'ssl_cert', 'require_secure_transport', 'bind_address', 'port');

-- que exista repl_mysql y que pida SSL (ssl_type = ANY)
SELECT user, host, ssl_type, account_locked
FROM   mysql.user
WHERE  user = 'repl_mysql';

-- permisos de repl_mysql, solo tablas de flotamax
SHOW GRANTS FOR 'repl_mysql'@'%';

-- que los id salgan pares (tiene que dar 2 y 2)
SHOW VARIABLES WHERE Variable_name IN ('auto_increment_increment', 'auto_increment_offset');


-- 3. TABLA QUE VA A USAR ORACLE PARA LA PRUEBA
-- Oracle mete el centro 9998, lo actualiza y al final lo borra
-- asi esta antes de la prueba
USE flotamax;

SELECT centro_id, nombre_centro, municipio, pais_operacion, categoria, capacidad_maxima,
       version_registro, fecha_ultima_mod_utc, eliminado
FROM   centros_operacion
ORDER  BY centro_id;


-- 4. REVISAR LO QUE HIZO ORACLE (correr despues de cada prueba de ellos)

-- despues del INSERT: tiene que salir el 9998 con capacidad 10
SELECT * FROM centros_operacion WHERE centro_id = 9998;

-- despues del UPDATE: capacidad 20 y nombre 'PRUEBA DB LINK (actualizado)'
SELECT centro_id, nombre_centro, capacidad_maxima
FROM   centros_operacion
WHERE  centro_id = 9998;

-- mientras Oracle esta conectado: que la conexion vaya cifrada
-- (Ssl_version tiene que decir TLSv1.2 o TLSv1.3)
SELECT t.PROCESSLIST_USER  AS usuario,
       t.PROCESSLIST_HOST  AS desde_host,
       s.VARIABLE_NAME     AS variable,
       s.VARIABLE_VALUE    AS valor
FROM   performance_schema.threads t
JOIN   performance_schema.status_by_thread s ON s.THREAD_ID = t.THREAD_ID
WHERE  t.PROCESSLIST_USER = 'repl_mysql'
AND    s.VARIABLE_NAME IN ('Ssl_cipher', 'Ssl_version');

-- despues de que Oracle borre: tiene que dar 0
SELECT COUNT(*) AS debe_ser_cero FROM centros_operacion WHERE centro_id = 9998;
ALTER TABLE centros_operacion AUTO_INCREMENT = 1;


-- 5. posibles errores que pueden aparecer al crear el link de Oracle
-- Access denied                        -> password mal o la IP no esta permitida
-- insecure transport are prohibited    -> Oracle se conecto sin SSL
-- Can't connect (timeout)              -> puerto 3306 cerrado en la nube
-- command denied                       -> falta el GRANT (final del 02_tablas.sql)
-- tildes raras                         -> usar utf8mb4 en la conexion de Oracle
