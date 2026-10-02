-- Proyecto Capstone - Análisis de ventas
-- estructura.sql: tablas y carga de datos
-- Julián Sfoggia
--
-- Antes de correr esto hay que crear la base y conectarse a ella:
--   CREATE DATABASE capstone_project;
-- (va aparte porque pgAdmin no deja ejecutar CREATE DATABASE junto con
-- el resto del script)


-- Borro todo primero para poder correr el script de nuevo sin que
-- choquen los datos. Va en este orden porque la vista y ventas dependen
-- de las otras tablas.
DROP VIEW IF EXISTS ventas_limpias;
DROP TABLE IF EXISTS ventas;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS clientes;

CREATE TABLE clientes (
    cliente_id     SERIAL PRIMARY KEY,
    nombre         VARCHAR(100) NOT NULL,
    email          VARCHAR(100) NOT NULL UNIQUE,  -- para no cargar dos veces al mismo cliente
    edad           INT          NOT NULL CHECK (edad >= 18),
    fecha_registro DATE         NOT NULL
);

CREATE TABLE productos (
    producto_id SERIAL PRIMARY KEY,
    nombre      VARCHAR(100)  NOT NULL,
    categoria   VARCHAR(50)   NOT NULL,
    precio      NUMERIC(10,2) NOT NULL CHECK (precio > 0),  -- NUMERIC y no FLOAT, para no tener errores de redondeo con plata
    stock       INT           NOT NULL CHECK (stock >= 0)
);

CREATE TABLE ventas (
    venta_id        SERIAL PRIMARY KEY,
    cliente_id      INT  NOT NULL REFERENCES clientes(cliente_id),
    producto_id     INT  NOT NULL REFERENCES productos(producto_id),
    cantidad        INT  NOT NULL CHECK (cantidad > 0),
    fecha_venta     DATE NOT NULL,
    -- Lo que se cobró realmente (puede tener descuento). La dejo sin
    -- NOT NULL para simular ventas cargadas sin precio; en el análisis
    -- se completan con el precio de lista.
    precio_unitario NUMERIC(10,2) CHECK (precio_unitario > 0)
);


INSERT INTO clientes (nombre, email, edad, fecha_registro) VALUES
('Juan Pérez',        'juan@email.com',      28, '2026-01-05'),
('María Gómez',       'maria@email.com',     35, '2026-01-10'),
('Carlos Díaz',       'carlos@email.com',    42, '2026-02-02'),
('Ana López',         'ana@email.com',       24, '2026-02-15'),
('Lucía Torres',      'lucia@email.com',     31, '2026-03-01'),
('Martín Fernández',  'martin@email.com',    39, '2026-01-08'),
('Sofía Ramírez',     'sofia@email.com',     27, '2026-01-12'),
('Diego Herrera',     'diego@email.com',     45, '2026-01-20'),
('Valentina Castro',  'valentina@email.com', 22, '2026-02-03'),
('Gonzalo Molina',    'gonzalo@email.com',   33, '2026-02-11'),
('Camila Rojas',      'camila@email.com',    29, '2026-02-25'),
('Nicolás Suárez',    'nicolas@email.com',   51, '2026-03-06'),
('Julieta Benítez',   'julieta@email.com',   26, '2026-03-14'),
('Tomás Acosta',      'tomas@email.com',     37, '2026-04-02'),
('Florencia Medina',  'florencia@email.com', 30, '2026-04-18'),
('Agustín Romero',    'agustin@email.com',   48, '2026-05-03');

INSERT INTO productos (nombre, categoria, precio, stock) VALUES
('Notebook Lenovo',           'Tecnología',  950000, 10),
('Mouse Logitech',            'Tecnología',   25000, 50),
('Silla Gamer',               'Muebles',     180000,  8),
('Monitor Samsung',           'Tecnología',  420000, 15),
('Escritorio',                'Muebles',     210000,  6),
('Teclado Mecánico Redragon', 'Tecnología',   65000, 30),
('Auriculares HyperX',        'Tecnología',   85000, 25),
('Biblioteca Modular',        'Muebles',     150000,  5),
('Lámpara LED de Escritorio', 'Iluminación',  35000, 40),
('Webcam Logitech',           'Tecnología',   70000, 20),
('Apoyapiés Ergonómico',      'Accesorios',   28000, 15),
('Pad Mouse XL',              'Accesorios',   12000, 60);

-- 45 ventas de enero a junio. Hay 6 sin precio_unitario (para limpiar
-- después) y algunas con descuento sobre el precio de lista.
INSERT INTO ventas (cliente_id, producto_id, cantidad, fecha_venta, precio_unitario) VALUES
-- Enero
(1,  1, 1, '2026-01-20', 950000),
(2,  2, 2, '2026-01-25',  25000),
(6,  4, 1, '2026-01-14', 420000),
(7, 12, 2, '2026-01-18',   NULL),
(8,  1, 1, '2026-01-28', 900000),
(6,  2, 1, '2026-01-30',  25000),
-- Febrero
(3,  3, 1, '2026-02-10', 180000),
(4,  4, 1, '2026-02-18', 420000),
(9,  7, 1, '2026-02-08',  85000),
(10, 6, 1, '2026-02-14',  65000),
(7,  9, 2, '2026-02-20',   NULL),
(11, 2, 1, '2026-02-27',  25000),
(8, 10, 1, '2026-02-22',  70000),
-- Marzo
(5,  5, 2, '2026-03-05', 210000),
(1,  2, 3, '2026-03-15',  25000),
(12, 1, 1, '2026-03-10', 950000),
(13,12, 3, '2026-03-18',  12000),
(2,  7, 1, '2026-03-21',   NULL),
(9,  6, 1, '2026-03-24',  58500),
(10,11, 1, '2026-03-28',  28000),
(6,  9, 1, '2026-03-30',  35000),
-- Abril
(2,  3, 2, '2026-04-08', 180000),
(3,  1, 1, '2026-04-20', 950000),
(14, 4, 1, '2026-04-05',   NULL),
(11,10, 1, '2026-04-12',  70000),
(13, 2, 2, '2026-04-15',  25000),
(12, 9, 2, '2026-04-22',  35000),
(4,  6, 1, '2026-04-26',  65000),
(15,12, 1, '2026-04-28',  12000),
-- Mayo
(16, 1, 1, '2026-05-08', 902500),
(14, 7, 2, '2026-05-10',  85000),
(5,  2, 1, '2026-05-12',   NULL),
(15, 3, 1, '2026-05-15', 180000),
(8,  6, 1, '2026-05-18',  65000),
(1, 10, 1, '2026-05-20',  70000),
(7, 11, 1, '2026-05-24',  28000),
(9, 12, 2, '2026-05-29',  12000),
-- Junio
(6,  1, 1, '2026-06-03', 950000),
(10, 4, 1, '2026-06-07', 420000),
(13, 9, 1, '2026-06-10',   NULL),
(16, 5, 1, '2026-06-14', 210000),
(3,  7, 1, '2026-06-18',  85000),
(11, 6, 2, '2026-06-21',  65000),
(2, 12, 2, '2026-06-25',  12000),
(4,  2, 1, '2026-06-28',  25000);

-- Control rápido: tiene que dar 16, 12 y 45.
SELECT
    (SELECT COUNT(*) FROM clientes)  AS total_clientes,
    (SELECT COUNT(*) FROM productos) AS total_productos,
    (SELECT COUNT(*) FROM ventas)    AS total_ventas;
