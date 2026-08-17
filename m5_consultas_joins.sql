
-- PASO 0: Crear la base de datos

CREATE DATABASE Ventas_Tech_DB;
GO
USE Ventas_Tech_DB;
GO


-- PASO 1: DROP TABLES (orden inverso de dependencias)
-- -------------------------------------------------------------------
-- ventas depende de clientes y productos -> se elimina primero.
-- productos depende de categorias -> se elimina antes que categorias.
-- clientes y categorias no tienen dependencias -> se eliminan al final.

DROP TABLE IF EXISTS ventas;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS clientes;
DROP TABLE IF EXISTS categorias;

-- PASO 2: CREATE TABLES

-- Tabla sin dependencias
CREATE TABLE categorias (
    id_categoria      INT PRIMARY KEY,
    nombre_categoria  VARCHAR(50) NOT NULL,
    descripcion       VARCHAR(200)
);
GO

-- Tabla sin dependencias
CREATE TABLE clientes (
    id_cliente      INT PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL,
    email           VARCHAR(100) UNIQUE,
    ciudad          VARCHAR(50),
    fecha_registro  DATE NOT NULL
);
GO

-- Depende de categorias
CREATE TABLE productos (
    id_producto      INT PRIMARY KEY,
    nombre_producto  VARCHAR(100) NOT NULL,
    id_categoria     INT,
    precio           DECIMAL(10,2) NOT NULL,
    stock            INT DEFAULT 0,
    activo           SMALLINT DEFAULT 1,   -- 1 = activo, 0 = inactivo                                       
        FOREIGN KEY (id_categoria) REFERENCES categorias(id_categoria)
);
GO

-- Depende de clientes y productos
CREATE TABLE ventas (
    id_venta         INT PRIMARY KEY,
    id_cliente       INT,
    id_producto      INT,
    cantidad         INT NOT NULL,
    precio_unitario  DECIMAL(10,2) NOT NULL,
    fecha_venta      DATE NOT NULL,
        FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente),
        FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
);
GO

-- -------------------------------------------------------------------
-- PASO 3: INSERT DATA (primero las tablas sin dependencias)
-- -------------------------------------------------------------------

-- categorias — 4 registros
INSERT INTO categorias (id_categoria, nombre_categoria, descripcion) VALUES
(1, 'Computación',    'Laptops, PCs y monitores'),
(2, 'Accesorios',     'Periféricos y complementos'),
(3, 'Audio',          'Auriculares y parlantes'),
(4, 'Almacenamiento', 'Discos y memorias');
GO

-- clientes — 5 registros
INSERT INTO clientes (id_cliente, nombre, email, ciudad, fecha_registro) VALUES
(1, 'María López',  'maria@mail.com',  'Buenos Aires', '2024-01-05'),
(2, 'Carlos Ruiz',  'carlos@mail.com', 'Córdoba',      '2024-01-10'),
(3, 'Ana Gómez',    'ana@mail.com',    'Rosario',      '2024-02-01'),
(4, 'Pedro Sanz',   'pedro@mail.com',  'Mendoza',      '2024-02-15'),
(5, 'Laura Torres', 'laura@mail.com',  'Tucumán',      '2024-03-01');
GO

-- productos — 6 registros
INSERT INTO productos (id_producto, nombre_producto, id_categoria, precio, stock, activo) VALUES
(1, 'Laptop Pro 15',      1, 1200.00, 15, 1),
(2, 'Mouse Inalámbrico',  2,   28.00, 80, 1),
(3, 'Monitor 4K 27"',     1,  450.00, 12, 1),
(4, 'Auriculares BT Pro', 3,  120.00, 35, 1),
(5, 'SSD Externo 1TB',    4,  130.00, 18, 1),
(6, 'Teclado Mecánico',   2,   95.00, 40, 1);
GO

-- ventas — 10 registros
INSERT INTO ventas (id_venta, id_cliente, id_producto, cantidad, precio_unitario, fecha_venta) VALUES
(1,  1, 1, 2, 1200.00, '2024-03-05'),
(2,  2, 2, 5,   28.00, '2024-03-06'),
(3,  3, 3, 1,  450.00, '2024-03-07'),
(4,  1, 4, 2,  120.00, '2024-03-08'),
(5,  4, 5, 3,  130.00, '2024-03-10'),
(6,  2, 6, 4,   95.00, '2024-03-11'),
(7,  5, 1, 1, 1200.00, '2024-03-12'),
(8,  3, 2, 8,   28.00, '2024-03-13'),
(9,  4, 4, 1,  120.00, '2024-03-14'),
(10, 5, 3, 2,  450.00, '2024-03-15');
GO

CREATE TABLE territorios (
    id_territorio          INT PRIMARY KEY,
    region                 VARCHAR(50) NOT NULL,
    pais                   VARCHAR(50) NOT NULL,
    zona                   VARCHAR(50),
    responsable_comercial  VARCHAR(150)
);
GO

INSERT INTO territorios (id_territorio, region, pais, zona, responsable_comercial) VALUES
(1, 'AMBA',   'Argentina', 'Zona Metropolitana',  'Lucía Fernández'),
(2, 'Centro', 'Argentina', 'Córdoba / Rosario',   'Martín Suárez'),
(3, 'Cuyo',   'Argentina', 'Mendoza',             'Sofía Andrada'),
(4, 'NOA',    'Argentina', 'Tucumán',             'Diego Paz');
GO

ALTER TABLE clientes ADD segmento VARCHAR(20) NULL;
GO

ALTER TABLE clientes ADD id_territorio INT NULL;
GO

ALTER TABLE clientes
    ADD CONSTRAINT fk_clientes_territorio
    FOREIGN KEY (id_territorio) REFERENCES territorios(id_territorio);
GO

UPDATE clientes
SET
    id_territorio = CASE id_cliente
        WHEN 1 THEN 1   -- María López   - Buenos Aires -> AMBA
        WHEN 2 THEN 2   -- Carlos Ruiz   - Córdoba      -> Centro
        WHEN 3 THEN 2   -- Ana Gómez     - Rosario      -> Centro
        WHEN 4 THEN 3   -- Pedro Sanz    - Mendoza      -> Cuyo
        WHEN 5 THEN 4   -- Laura Torres  - Tucumán      -> NOA
    END,
    segmento = CASE id_cliente
        WHEN 1 THEN 'mayorista'
        WHEN 2 THEN 'minorista'
        WHEN 3 THEN 'minorista'
        WHEN 4 THEN 'corporativo'
        WHEN 5 THEN 'mayorista'
    END;
GO

ALTER TABLE ventas ADD canal VARCHAR(30) NULL;
GO

-- Split de ejemplo: ventas con id_venta impar -> Online, par -> Presencial
UPDATE ventas
SET canal = CASE WHEN id_venta % 2 = 0 THEN 'Presencial' ELSE 'Online' END;
GO

SELECT * FROM territorios;
SELECT id_cliente, nombre, ciudad, segmento, id_territorio FROM clientes;
SELECT id_venta, id_cliente, id_producto, canal FROM ventas;

-- Clientes registrados que todavía no compraron nada
INSERT INTO clientes (id_cliente, nombre, email, ciudad, fecha_registro, segmento, id_territorio)
VALUES (7, 'Diego Herrera', 'diego.herrera@mail.com', 'Rosario', '2024-04-10', 'corporativo', 2);

INSERT INTO clientes (id_cliente, nombre, email, ciudad, fecha_registro, segmento, id_territorio)
VALUES (8, 'Valentina Castro', 'valentina.castro@mail.com', 'Mendoza', '2024-04-18', 'minorista', 3);

INSERT INTO clientes (id_cliente, nombre, email, ciudad, fecha_registro, segmento, id_territorio)
VALUES (9, 'Nicolás Ferreyra', 'nicolas.ferreyra@mail.com', 'Tucumán', '2024-05-02', 'mayorista', 4);

-- Productos del catálogo que todavía no se vendieron
INSERT INTO productos (id_producto, nombre_producto, id_categoria, precio, stock, activo)
VALUES (8, 'Parlante Bluetooth', 3, 60.00, 22, 1);

INSERT INTO productos (id_producto, nombre_producto, id_categoria, precio, stock, activo)
VALUES (9, 'Pendrive 64GB', 4, 15.00, 50, 1);

-- PASO 4: VERIFICACIÓN DE INTEGRIDAD

SELECT * FROM categorias;
SELECT * FROM clientes;
SELECT * FROM productos;
SELECT * FROM ventas;
SELECT * FROM territorios;

-- =============================================================================
-- MÓDULO 4: CONSULTAS DE NEGOCIO EN VENTAS_TECH_DB
-- Archivo: m4_consultas_negocio.sql
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Consulta 1: Resumen ejecutivo mensual
-- Total facturado, cantidad de pedidos y ticket promedio por mes
-- -----------------------------------------------------------------------------
SELECT 
    MONTH(fecha_venta) AS mes,
    SUM(cantidad * precio_unitario) AS total_facturado,
    COUNT(*) AS cantidad_pedidos,
    ROUND(AVG(cantidad * precio_unitario), 2) AS ticket_promedio
FROM ventas
GROUP BY MONTH(fecha_venta)
ORDER BY mes ASC;
GO

-- -----------------------------------------------------------------------------
-- Consulta 2: Ranking de productos
-- Top 5 de productos por total facturado y unidades vendidas
-- -----------------------------------------------------------------------------
SELECT TOP 5
    id_producto,
    SUM(cantidad) AS unidades_vendidas,
    SUM(cantidad * precio_unitario) AS total_generado
FROM ventas
GROUP BY id_producto
ORDER BY total_generado DESC;
GO


-- -----------------------------------------------------------------------------
-- Consulta 3: Clientes recurrentes
-- Clientes con más de un pedido, su recurrencia y gasto acumulado
-- -----------------------------------------------------------------------------
SELECT id_cliente,
    COUNT(*) AS cantidad_pedidos,
    SUM(cantidad * precio_unitario) AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY total_gastado DESC;
GO


-- -----------------------------------------------------------------------------
-- Consulta 4: Meses por encima / por debajo del promedio
-- Compara el total mensual contra el promedio mensual general del período
-- -----------------------------------------------------------------------------

DECLARE @promedio_general DECIMAL(18,2);
WITH venta_mensual AS (
    SELECT 
        MONTH(fecha_venta) AS mes,
        SUM(cantidad * precio_unitario) AS total_facturado
    FROM ventas
    GROUP BY MONTH(fecha_venta)
)
SELECT @promedio_general = AVG(total_facturado)
FROM venta_mensual;
WITH venta_mensual AS (
    SELECT 
        MONTH(fecha_venta) AS mes,
        SUM(cantidad * precio_unitario) AS total_facturado
    FROM ventas
    GROUP BY MONTH(fecha_venta)
)
SELECT 
    mes,
    total_facturado,
    CASE 
        WHEN total_facturado >= @promedio_general THEN 'Por encima'
        ELSE 'Por debajo'
    END AS relacion_promedio
FROM venta_mensual
ORDER BY mes ASC;

-- =============================================================================
-- BLOQUE DE CIERRE — HALLAZGOS CLAVE DEL NEGOCIO
-- =============================================================================
-- 1. Concentración de Ingresos en pocos productos: Laptop Pro 15 (id_producto 1) y Monitor 4K 27" (id_producto 3)
-- generan la mayor parte de los ingresos. Ambos representan productos de alto valor.
-- 2. Baja tasa de recurrencia de clientes: Solo 3 de 5 clientes tienen mas de una compra.
-- 3. Productos de bajo valor tienen alto volumen: Mouse ($28) y Teclado ($95) se venden en cantidad
-- Son buenos complementos de venta cruzada con productos premium


-- MODULO 5
-- CONSULTA 1 — Vista base del proyecto (INNER JOIN)

SELECT
    v.fecha_venta                          AS fecha,
    c.nombre                               AS nombre_cliente,
    c.segmento                             AS segmento,
    t.region                               AS region,
    p.nombre_producto                      AS nombre_producto,
    cat.nombre_categoria                   AS categoria,
    v.cantidad                             AS cantidad,
    v.precio_unitario                      AS precio_unitario,
    (v.cantidad * v.precio_unitario)       AS total_venta,
    v.canal                                AS canal
FROM ventas v
INNER JOIN clientes c     ON v.id_cliente   = c.id_cliente
INNER JOIN productos p    ON v.id_producto  = p.id_producto
INNER JOIN categorias cat ON p.id_categoria = cat.id_categoria
INNER JOIN territorios t  ON c.id_territorio = t.id_territorio
ORDER BY v.fecha_venta;
GO

-- CONSULTA 2 — Clientes sin ventas (LEFT JOIN)
-- Clientes registrados que todavía no compraron nada.

SELECT
    c.nombre,
    c.email,
    c.fecha_registro
FROM clientes c
LEFT JOIN ventas v ON c.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL;
GO

-- CONSULTA 3 — Productos sin ventas (LEFT JOIN)
-- Productos del catálogo que nunca se vendieron.

SELECT
    p.nombre_producto,
    cat.nombre_categoria AS categoria,
    p.precio
FROM productos p
INNER JOIN categorias cat ON p.id_categoria = cat.id_categoria
LEFT JOIN ventas v ON p.id_producto = v.id_producto
WHERE v.id_venta IS NULL;
GO

-- CONSULTA 4 — Consolidado por canal (UNION ALL)
-- Une el detalle de ventas Online y Presencial en un solo resultado,
-- y después agrega el total facturado por canal.

WITH ventas_por_canal AS (
    SELECT
        v.id_venta,
        v.cantidad,
        v.precio_unitario,
        (v.cantidad * v.precio_unitario) AS total_venta,
        'Online' AS canal
    FROM ventas v
    WHERE v.canal = 'Online'

    UNION ALL

    SELECT
        v.id_venta,
        v.cantidad,
        v.precio_unitario,
        (v.cantidad * v.precio_unitario) AS total_venta,
        'Presencial' AS canal
    FROM ventas v
    WHERE v.canal = 'Presencial'
)
SELECT
    canal,
    COUNT(*)          AS cantidad_ventas,
    SUM(total_venta)  AS total_facturado
FROM ventas_por_canal
GROUP BY canal
ORDER BY canal;
GO
