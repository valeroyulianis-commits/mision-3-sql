-- =====================================================================
-- MISIÓN 3 · Los datos tienen que vivir en algún sitio: SQL
-- Equipo: Yulianis Valero y Yuleimis Valero
-- Base de datos: ai_customer (MySQL 8.4)
-- Antes de este script: ejecutar 01_creacion.sql y 02_datos.sql
-- =====================================================================
USE ai_customer;

-- =====================================================================
-- RETO 1 · Estructura, claves y recuentos
-- =====================================================================

-- 1.1 Tablas que existen en la base de datos
SHOW TABLES;

-- 1.2 Estructura de cada tabla: columnas, tipos, NULL y claves (PRI / MUL)
DESCRIBE clientes;
DESCRIBE operaciones;

-- 1.3 Claves primarias y foráneas definidas en el esquema
SELECT TABLE_NAME, CONSTRAINT_NAME, COLUMN_NAME,
       REFERENCED_TABLE_NAME, REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'ai_customer'
ORDER BY TABLE_NAME, CONSTRAINT_NAME;

-- 1.4 Recuento de filas de cada tabla (esperado: 30 clientes y 99 operaciones)
SELECT 'clientes' AS tabla, COUNT(*) AS filas FROM clientes
UNION ALL
SELECT 'operaciones', COUNT(*) FROM operaciones;

-- 1.5 Relación 1:N: cuántas operaciones tiene cada cliente.
-- Un cliente puede tener 0, 1 o varias operaciones, pero cada
-- operación pertenece a un único cliente (id_cliente en operaciones).
SELECT id_cliente, COUNT(*) AS num_operaciones
FROM operaciones
GROUP BY id_cliente
ORDER BY num_operaciones DESC;

-- 1.6 Prueba de la clave foránea: insertar una operación de un cliente
-- que no existe (id 999). MySQL la RECHAZA con el error 1452
-- (Cannot add or update a child row: a foreign key constraint fails).
-- La dejamos comentada para que el script se ejecute completo;
-- se ejecuta aparte para la captura del error.
-- INSERT INTO operaciones VALUES (999, 999, '2026-09-01', 50.00, 'web');

-- =====================================================================
-- RETO 2 · SELECT, WHERE y ORDER BY
-- =====================================================================

-- 2.1 Clientes de Madrid (esperado: 5 filas)
SELECT * FROM clientes
WHERE ciudad = 'Madrid';

-- 2.2 Clientes con antigüedad inferior a 6 meses (esperado: 5 filas)
SELECT * FROM clientes
WHERE antiguedad_meses < 6;

-- 2.3 Todos los clientes ordenados de mayor a menor antigüedad
SELECT id_cliente, nombre, ciudad, antiguedad_meses
FROM clientes
ORDER BY antiguedad_meses DESC;

-- 2.4 Clientes que han abandonado (abandono = 1) (esperado: 9 filas)
SELECT * FROM clientes
WHERE abandono = 1;

-- WHERE filtra: decide QUÉ filas aparecen (reduce el número de filas).
-- ORDER BY ordena: decide EN QUÉ ORDEN aparecen (no quita ninguna fila).

-- =====================================================================
-- RETO 3 · JOIN
-- =====================================================================

-- 3.1 Operaciones con el nombre de su cliente (INNER JOIN, esperado: 99 filas)
SELECT o.id_operacion, o.fecha, o.importe, o.canal,
       c.id_cliente, c.nombre
FROM operaciones o
INNER JOIN clientes c ON o.id_cliente = c.id_cliente
ORDER BY o.id_operacion;

-- 3.2 Clientes sin operaciones (LEFT JOIN + IS NULL, esperado: 4 filas)
SELECT c.id_cliente, c.nombre, c.ciudad
FROM clientes c
LEFT JOIN operaciones o ON c.id_cliente = o.id_cliente
WHERE o.id_operacion IS NULL;

-- 3.3 Operaciones con importe superior a 200 (esperado: 37 filas)
SELECT o.id_operacion, c.nombre, o.fecha, o.importe, o.canal
FROM operaciones o
INNER JOIN clientes c ON o.id_cliente = c.id_cliente
WHERE o.importe > 200
ORDER BY o.importe DESC;

-- 3.4 Operaciones de un cliente concreto: Cliente 03 (esperado: 6 filas)
SELECT o.id_operacion, c.nombre, o.fecha, o.importe, o.canal
FROM operaciones o
INNER JOIN clientes c ON o.id_cliente = c.id_cliente
WHERE c.id_cliente = 3
ORDER BY o.fecha;

-- INNER JOIN solo devuelve las filas que tienen pareja en las dos tablas.
-- LEFT JOIN devuelve TODOS los clientes, y si no tienen operaciones
-- las columnas de operaciones salen en NULL.

-- =====================================================================
-- RETO 4 · Agregaciones: COUNT, SUM, AVG, GROUP BY y HAVING
-- =====================================================================

-- 4.1 Gasto total por cliente (solo clientes con operaciones: 26 filas)
SELECT c.id_cliente, c.nombre, SUM(o.importe) AS gasto_total
FROM clientes c
INNER JOIN operaciones o ON c.id_cliente = o.id_cliente
GROUP BY c.id_cliente, c.nombre
ORDER BY gasto_total DESC;

-- 4.2 Número de operaciones por canal (app, tienda, web)
SELECT canal, COUNT(*) AS num_operaciones, SUM(importe) AS importe_total
FROM operaciones
GROUP BY canal
ORDER BY num_operaciones DESC;

-- 4.3 Ticket medio: global y por cliente
SELECT ROUND(AVG(importe), 2) AS ticket_medio_global
FROM operaciones;

SELECT c.id_cliente, c.nombre, ROUND(AVG(o.importe), 2) AS ticket_medio
FROM clientes c
INNER JOIN operaciones o ON c.id_cliente = o.id_cliente
GROUP BY c.id_cliente, c.nombre
ORDER BY ticket_medio DESC;

-- 4.4 Clientes con gasto total superior a 500 (HAVING) (esperado: 16 filas)
SELECT c.id_cliente, c.nombre, SUM(o.importe) AS gasto_total
FROM clientes c
INNER JOIN operaciones o ON c.id_cliente = o.id_cliente
GROUP BY c.id_cliente, c.nombre
HAVING SUM(o.importe) > 500
ORDER BY gasto_total DESC;

-- WHERE filtra filas ANTES de agrupar (no puede usar SUM, COUNT...).
-- HAVING filtra grupos DESPUÉS de agrupar (sí puede usar SUM, COUNT...).
-- Ejemplo combinado: gasto > 500 contando solo operaciones de la app.
SELECT id_cliente, SUM(importe) AS gasto_app
FROM operaciones
WHERE canal = 'app'
GROUP BY id_cliente
HAVING SUM(importe) > 500;

-- =====================================================================
-- RETO FINAL · Dataset para el modelo de abandono (una fila por cliente)
-- (misma consulta que 04_dataset_ia.sql)
-- =====================================================================
SELECT c.id_cliente,
       c.antiguedad_meses,
       COUNT(o.id_operacion)           AS num_operaciones,
       COALESCE(SUM(o.importe), 0)     AS gasto_total,
       COALESCE(AVG(o.importe), 0)     AS ticket_medio,
       c.abandono
FROM clientes c
LEFT JOIN operaciones o ON c.id_cliente = o.id_cliente
GROUP BY c.id_cliente, c.antiguedad_meses, c.abandono
ORDER BY c.id_cliente;

-- Validación 1: número de filas del dataset (esperado: 30)
SELECT COUNT(*) AS filas_dataset
FROM (
  SELECT c.id_cliente
  FROM clientes c
  LEFT JOIN operaciones o ON c.id_cliente = o.id_cliente
  GROUP BY c.id_cliente
) AS d;

-- Validación 2: ausencia de duplicados (esperado: filas = clientes_distintos = 30)
SELECT COUNT(*) AS filas, COUNT(DISTINCT id_cliente) AS clientes_distintos
FROM (
  SELECT c.id_cliente
  FROM clientes c
  LEFT JOIN operaciones o ON c.id_cliente = o.id_cliente
  GROUP BY c.id_cliente
) AS d;

-- Validación 3: ningún nulo en las variables (esperado: 0 nulos;
-- los 4 clientes sin operaciones aparecen con 0, no con NULL)
SELECT SUM(gasto_total IS NULL)  AS nulos_gasto,
       SUM(ticket_medio IS NULL) AS nulos_ticket,
       SUM(num_operaciones = 0)  AS clientes_sin_operaciones
FROM (
  SELECT c.id_cliente,
         COUNT(o.id_operacion)       AS num_operaciones,
         COALESCE(SUM(o.importe), 0) AS gasto_total,
         COALESCE(AVG(o.importe), 0) AS ticket_medio
  FROM clientes c
  LEFT JOIN operaciones o ON c.id_cliente = o.id_cliente
  GROUP BY c.id_cliente
) AS d;
