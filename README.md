# Retail Project

Este repositorio contiene las pre-entregas del curso de SQL, desarrolladas sobre la base de datos `retail_project`.

## Ejecución

1. Ejecutar el script para crear la base de datos `retail_project`.
2. Conectarse a la base de datos.
3. Ejecutar los scripts de cada pre-entrega.

## Pre-entrega 4

El archivo `pre-entrega-modulo4.sql` contiene consultas multicapa para analizar:

- Rentabilidad por categoría.
- Clientes sin compras.
- Top de compras por cliente.

Las consultas utilizan `JOIN`, `GROUP BY`, `HAVING`, `COALESCE`, CTEs y `ROW_NUMBER()`.

## Pre-entrega 5

El archivo `pre-entrega-modulo-5.sql` contiene un análisis avanzado de ventas utilizando CTEs y Window Functions.

Permite analizar:

- Ventas mensuales por categoría.
- Ranking de categorías.
- Ventas acumuladas.
- Promedio histórico.
- Comparación del rendimiento entre `Exitoso` y `Bajo el promedio`.

## Modelo de datos

El proyecto utiliza tres tablas principales:

- `clientes`
- `productos`
- `ventas`

La categoría de los productos se encuentra en `productos.categoria`.
