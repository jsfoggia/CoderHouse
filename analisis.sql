-- Retail Project - Capstone
-- Análisis Exploratorio de Datos (EDA)
-- Alumno: Julián Sfoggia

-- 1. LIMPIEZA Y CONTROL DE DATOS
-- Verificamos nulos en los campos críticos antes del análisis.
SELECT
    COUNT(*) FILTER (WHERE cliente_id IS NULL) AS clientes_nulos,
    COUNT(*) FILTER (WHERE producto_id IS NULL) AS productos_nulos,
    COUNT(*) FILTER (WHERE cantidad IS NULL) AS cantidades_nulas,
    COUNT(*) FILTER (WHERE fecha_venta IS NULL) AS fechas_nulas
FROM ventas;

-- 2. TOP 5 CLIENTES POR GASTO TOTAL
-- Identifica los clientes de mayor valor comercial.
SELECT
    c.cliente_id,
    c.nombre,
    SUM(v.cantidad * p.precio) AS gasto_total
FROM clientes c
JOIN ventas v ON v.cliente_id = c.cliente_id
JOIN productos p ON p.producto_id = v.producto_id
GROUP BY c.cliente_id, c.nombre
ORDER BY gasto_total DESC
LIMIT 5;

-- 3. VENTAS TOTALES POR MES
-- Permite observar la evolución mensual de los ingresos.
SELECT
    DATE_TRUNC('month', v.fecha_venta) AS mes,
    COALESCE(SUM(v.cantidad * p.precio), 0) AS ventas_totales
FROM ventas v
JOIN productos p ON p.producto_id = v.producto_id
GROUP BY DATE_TRUNC('month', v.fecha_venta)
ORDER BY mes;

-- 4. PRODUCTOS MENOS VENDIDOS
-- Detecta productos con menor movimiento comercial.
SELECT
    p.producto_id,
    p.nombre,
    COALESCE(SUM(v.cantidad), 0) AS unidades_vendidas
FROM productos p
LEFT JOIN ventas v ON v.producto_id = p.producto_id
GROUP BY p.producto_id, p.nombre
ORDER BY unidades_vendidas ASC
LIMIT 3;

-- 5. RANKING DE CATEGORÍAS POR MES
-- Compara el rendimiento de las categorías dentro de cada mes.
WITH ventas_mensuales AS (
    SELECT
        DATE_TRUNC('month', v.fecha_venta) AS mes,
        p.categoria,
        SUM(v.cantidad * p.precio) AS venta_total
    FROM ventas v
    JOIN productos p ON p.producto_id = v.producto_id
    GROUP BY DATE_TRUNC('month', v.fecha_venta), p.categoria
)
SELECT
    mes,
    categoria,
    venta_total,
    RANK() OVER (
        PARTITION BY mes
        ORDER BY venta_total DESC
    ) AS ranking_categoria
FROM ventas_mensuales
ORDER BY mes, ranking_categoria;
