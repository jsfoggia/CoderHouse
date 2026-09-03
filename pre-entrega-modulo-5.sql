--------------------------------------------------------
-- PRE-ENTREGA MÓDULO 5
-- Script de análisis avanzado con Window Functions
-- Retail Project
-- Alumno: Julián Sfoggia
--------------------------------------------------------


--------------------------------------------------------
-- 1. VENTAS MENSUALES
--------------------------------------------------------
-- Problema de negocio:
-- Permite conocer cuánto se vendió por categoría
-- durante cada mes.
--
-- Se utiliza DATE_TRUNC para agrupar las ventas por mes y categoría.
-- El ingreso se calcula como:
-- cantidad vendida * precio del producto.

WITH ventas_mensuales AS (

    SELECT
        DATE_TRUNC('month', v.fecha_venta) AS mes,
        p.categoria,
        SUM(v.cantidad * p.precio) AS venta_total

    FROM ventas AS v

    INNER JOIN productos AS p
        ON v.producto_id = p.producto_id

    GROUP BY
        DATE_TRUNC('month', v.fecha_venta),
        p.categoria
),


--------------------------------------------------------
-- 2. MÉTRICAS CON WINDOW FUNCTIONS
--------------------------------------------------------
-- Se calculan:
--   - Ranking de cada categoría dentro de cada mes.
--   - Ventas acumuladas de cada categoría a través
--     de los meses.
--   - Promedio histórico de ventas de cada categoría.
--
-- RANK() permite comparar las categorías dentro
-- de cada período.
--
-- SUM() OVER() genera el acumulado respetando
-- el orden cronológico de los meses.

metricas_ventana AS (

    SELECT
        mes,
        categoria,
        venta_total,

        RANK() OVER (
            PARTITION BY mes
            ORDER BY venta_total DESC
        ) AS ranking_categoria,

        SUM(venta_total) OVER (
            PARTITION BY categoria
            ORDER BY mes
            ROWS BETWEEN UNBOUNDED PRECEDING
            AND CURRENT ROW
        ) AS ventas_acumuladas,

        AVG(venta_total) OVER (
            PARTITION BY categoria
        ) AS promedio_historico

    FROM ventas_mensuales
)


--------------------------------------------------------
-- 3. REPORTE FINAL
--------------------------------------------------------
-- Problema de negocio:
-- Permite identificar el rendimiento mensual de cada
-- categoría y compararlo contra su promedio histórico.
-- Si la venta mensual es igual o superior al promedio
-- histórico se considera "Exitoso".
-- En caso contrario se considera "Bajo el promedio".

SELECT
    mes,
    categoria,
    venta_total,
    ranking_categoria,
    ventas_acumuladas,

    CASE
        WHEN venta_total >= promedio_historico
            THEN 'Exitoso'
        ELSE 'Bajo el promedio'
    END AS comparativa

FROM metricas_ventana

ORDER BY
    mes,
    ranking_categoria;