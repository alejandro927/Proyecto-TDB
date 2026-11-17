-- datos de prueba de FlotaMax
-- no mando los id, los pone solo el AUTO_INCREMENT (salen pares)
-- para las FK busco el id con un SELECT por placa, documento o nombre
SET NAMES utf8mb4;
USE flotamax;

-- por si acaso lo pongo aqui tambien para que los id salgan pares
SET SESSION auto_increment_increment = 2;
SET SESSION auto_increment_offset    = 2;
SET SESSION time_zone = '+00:00';

START TRANSACTION;

-- 1. CATALOGOS
-- paises con su codigo ISO
INSERT INTO catalogo_pais (codigo_iso, nombre_pais) VALUES
('AD', 'Andorra'),
('AE', 'Emiratos Árabes Unidos'),
('AF', 'Afganistán'),
('AG', 'Antigua y Barbuda'),
('AL', 'Albania'),
('AM', 'Armenia'),
('AO', 'Angola'),
('AR', 'Argentina'),
('AT', 'Austria'),
('AU', 'Australia'),
('AZ', 'Azerbaiyán'),
('BA', 'Bosnia y Herzegovina'),
('BB', 'Barbados'),
('BD', 'Bangladés'),
('BE', 'Bélgica'),
('BF', 'Burkina Faso'),
('BG', 'Bulgaria'),
('BH', 'Baréin'),
('BI', 'Burundi'),
('BJ', 'Benín'),
('BN', 'Brunéi'),
('BO', 'Bolivia'),
('BR', 'Brasil'),
('BS', 'Bahamas'),
('BT', 'Bután'),
('BW', 'Botsuana'),
('BY', 'Bielorrusia'),
('BZ', 'Belice'),
('CA', 'Canadá'),
('CD', 'República Democrática del Congo'),
('CF', 'República Centroafricana'),
('CG', 'República del Congo'),
('CH', 'Suiza'),
('CI', 'Costa de Marfil'),
('CL', 'Chile'),
('CM', 'Camerún'),
('CN', 'China'),
('CO', 'Colombia'),
('CR', 'Costa Rica'),
('CU', 'Cuba'),
('CV', 'Cabo Verde'),
('CY', 'Chipre'),
('CZ', 'República Checa'),
('DE', 'Alemania'),
('DJ', 'Yibuti'),
('DK', 'Dinamarca'),
('DM', 'Dominica'),
('DO', 'República Dominicana'),
('DZ', 'Argelia'),
('EC', 'Ecuador'),
('EE', 'Estonia'),
('EG', 'Egipto'),
('ER', 'Eritrea'),
('ES', 'España'),
('ET', 'Etiopía'),
('FI', 'Finlandia'),
('FJ', 'Fiyi'),
('FM', 'Micronesia'),
('FR', 'Francia'),
('GA', 'Gabón'),
('GB', 'Reino Unido'),
('GD', 'Granada'),
('GE', 'Georgia'),
('GH', 'Ghana'),
('GM', 'Gambia'),
('GN', 'Guinea'),
('GQ', 'Guinea Ecuatorial'),
('GR', 'Grecia'),
('GT', 'Guatemala'),
('GW', 'Guinea-Bisáu'),
('GY', 'Guyana'),
('HN', 'Honduras'),
('HR', 'Croacia'),
('HT', 'Haití'),
('HU', 'Hungría'),
('ID', 'Indonesia'),
('IE', 'Irlanda'),
('IL', 'Israel'),
('IN', 'India'),
('IQ', 'Irak'),
('IR', 'Irán'),
('IS', 'Islandia'),
('IT', 'Italia'),
('JM', 'Jamaica'),
('JO', 'Jordania'),
('JP', 'Japón'),
('KE', 'Kenia'),
('KG', 'Kirguistán'),
('KH', 'Camboya'),
('KI', 'Kiribati'),
('KM', 'Comoras'),
('KN', 'San Cristóbal y Nieves'),
('KP', 'Corea del Norte'),
('KR', 'Corea del Sur'),
('KW', 'Kuwait'),
('KZ', 'Kazajistán'),
('LA', 'Laos'),
('LB', 'Líbano'),
('LC', 'Santa Lucía'),
('LI', 'Liechtenstein'),
('LK', 'Sri Lanka'),
('LR', 'Liberia'),
('LS', 'Lesoto'),
('LT', 'Lituania'),
('LU', 'Luxemburgo'),
('LV', 'Letonia'),
('LY', 'Libia'),
('MA', 'Marruecos'),
('MC', 'Mónaco'),
('MD', 'Moldavia'),
('ME', 'Montenegro'),
('MG', 'Madagascar'),
('MH', 'Islas Marshall'),
('MK', 'Macedonia del Norte'),
('ML', 'Malí'),
('MM', 'Myanmar'),
('MN', 'Mongolia'),
('MR', 'Mauritania'),
('MT', 'Malta'),
('MU', 'Mauricio'),
('MV', 'Maldivas'),
('MW', 'Malaui'),
('MX', 'México'),
('MY', 'Malasia'),
('MZ', 'Mozambique'),
('NA', 'Namibia'),
('NE', 'Níger'),
('NG', 'Nigeria'),
('NI', 'Nicaragua'),
('NL', 'Países Bajos'),
('NO', 'Noruega'),
('NP', 'Nepal'),
('NR', 'Nauru'),
('NZ', 'Nueva Zelanda'),
('OM', 'Omán'),
('PA', 'Panamá'),
('PE', 'Perú'),
('PG', 'Papúa Nueva Guinea'),
('PH', 'Filipinas'),
('PK', 'Pakistán'),
('PL', 'Polonia'),
('PT', 'Portugal'),
('PW', 'Palaos'),
('PY', 'Paraguay'),
('QA', 'Catar'),
('RO', 'Rumania'),
('RS', 'Serbia'),
('RU', 'Rusia'),
('RW', 'Ruanda'),
('SA', 'Arabia Saudita'),
('SB', 'Islas Salomón'),
('SC', 'Seychelles'),
('SD', 'Sudán'),
('SE', 'Suecia'),
('SG', 'Singapur'),
('SI', 'Eslovenia'),
('SK', 'Eslovaquia'),
('SL', 'Sierra Leona'),
('SM', 'San Marino'),
('SN', 'Senegal'),
('SO', 'Somalia'),
('SR', 'Surinam'),
('SS', 'Sudán del Sur'),
('ST', 'Santo Tomé y Príncipe'),
('SV', 'El Salvador'),
('SY', 'Siria'),
('SZ', 'Esuatini'),
('TD', 'Chad'),
('TG', 'Togo'),
('TH', 'Tailandia'),
('TJ', 'Tayikistán'),
('TL', 'Timor-Leste'),
('TM', 'Turkmenistán'),
('TN', 'Túnez'),
('TO', 'Tonga'),
('TR', 'Turquía'),
('TT', 'Trinidad y Tobago'),
('TV', 'Tuvalu'),
('TW', 'Taiwán, provincia de China'),
('TZ', 'Tanzania'),
('UA', 'Ucrania'),
('UG', 'Uganda'),
('US', 'Estados Unidos'),
('UY', 'Uruguay'),
('UZ', 'Uzbekistán'),
('VA', 'Ciudad del Vaticano'),
('VC', 'San Vicente y las Granadinas'),
('VE', 'Venezuela'),
('VN', 'Vietnam'),
('VU', 'Vanuatu'),
('WS', 'Samoa'),
('YE', 'Yemen'),
('ZA', 'Sudáfrica'),
('ZM', 'Zambia'),
('ZW', 'Zimbabue');

-- parametros (tasa de cambio, ISV, intentos...)
-- solo pide la tasa de cambio aqui, pero es mas facil tener todos los parametros en una tabla
INSERT INTO parametros_replicacion (nombre_parametro, valor_numerico, valor_texto, descripcion) VALUES
    -- tasa de cambio (24.80 lempiras por dolar)
    ('TASA_HNL_POR_USD', 24.8000, NULL,
     'Lempiras por 1 dólar. HNL->USD divide, USD->HNL multiplica. Redondeo 2 decimales mitad hacia arriba'),
    -- diferencia de horas: aqui guardamos en UTC y en la otra base se guarda en hora de Honduras (UTC-6)
    ('OFFSET_HORAS_UTC', -6, NULL,
     'Oracle guarda hora local UTC-6. Hacia MySQL se suman 6 h, hacia Oracle se restan 6 h'),
    -- el ISV es 15% de las lineas que llevan impuesto, lo uso para calcular
    -- el impuesto de las facturas
    ('PORCENTAJE_ISV', 15, NULL,
     'ISV que se aplica a las líneas de factura con incluye_impuesto = TRUE'),
    -- el documento dice que despues de 5 intentos fallidos el evento se va la cola de errores (DLQ)
    ('MAX_INTENTOS_REPLICACION', 5, NULL,
     'Intentos fallidos antes de mandar el evento a la DLQ'),
    -- nombre de esta base para la bitacora, ahi se guarda de donde vino cada cambio (ORACLE o MYSQL)
    ('NODO_LOCAL', NULL, 'MYSQL',
     'Nombre de este nodo para el campo nodo_origen de la bitácora'),
    -- recordatorio de que aqui los id son pares y en la otra base impares para que no choquen
    ('PARIDAD_IDS', 2, 'PAR',
     'MySQL genera ids pares (auto_increment_increment=2, offset=2). Oracle genera impares');


-- 2. centros de operacion
INSERT INTO centros_operacion (nombre_centro, municipio, pais_operacion, categoria, capacidad_maxima) VALUES
    ('Aeropuerto Internacional de Palmerola',  'Comayagua',   'Honduras',   'Aeropuerto', 30),
    ('FlotaMax Boulevard Morazán',             'Tegucigalpa', 'Honduras',   'Urbana',     25),
    ('Patio Corporativo Villanueva',           'Villanueva',  'Honduras',   'Patio',      50),
    ('Taller FlotaMax Choloma',                'Choloma',     'Honduras',   'Taller',     12),
    ('Aeropuerto Juan Santamaría',             'Alajuela',    'Costa Rica', 'Aeropuerto', 30),
    ('Managua Carretera a Masaya',             'Managua',     'Nicaragua',  'Urbana',     20);


-- 3. tipos de vehiculo (tarifa en dolares)
INSERT INTO tipos_vehiculo (fabricante, linea, segmento, pasajeros, tarifa_dia_usd) VALUES
    ('Mitsubishi', 'Mirage',   'Económico', 5,  40.00),
    ('Honda',      'Civic',    'Sedán',     5,  58.50),
    ('Toyota',     'RAV4',     'SUV',       5,  85.00),
    ('Nissan',     'Frontier', 'Pickup',    5,  92.75),
    ('Hyundai',    'Staria',   'Van',       11, 120.00),
    -- esta tiene centavos para probar el redondeo
    ('Kia',        'Sportage', 'SUV',       5,  79.99);


-- 4. extras (costo en dolares)
-- la renta base va en 0 porque se cobra con la tarifa del vehiculo
INSERT INTO extras (detalle, costo_dia_usd, autorizacion_previa, categoria) VALUES
    ('Renta base de la unidad (tarifa diaria según tipo de vehículo)', 0.00, FALSE, 'Renta'), 
    ('Seguro premium de cobertura total para flotas corporativas, sin deducible, con asistencia vial 24/7 en toda Centroamérica y vehículo sustituto',
                                                                     12.00, FALSE, 'Seguro'),
    ('Wi-Fi portátil 4G',                                             6.50, FALSE, 'Equipo'),
    ('Rack de techo para equipaje',                                   8.00, FALSE, 'Equipo'),
    ('Chofer corporativo bilingüe',                                  45.00, TRUE,  'Chofer'),
    ('Entrega de la unidad en oficina del cliente',                  15.00, FALSE, 'Entrega');


-- 5. clientes
INSERT INTO clientes_flota (nombre_cliente, tipo_doc, documento, telefono_contacto, email, pais, licencia_valida, es_corporativo, fecha_alta) VALUES
    ('Inversiones Turísticas del Caribe S.A.', 'RTN', '08019015678901', '+504 2232-4500', 'flota@intucaribe.hn',
     'Honduras', TRUE, TRUE, '2025-02-10 15:30:00'),
    ('Luis Fernando Andino Reyes', 'Identidad', '0801198809876', '+504 9712-3344', 'luis.andino@correo.hn',
     'Honduras', TRUE, FALSE, '2025-05-22 18:10:00'),
    ('Karla Patricia Zelaya Ordóñez', 'Identidad', '0318199200456', '+504 3190-8877', 'kzelaya@correo.hn',
     'Honduras', TRUE, FALSE, '2025-09-03 14:45:00'),
    ('Daniel Alberto Vargas Quesada', 'Pasaporte', 'CR1122334', '+506 8800-1122', 'dvargas@correo.cr',
     'Costa Rica', TRUE, FALSE, '2026-01-15 20:00:00'),
    ('Emily Johnson', 'Pasaporte', '678912345', '+1 512 555 0147', 'emily.johnson@mail.com',
     'Estados Unidos', TRUE, FALSE, '2026-03-02 02:15:00'),   -- 1-mar 8:15pm en Honduras
    -- este no tiene licencia, no puede tener contrato en curso
    ('Mario Enrique Bonilla Cruz', 'Identidad', '1501198000777', '+504 8899-0011', NULL,
     'Honduras', FALSE, FALSE, '2026-05-19 16:20:00'),
    -- nombre largo a proposito para probar
    ('Constructora Centroamericana de Infraestructura Vial, Puentes, Obras Hidráulicas y Proyectos Energéticos, Sociedad Anónima de Capital Variable',
     'RTN', '08019120004455', '+504 2270-9000', 'compras@constructoraca.hn',
     'Honduras', TRUE, TRUE, '2026-07-07 13:00:00'),
    ('Gabriela Sofía Rojas Murillo', 'Pasaporte', 'N00987654', '+505 8456-7788', 'gaby.rojas@correo.ni',
     'Nicaragua', TRUE, FALSE, '2026-09-12 22:40:00');


-- 6. unidades
-- deje por lo menos una en cada estado
INSERT INTO unidades (placa, vin, tipo_id, anio_fabricacion, odometro_km, es_automatico, estado) VALUES
    ('HBA-1001', 'ML32AUHJ5PH004512', (SELECT tipo_id FROM tipos_vehiculo WHERE fabricante = 'Mitsubishi' AND linea = 'Mirage'),   2023,  18250, TRUE,  'Disponible'),
    ('HBA-1002', '2HGFE2F59NH512033', (SELECT tipo_id FROM tipos_vehiculo WHERE fabricante = 'Honda'      AND linea = 'Civic'),    2022,  41200, TRUE,  'Rentado'),
    ('HBB-2003', '2T3P1RFV4RW110784', (SELECT tipo_id FROM tipos_vehiculo WHERE fabricante = 'Toyota'     AND linea = 'RAV4'),     2024,   9800, TRUE,  'Disponible'),
    ('HBB-2004', '1N6ED1EJ8MN603217', (SELECT tipo_id FROM tipos_vehiculo WHERE fabricante = 'Nissan'     AND linea = 'Frontier'), 2021,  66500, FALSE, 'Rentado'),
    ('HBC-3005', 'KMJWA37KDNU118650', (SELECT tipo_id FROM tipos_vehiculo WHERE fabricante = 'Hyundai'    AND linea = 'Staria'),   2022,  52300, FALSE, 'Mantenimiento'),
    ('HBC-3006', 'KNDPU3AF2P7204419', (SELECT tipo_id FROM tipos_vehiculo WHERE fabricante = 'Kia'        AND linea = 'Sportage'), 2023,  27450, TRUE,  'Disponible'),
    ('HBD-4007', 'ML32AUHJ1KH890342', (SELECT tipo_id FROM tipos_vehiculo WHERE fabricante = 'Mitsubishi' AND linea = 'Mirage'),   2019, 120400, FALSE, 'Retenido'),
    ('HBD-4008', '1N6AD0EV7HN771026', (SELECT tipo_id FROM tipos_vehiculo WHERE fabricante = 'Nissan'     AND linea = 'Frontier'), 2017, 188000, FALSE, 'Baja'),
    ('HBE-5009', '2HGFE2F51RH600418', (SELECT tipo_id FROM tipos_vehiculo WHERE fabricante = 'Honda'      AND linea = 'Civic'),    2024,   6100, TRUE,  'Disponible'),
    ('HBE-5010', '2T3P1RFV0NW227591', (SELECT tipo_id FROM tipos_vehiculo WHERE fabricante = 'Toyota'     AND linea = 'RAV4'),     2022,  48900, TRUE,  'Disponible');


-- 7. donde esta cada unidad ahorita
-- las rentadas quedan en el centro de donde salieron
INSERT INTO posicion_flota (unidad_id, centro_id, combustible, fecha_modificacion) VALUES
    ((SELECT unidad_id FROM unidades WHERE placa = 'HBA-1001'),
     (SELECT centro_id FROM centros_operacion WHERE nombre_centro = 'Aeropuerto Internacional de Palmerola'),
     'Lleno', '2026-10-06 15:30:00'),
    ((SELECT unidad_id FROM unidades WHERE placa = 'HBA-1002'),
     (SELECT centro_id FROM centros_operacion WHERE nombre_centro = 'FlotaMax Boulevard Morazán'),
     '3/4',   '2026-11-11 14:00:00'),
    ((SELECT unidad_id FROM unidades WHERE placa = 'HBB-2003'),
     (SELECT centro_id FROM centros_operacion WHERE nombre_centro = 'Aeropuerto Internacional de Palmerola'),
     'Lleno', '2026-10-28 20:30:00'),
    ((SELECT unidad_id FROM unidades WHERE placa = 'HBB-2004'),
     (SELECT centro_id FROM centros_operacion WHERE nombre_centro = 'Patio Corporativo Villanueva'),
     'Lleno', '2026-11-09 13:00:00'),
    ((SELECT unidad_id FROM unidades WHERE placa = 'HBC-3005'),
     (SELECT centro_id FROM centros_operacion WHERE nombre_centro = 'Taller FlotaMax Choloma'),
     '1/4',   '2026-11-08 14:45:00'),
    ((SELECT unidad_id FROM unidades WHERE placa = 'HBC-3006'),
     (SELECT centro_id FROM centros_operacion WHERE nombre_centro = 'Aeropuerto Juan Santamaría'),
     '1/2',   '2026-10-25 17:00:00'),
    ((SELECT unidad_id FROM unidades WHERE placa = 'HBD-4007'),
     (SELECT centro_id FROM centros_operacion WHERE nombre_centro = 'Patio Corporativo Villanueva'),
     'Vacío', '2026-09-20 21:00:00'),
    ((SELECT unidad_id FROM unidades WHERE placa = 'HBD-4008'),
     (SELECT centro_id FROM centros_operacion WHERE nombre_centro = 'Patio Corporativo Villanueva'),
     'Vacío', '2026-08-30 16:00:00'),
    ((SELECT unidad_id FROM unidades WHERE placa = 'HBE-5009'),
     (SELECT centro_id FROM centros_operacion WHERE nombre_centro = 'FlotaMax Boulevard Morazán'),
     '1/2',   '2026-11-02 17:30:00'),
    ((SELECT unidad_id FROM unidades WHERE placa = 'HBE-5010'),
     (SELECT centro_id FROM centros_operacion WHERE nombre_centro = 'Managua Carretera a Masaya'),
     '3/4',   '2026-10-15 14:20:00');


-- 8. 7 contratos en total
-- 2 en curso, 1 reservado, 3 cerrados y 1 cancelado

-- K1: en curso, por eso el Civic HBA-1002 esta rentado
INSERT INTO contratos (cliente_id, unidad_id, centro_salida, centro_retorno, fecha_salida, fecha_retorno, estatus, nivel_prioridad)
VALUES ((SELECT cliente_id FROM clientes_flota    WHERE documento = '0801198809876'),
        (SELECT unidad_id  FROM unidades          WHERE placa = 'HBA-1002'),
        (SELECT centro_id  FROM centros_operacion WHERE nombre_centro = 'FlotaMax Boulevard Morazán'),
        (SELECT centro_id  FROM centros_operacion WHERE nombre_centro = 'FlotaMax Boulevard Morazán'),
        '2026-11-11 14:00:00', '2026-11-18 14:00:00', 'En curso', 3);

-- K2: en curso, la Frontier HBB-2004 la tiene una empresa
INSERT INTO contratos (cliente_id, unidad_id, centro_salida, centro_retorno, fecha_salida, fecha_retorno, estatus, nivel_prioridad)
VALUES ((SELECT cliente_id FROM clientes_flota    WHERE documento = '08019015678901'),
        (SELECT unidad_id  FROM unidades          WHERE placa = 'HBB-2004'),
        (SELECT centro_id  FROM centros_operacion WHERE nombre_centro = 'Patio Corporativo Villanueva'),
        (SELECT centro_id  FROM centros_operacion WHERE nombre_centro = 'Aeropuerto Internacional de Palmerola'),
        '2026-11-09 13:00:00', '2026-11-23 23:00:00', 'En curso', 5);

-- K3: reservado para despues, le puse prioridad 4 para probar
INSERT INTO contratos (cliente_id, unidad_id, centro_salida, centro_retorno, fecha_salida, fecha_retorno, estatus, nivel_prioridad)
VALUES ((SELECT cliente_id FROM clientes_flota    WHERE documento = '678912345'),
        (SELECT unidad_id  FROM unidades          WHERE placa = 'HBC-3006'),
        (SELECT centro_id  FROM centros_operacion WHERE nombre_centro = 'Aeropuerto Juan Santamaría'),
        (SELECT centro_id  FROM centros_operacion WHERE nombre_centro = 'Aeropuerto Juan Santamaría'),
        '2026-11-26 16:00:00', '2026-12-01 16:00:00', 'Reservado', 4);

-- K4: cerrado, Mirage 4 dias (tiene factura)
INSERT INTO contratos (cliente_id, unidad_id, centro_salida, centro_retorno, fecha_salida, fecha_retorno, estatus, nivel_prioridad)
VALUES ((SELECT cliente_id FROM clientes_flota    WHERE documento = '0318199200456'),
        (SELECT unidad_id  FROM unidades          WHERE placa = 'HBA-1001'),
        (SELECT centro_id  FROM centros_operacion WHERE nombre_centro = 'Aeropuerto Internacional de Palmerola'),
        (SELECT centro_id  FROM centros_operacion WHERE nombre_centro = 'Aeropuerto Internacional de Palmerola'),
        '2026-10-02 15:00:00', '2026-10-06 15:00:00', 'Cerrado', 2);

-- K5: cerrado, la RAV4 sale de Costa Rica y la devuelven en Managua
INSERT INTO contratos (cliente_id, unidad_id, centro_salida, centro_retorno, fecha_salida, fecha_retorno, estatus, nivel_prioridad)
VALUES ((SELECT cliente_id FROM clientes_flota    WHERE documento = 'CR1122334'),
        (SELECT unidad_id  FROM unidades          WHERE placa = 'HBE-5010'),
        (SELECT centro_id  FROM centros_operacion WHERE nombre_centro = 'Aeropuerto Juan Santamaría'),
        (SELECT centro_id  FROM centros_operacion WHERE nombre_centro = 'Managua Carretera a Masaya'),
        '2026-10-10 14:00:00', '2026-10-15 14:00:00', 'Cerrado', 3);

-- K6: cerrado, Civic 10 dias (despues lo movieron a Tegucigalpa)
INSERT INTO contratos (cliente_id, unidad_id, centro_salida, centro_retorno, fecha_salida, fecha_retorno, estatus, nivel_prioridad)
VALUES ((SELECT cliente_id FROM clientes_flota    WHERE documento = '08019120004455'),
        (SELECT unidad_id  FROM unidades          WHERE placa = 'HBE-5009'),
        (SELECT centro_id  FROM centros_operacion WHERE nombre_centro = 'Aeropuerto Internacional de Palmerola'),
        (SELECT centro_id  FROM centros_operacion WHERE nombre_centro = 'Aeropuerto Internacional de Palmerola'),
        '2026-10-20 12:00:00', '2026-10-30 12:00:00', 'Cerrado', 5);

-- K7: cancelado, sale 4-nov 02:00 UTC que en Honduras es 3-nov 20:00
INSERT INTO contratos (cliente_id, unidad_id, centro_salida, centro_retorno, fecha_salida, fecha_retorno, estatus, nivel_prioridad)
VALUES ((SELECT cliente_id FROM clientes_flota    WHERE documento = 'N00987654'),
        (SELECT unidad_id  FROM unidades          WHERE placa = 'HBB-2003'),
        (SELECT centro_id  FROM centros_operacion WHERE nombre_centro = 'Aeropuerto Internacional de Palmerola'),
        (SELECT centro_id  FROM centros_operacion WHERE nombre_centro = 'Aeropuerto Internacional de Palmerola'),
        '2026-11-04 02:00:00', '2026-11-07 02:00:00', 'Cancelado', 1);


-- 9. facturas (solo de los contratos cerrados)
-- K4: 160 + 48 = 208, ISV 31.20, total 239.20
-- K5: 425 + 32.50 + 15 (sin ISV) = 472.50, ISV 68.63, total 541.13
-- K6: 585 + 120 + 135 = 840, ISV 126, total 966
INSERT INTO facturas (contrato_id, fecha, subtotal_usd, impuesto_usd, monto_total_usd, comentarios)
VALUES ((SELECT c.contrato_id FROM contratos c JOIN unidades u ON u.unidad_id = c.unidad_id
          WHERE u.placa = 'HBA-1001' AND c.fecha_salida = '2026-10-02 15:00:00'),
        '2026-10-06 15:40:00', 208.00, 31.20, 239.20,
        'Renta Mirage 4 días con seguro premium. Pago con tarjeta corporativa.');

INSERT INTO facturas (contrato_id, fecha, subtotal_usd, impuesto_usd, monto_total_usd, comentarios)
VALUES ((SELECT c.contrato_id FROM contratos c JOIN unidades u ON u.unidad_id = c.unidad_id
          WHERE u.placa = 'HBE-5010' AND c.fecha_salida = '2026-10-10 14:00:00'),
        '2026-10-15 14:30:00', 472.50, 68.63, 541.13,
        'Renta RAV4 5 días con Wi-Fi. Devuelto en Managua. Entrega exenta de ISV.');

INSERT INTO facturas (contrato_id, fecha, subtotal_usd, impuesto_usd, monto_total_usd, comentarios)
VALUES ((SELECT c.contrato_id FROM contratos c JOIN unidades u ON u.unidad_id = c.unidad_id
          WHERE u.placa = 'HBE-5009' AND c.fecha_salida = '2026-10-20 12:00:00'),
        '2026-10-30 13:15:00', 840.00, 126.00, 966.00,
        'Contrato corporativo de 10 días con seguro premium y chofer bilingüe por 3 días para visita de obra. Facturar a la cuenta 4410 del cliente y enviar copia al área de compras antes del día cinco del mes');


-- 10. lineas de cada factura
-- factura de K4
INSERT INTO factura_extras (factura_id, extra_id, dias, subtotal_usd, incluye_impuesto) VALUES
    ((SELECT f.factura_id FROM facturas f JOIN contratos c ON c.contrato_id = f.contrato_id JOIN unidades u ON u.unidad_id = c.unidad_id
       WHERE u.placa = 'HBA-1001' AND c.fecha_salida = '2026-10-02 15:00:00'),
     (SELECT extra_id FROM extras WHERE categoria = 'Renta'), 4, 160.00, TRUE),
    ((SELECT f.factura_id FROM facturas f JOIN contratos c ON c.contrato_id = f.contrato_id JOIN unidades u ON u.unidad_id = c.unidad_id
       WHERE u.placa = 'HBA-1001' AND c.fecha_salida = '2026-10-02 15:00:00'),
     (SELECT extra_id FROM extras WHERE categoria = 'Seguro'), 4, 48.00, TRUE);

-- factura de K5
INSERT INTO factura_extras (factura_id, extra_id, dias, subtotal_usd, incluye_impuesto) VALUES
    ((SELECT f.factura_id FROM facturas f JOIN contratos c ON c.contrato_id = f.contrato_id JOIN unidades u ON u.unidad_id = c.unidad_id
       WHERE u.placa = 'HBE-5010' AND c.fecha_salida = '2026-10-10 14:00:00'),
     (SELECT extra_id FROM extras WHERE categoria = 'Renta'), 5, 425.00, TRUE),
    ((SELECT f.factura_id FROM facturas f JOIN contratos c ON c.contrato_id = f.contrato_id JOIN unidades u ON u.unidad_id = c.unidad_id
       WHERE u.placa = 'HBE-5010' AND c.fecha_salida = '2026-10-10 14:00:00'),
     (SELECT extra_id FROM extras WHERE detalle = 'Wi-Fi portátil 4G'), 5, 32.50, TRUE),
    ((SELECT f.factura_id FROM facturas f JOIN contratos c ON c.contrato_id = f.contrato_id JOIN unidades u ON u.unidad_id = c.unidad_id
       WHERE u.placa = 'HBE-5010' AND c.fecha_salida = '2026-10-10 14:00:00'),
     (SELECT extra_id FROM extras WHERE categoria = 'Entrega'), 1, 15.00, FALSE);

-- factura de K6
INSERT INTO factura_extras (factura_id, extra_id, dias, subtotal_usd, incluye_impuesto) VALUES
    ((SELECT f.factura_id FROM facturas f JOIN contratos c ON c.contrato_id = f.contrato_id JOIN unidades u ON u.unidad_id = c.unidad_id
       WHERE u.placa = 'HBE-5009' AND c.fecha_salida = '2026-10-20 12:00:00'),
     (SELECT extra_id FROM extras WHERE categoria = 'Renta'), 10, 585.00, TRUE),
    ((SELECT f.factura_id FROM facturas f JOIN contratos c ON c.contrato_id = f.contrato_id JOIN unidades u ON u.unidad_id = c.unidad_id
       WHERE u.placa = 'HBE-5009' AND c.fecha_salida = '2026-10-20 12:00:00'),
     (SELECT extra_id FROM extras WHERE categoria = 'Seguro'), 10, 120.00, TRUE),
    ((SELECT f.factura_id FROM facturas f JOIN contratos c ON c.contrato_id = f.contrato_id JOIN unidades u ON u.unidad_id = c.unidad_id
       WHERE u.placa = 'HBE-5009' AND c.fecha_salida = '2026-10-20 12:00:00'),
     (SELECT extra_id FROM extras WHERE categoria = 'Chofer'), 3, 135.00, TRUE);


-- 11. movimientos (el destino es donde quedo cada unidad en el inciso 7)

-- Mirage de Tegucigalpa al patio
INSERT INTO movimientos_flota (unidad_id, centro_origen, centro_destino, km_recorridos, motivo, fecha_movimiento)
VALUES ((SELECT unidad_id FROM unidades WHERE placa = 'HBD-4007'),
        (SELECT centro_id FROM centros_operacion WHERE nombre_centro = 'FlotaMax Boulevard Morazán'),
        (SELECT centro_id FROM centros_operacion WHERE nombre_centro = 'Patio Corporativo Villanueva'),
        230, 'Rebalanceo', '2026-09-20 15:00:00');

-- RAV4 regresa del patio a Palmerola
INSERT INTO movimientos_flota (unidad_id, centro_origen, centro_destino, km_recorridos, motivo, fecha_movimiento)
VALUES ((SELECT unidad_id FROM unidades WHERE placa = 'HBB-2003'),
        (SELECT centro_id FROM centros_operacion WHERE nombre_centro = 'Patio Corporativo Villanueva'),
        (SELECT centro_id FROM centros_operacion WHERE nombre_centro = 'Aeropuerto Internacional de Palmerola'),
        160, 'Devolución', '2026-10-28 18:00:00');

-- Civic de Palmerola a Tegucigalpa
INSERT INTO movimientos_flota (unidad_id, centro_origen, centro_destino, km_recorridos, motivo, fecha_movimiento)
VALUES ((SELECT unidad_id FROM unidades WHERE placa = 'HBE-5009'),
        (SELECT centro_id FROM centros_operacion WHERE nombre_centro = 'Aeropuerto Internacional de Palmerola'),
        (SELECT centro_id FROM centros_operacion WHERE nombre_centro = 'FlotaMax Boulevard Morazán'),
        82, 'Rebalanceo', '2026-11-02 15:00:00');

-- Staria del patio al taller (por eso esta en mantenimiento)
INSERT INTO movimientos_flota (unidad_id, centro_origen, centro_destino, km_recorridos, motivo, fecha_movimiento)
VALUES ((SELECT unidad_id FROM unidades WHERE placa = 'HBC-3005'),
        (SELECT centro_id FROM centros_operacion WHERE nombre_centro = 'Patio Corporativo Villanueva'),
        (SELECT centro_id FROM centros_operacion WHERE nombre_centro = 'Taller FlotaMax Choloma'),
        25, 'Mantenimiento', '2026-11-08 14:00:00');

COMMIT;