-- Proyecto Capstone - Análisis de ventas
-- analisis.sql: limpieza y consultas
-- Julián Sfoggia
-- Correr en capstone_project después de estructura.sql


-- 1. LIMPIEZA

-- Antes de sumar nada quiero saber cuántas ventas no tienen precio,
-- porque esas filas después se pierden en los totales.
SELECT
    COUNT(*) AS total_ventas,
    COUNT(*) FILTER (WHERE precio_unitario IS NULL) AS ventas_sin_precio,
    ROUND(100.0 * COUNT(*) FILTER (WHERE precio_unitario IS NULL) / COUNT(*), 1) AS pct_sin_precio,
    COUNT(*) FILTER (WHERE fecha_venta IS NULL) AS ventas_sin_fecha,
    COUNT(*) FILTER (WHERE cantidad IS NULL) AS ventas_sin_cantidad
FROM ventas;

-- Chequeo que fechas y precios tengan el tipo correcto. Si una fecha
-- estuviera como texto, DATE_TRUNC no funcionaría.
SELECT table_name, column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
  AND column_name IN ('precio', 'precio_unitario', 'fecha_venta', 'fecha_registro', 'cantidad')
ORDER BY table_name, column_name;

-- Cuánta plata se pierde si no trato los nulos (SUM los ignora).
-- Completo con el precio de lista: la venta existió y es el mejor
-- dato que tengo de lo que se cobró.
SELECT
    SUM(v.cantidad * v.precio_unitario) AS facturacion_sin_limpiar,
    SUM(v.cantidad * COALESCE(v.precio_unitario, p.precio)) AS facturacion_limpia,
    SUM(v.cantidad * COALESCE(v.precio_unitario, p.precio))
      - SUM(v.cantidad * v.precio_unitario) AS diferencia
FROM ventas v
JOIN productos p ON p.producto_id = v.producto_id;

-- Dejo la regla del COALESCE en una vista para no repetirla en cada
-- consulta (y si la cambio, la cambio en un solo lugar).
CREATE OR REPLACE VIEW ventas_limpias AS
SELECT
    v.venta_id,
    v.cliente_id,
    v.producto_id,
    v.cantidad,
    v.fecha_venta,
    COALESCE(v.precio_unitario, p.precio) AS precio_final,
    v.cantidad * COALESCE(v.precio_unitario, p.precio) AS importe
FROM ventas v
JOIN productos p ON p.producto_id = v.producto_id;


-- 2. TOP 5 CLIENTES POR GASTO

-- Sumo también la cantidad de compras para ver si gastan mucho porque
-- vuelven seguido o por una sola compra grande.
SELECT
    c.cliente_id,
    c.nombre,
    COUNT(vl.venta_id) AS compras,
    SUM(vl.importe) AS gasto_total
FROM clientes c
JOIN ventas_limpias vl ON vl.cliente_id = c.cliente_id
GROUP BY c.cliente_id, c.nombre
ORDER BY gasto_total DESC
LIMIT 5;


-- 3. VENTAS POR MES

-- Con el total solo no se ve bien si un mes cayó, así que uso LAG para
-- compararlo con el anterior. NULLIF es por si algún mes diera 0.
WITH ventas_mes AS (
    SELECT
        DATE_TRUNC('month', fecha_venta)::DATE AS mes,
        COUNT(*) AS operaciones,
        SUM(importe) AS ventas_totales
    FROM ventas_limpias
    GROUP BY DATE_TRUNC('month', fecha_venta)
)
SELECT
    TO_CHAR(mes, 'YYYY-MM') AS mes,
    operaciones,
    ventas_totales,
    ROUND(100.0 * (ventas_totales - LAG(ventas_totales) OVER (ORDER BY mes))
          / NULLIF(LAG(ventas_totales) OVER (ORDER BY mes), 0), 1) AS variacion_pct
FROM ventas_mes
ORDER BY mes;


-- 4. LOS 3 PRODUCTOS MENOS VENDIDOS

-- LEFT JOIN desde productos porque me interesa sobre todo el que no se
-- vendió nunca. Con JOIN normal ese producto no tiene filas en ventas
-- y no aparecería.
-- El COALESCE pasa su NULL a 0; si no, en orden ASC quedaría al final.
-- Si empatan, va primero el que tiene más stock parado.
SELECT
    p.producto_id,
    p.nombre,
    p.categoria,
    p.stock,
    COALESCE(SUM(vl.cantidad), 0) AS unidades_vendidas,
    COALESCE(SUM(vl.importe), 0) AS facturacion
FROM productos p
LEFT JOIN ventas_limpias vl ON vl.producto_id = p.producto_id
GROUP BY p.producto_id, p.nombre, p.categoria, p.stock
ORDER BY unidades_vendidas ASC, p.stock DESC
LIMIT 3;


-- 5. RANKING DE CATEGORÍAS POR MES

-- Quiero ver si la categoría que lidera cambia según el mes.
-- PARTITION BY mes arranca el ranking de cero en cada mes. Uso RANK y
-- no ROW_NUMBER para que si dos categorías empatan compartan el puesto.
WITH ventas_categoria_mes AS (
    SELECT
        DATE_TRUNC('month', vl.fecha_venta)::DATE AS mes,
        p.categoria,
        SUM(vl.importe) AS venta_total
    FROM ventas_limpias vl
    JOIN productos p ON p.producto_id = vl.producto_id
    GROUP BY DATE_TRUNC('month', vl.fecha_venta), p.categoria
)
SELECT
    TO_CHAR(mes, 'YYYY-MM') AS mes,
    categoria,
    venta_total,
    RANK() OVER (PARTITION BY mes ORDER BY venta_total DESC) AS ranking_categoria
FROM ventas_categoria_mes
ORDER BY mes, ranking_categoria;


-- 6. PESO DE CADA PRODUCTO EN LA FACTURACIÓN

-- Para ver si dependemos de pocos productos. SUM() OVER () me da el
-- total general en cada fila sin agrupar, y con eso saco el porcentaje.
-- El CASE es para clasificarlos rápido sin mirar decimales.
WITH facturacion_producto AS (
    SELECT
        p.nombre,
        COALESCE(SUM(vl.cantidad), 0) AS unidades,
        COALESCE(SUM(vl.importe), 0) AS facturacion
    FROM productos p
    LEFT JOIN ventas_limpias vl ON vl.producto_id = p.producto_id
    GROUP BY p.nombre
)
SELECT
    nombre,
    unidades,
    facturacion,
    ROUND(100.0 * facturacion / SUM(facturacion) OVER (), 1) AS pct_facturacion,
    CASE
        WHEN 100.0 * facturacion / SUM(facturacion) OVER () >= 30 THEN 'Dependencia alta'
        WHEN 100.0 * facturacion / SUM(facturacion) OVER () >= 10 THEN 'Relevante'
        WHEN facturacion = 0 THEN 'Sin ventas'
        ELSE 'Aporte menor'
    END AS nivel
FROM facturacion_producto
ORDER BY facturacion DESC;
