-- Retail Project - Capstone
-- Estructura y carga de datos
-- Alumno: Julián Sfoggia

CREATE TABLE IF NOT EXISTS clientes (
    cliente_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    edad INT NOT NULL CHECK (edad >= 18),
    fecha_registro DATE NOT NULL
);

CREATE TABLE IF NOT EXISTS productos (
    producto_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    categoria VARCHAR(50) NOT NULL,
    precio NUMERIC(10,2) NOT NULL CHECK (precio > 0),
    stock INT NOT NULL CHECK (stock >= 0)
);

CREATE TABLE IF NOT EXISTS ventas (
    venta_id SERIAL PRIMARY KEY,
    cliente_id INT NOT NULL REFERENCES clientes(cliente_id),
    producto_id INT NOT NULL REFERENCES productos(producto_id),
    cantidad INT NOT NULL CHECK (cantidad > 0),
    fecha_venta DATE NOT NULL
);

INSERT INTO clientes (nombre, email, edad, fecha_registro) VALUES
('Juan Pérez','juan@email.com',28,'2026-01-05'),
('María Gómez','maria@email.com',35,'2026-01-10'),
('Carlos Díaz','carlos@email.com',42,'2026-02-02'),
('Ana López','ana@email.com',24,'2026-02-15'),
('Lucía Torres','lucia@email.com',31,'2026-03-01')
ON CONFLICT (email) DO NOTHING;

INSERT INTO productos (nombre,categoria,precio,stock) VALUES
('Notebook Lenovo','Tecnología',950000,10),
('Mouse Logitech','Tecnología',25000,50),
('Silla Gamer','Muebles',180000,8),
('Monitor Samsung','Tecnología',420000,15),
('Escritorio','Muebles',210000,6)
ON CONFLICT DO NOTHING;

INSERT INTO ventas (cliente_id,producto_id,cantidad,fecha_venta) VALUES
(1,1,1,'2026-01-20'),
(2,2,2,'2026-01-25'),
(3,3,1,'2026-02-10'),
(4,4,1,'2026-02-18'),
(5,5,2,'2026-03-05'),
(1,2,3,'2026-03-15'),
(2,3,2,'2026-04-08'),
(3,1,1,'2026-04-20');
