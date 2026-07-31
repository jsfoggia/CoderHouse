--------------------------------------------------------
-- PRE-ENTREGA
-- Retail Project
-- Alumno: Julián Sfoggia
--------------------------------------------------------

--------------------------------------------------------
-- Crear Base de Datos
--------------------------------------------------------

CREATE DATABASE retail_project;

-- Conectarse a la base de datos retail_project antes de continuar.

--------------------------------------------------------

-- CREACIÓN DE TABLAS
--------------------------------------------------------

CREATE TABLE clientes (
    cliente_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    edad INT NOT NULL,
    fecha_registro DATE NOT NULL,

    CONSTRAINT chk_edad_cliente
        CHECK (edad >= 18)
);

CREATE TABLE productos (
    producto_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    categoria VARCHAR(50) NOT NULL,
    precio DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL,

    CONSTRAINT chk_precio_producto
        CHECK (precio > 0),

    CONSTRAINT chk_stock_producto
        CHECK (stock >= 0)
);

CREATE TABLE ventas (
    venta_id SERIAL PRIMARY KEY,

    cliente_id INT NOT NULL,
    producto_id INT NOT NULL,

    cantidad INT NOT NULL,
    fecha_venta DATE NOT NULL,

    CONSTRAINT chk_cantidad_venta
        CHECK (cantidad > 0),

    CONSTRAINT fk_cliente
        FOREIGN KEY (cliente_id)
        REFERENCES clientes(cliente_id),

    CONSTRAINT fk_producto
        FOREIGN KEY (producto_id)
        REFERENCES productos(producto_id)
);

--------------------------------------------------------
-- CARGA INICIAL DE DATOS
--------------------------------------------------------

BEGIN;

---------------------------------------------------------
-- CLIENTES
---------------------------------------------------------

INSERT INTO clientes (nombre, email, edad, fecha_registro)
VALUES
('Juan Pérez','juan@email.com',28,'2026-07-01'),
('María Gómez','maria@email.com',35,'2026-07-02'),
('Carlos Díaz','carlos@email.com',42,'2026-07-03'),
('Ana López','ana@email.com',24,'2026-07-04'),
('Lucía Torres','lucia@email.com',31,'2026-07-05');

---------------------------------------------------------
-- PRODUCTOS
---------------------------------------------------------

INSERT INTO productos (nombre,categoria,precio,stock)
VALUES
('Notebook Lenovo','Tecnología',950000,10),
('Mouse Logitech','Tecnología',25000,50),
('Silla Gamer','Muebles',180000,8),
('Monitor Samsung','Tecnología',420000,15),
('Escritorio','Muebles',210000,6);

---------------------------------------------------------
-- VENTAS
---------------------------------------------------------

INSERT INTO ventas (cliente_id,producto_id,cantidad,fecha_venta)
VALUES
(1,1,1,'2026-07-20'),
(2,2,2,'2026-07-21'),
(3,3,1,'2026-07-22'),
(4,4,1,'2026-07-23'),
(5,5,2,'2026-07-24');

COMMIT;

--------------------------------------------------------
-- ACTUALIZACIÓN DE DATOS
--------------------------------------------------------

-- Verificar primero

SELECT *
FROM productos
WHERE categoria = 'Tecnología';

UPDATE productos
SET precio = precio * 1.10
WHERE categoria = 'Tecnología';

--------------------------------------------------------
-- ELIMINACIÓN DE DATOS
--------------------------------------------------------

-- Verificar primero

SELECT *
FROM ventas
WHERE venta_id = 5;

DELETE FROM ventas
WHERE venta_id = 5;

--------------------------------------------------------
-- CONSULTAS DE VERIFICACIÓN
--------------------------------------------------------

SELECT * FROM clientes;
SELECT * FROM productos;
SELECT * FROM ventas;