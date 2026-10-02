# Proyecto Capstone - Análisis de ventas en PostgreSQL

Julián Sfoggia

## El problema

Tomé como caso una tienda chica que vende tecnología y muebles para home office. Tengo las ventas del primer semestre de 2026 y la idea es ver de dónde sale la plata antes de decidir qué comprar y qué empujar en el segundo semestre.

Puntualmente quería saber:

- si los datos de ventas estaban completos o había huecos que cambiaran los totales
- quiénes son los mejores clientes y si tienen algo en común
- cómo se mueven las ventas mes a mes
- qué productos casi no se venden
- qué categoría lidera cada mes
- si la facturación depende de pocos productos

## Los datos

Armé el dataset yo, con tres tablas: `clientes` (16), `productos` (12) y `ventas` (45, de enero a junio).

En `ventas` agregué la columna `precio_unitario`, que es lo que se cobró de verdad (a veces con descuento). Esa columna acepta nulos a propósito, para simular ventas que se cargaron sin el precio.

## Limpieza

De las 45 ventas, 6 no tienen precio (un 13 %). Si sumo directamente, `SUM` saltea esas filas y la facturación me da $9.653.000, cuando en realidad es $10.312.000. O sea, me estaría comiendo $659.000.

Lo resolví completando el precio que falta con el precio de lista: `COALESCE(v.precio_unitario, p.precio)`. No es perfecto, porque si esa venta tuvo descuento el precio de lista la infla un poco, pero la venta existió y es el mejor dato que tengo. Para no repetir esa regla en cada consulta la puse en una vista, `ventas_limpias`.

También chequeé con `information_schema` que las fechas sean `DATE` y los precios `NUMERIC`.

## Qué encontré

### Top 5 clientes

| Cliente | Compras | Gasto total |
|---|---|---|
| Martín Fernández | 4 | $1.430.000 |
| Carlos Díaz | 3 | $1.215.000 |
| Agustín Romero | 2 | $1.112.500 |
| Juan Pérez | 3 | $1.095.000 |
| Diego Herrera | 3 | $1.035.000 |

Estos 5 clientes (de 16) se llevan el 57 % de la facturación. Lo que me llamó la atención es que los cinco compraron la Notebook Lenovo. No están arriba por comprar seguido sino porque hicieron una compra cara: Agustín Romero es tercero con solo 2 compras. Si no vuelven a comprar algo de ese precio, el semestre que viene probablemente no estén en el top. Me parece que tendría sentido ofrecerles accesorios (monitor, teclado, webcam) para que vuelvan.

### Ventas por mes

| Mes | Operaciones | Ventas | Variación |
|---|---|---|---|
| Enero | 6 | $2.369.000 | |
| Febrero | 7 | $915.000 | -61,4 % |
| Marzo | 8 | $1.687.500 | +84,4 % |
| Abril | 8 | $1.997.000 | +18,3 % |
| Mayo | 8 | $1.464.500 | -26,7 % |
| Junio | 8 | $1.879.000 | +28,3 % |

Las ventas suben y bajan bastante, pero la cantidad de operaciones casi no cambia (entre 6 y 8 por mes). Febrero cae 61 % y no es porque haya venido menos gente: es el único mes en que no se vendió ninguna notebook. Si saco la notebook, el resto factura entre $519.000 y $1.047.000 por mes, que es mucho más parejo. Para proyectar conviene mirar las dos cosas por separado.

### Productos menos vendidos

| Producto | Stock | Unidades vendidas |
|---|---|---|
| Biblioteca Modular | 5 | 0 |
| Apoyapiés Ergonómico | 15 | 2 |
| Webcam Logitech | 20 | 3 |

La Biblioteca Modular no se vendió nunca en seis meses, y hay 5 en depósito (unos $750.000 a precio de lista). Para que aparezca en la consulta tuve que usar `LEFT JOIN`; con un `JOIN` común no tiene filas en ventas y directamente no sale. El apoyapiés y la webcam se venden, pero muy despacio para el stock que hay. Yo liquidaría la biblioteca (o la armaría en combo con el escritorio) y no repondría los otros dos por ahora.

### Ranking de categorías por mes

Tecnología sale primera todos los meses y hace el 83 % del semestre. Muebles es segunda casi siempre (13 %). Iluminación y Accesorios juntas no llegan al 4 %. No hay rotación: en la práctica es una tienda de tecnología que además vende algunos muebles. Las categorías chicas sirven más como complemento de una venta de tecnología que como algo para promocionar solo.

### Cuánto depende la facturación de cada producto

| Producto | Unidades | % de la facturación |
|---|---|---|
| Notebook Lenovo | 6 | 54,3 % |
| Monitor Samsung | 4 | 16,3 % |
| Silla Gamer | 4 | 7,0 % |
| Los otros 9 | | 22,4 % |

Más de la mitad de lo que se factura sale de 6 notebooks. En cambio el Mouse Logitech es lo que más unidades vendió (11) y apenas aporta el 2,7 %.

Depender tanto de un producto es un riesgo. Si el proveedor se queda sin stock o sube el precio, la facturación se puede caer a la mitad, como pasó en febrero. Si otro comercio la vende más barata, perdemos justo el producto que sostiene todo. Y ya se ve algo de presión en el precio: dos de los tres descuentos del semestre fueron en esta notebook ($900.000 y $902.500 contra $950.000 de lista).

## Conclusiones

Lo principal es que el negocio depende de la Notebook Lenovo: explica la mitad de la facturación, los saltos mes a mes y quiénes son los mejores clientes. Sería lo primero a cuidar (asegurar stock, negociar con el proveedor) y convendría sumar otro modelo o marca para no depender de uno solo.

Después, aprovechar cada venta de notebook para vender accesorios, sacarse de encima el stock que no rota y pedir que el precio se cargue siempre en el punto de venta, porque hoy falta en una de cada ocho ventas.

Una aclaración: son 45 ventas en seis meses, así que esto hay que tomarlo como una primera lectura y confirmarlo con más datos.

## Cómo correrlo

Necesitás PostgreSQL (lo probé en la versión 16) y pgAdmin o psql.

**Con pgAdmin:**

1. Conectado a la base `postgres`, ejecutar solo `CREATE DATABASE capstone_project;`
2. Abrir un Query Tool nuevo sobre `capstone_project`.
3. Ejecutar `estructura.sql`. Al final muestra un conteo: tienen que salir 16 clientes, 12 productos y 45 ventas.
4. Ejecutar `analisis.sql`. Para ver cada resultado conviene seleccionar una consulta y correrla sola.

**Con psql:**

```bash
psql -U postgres -c "CREATE DATABASE capstone_project;"
psql -U postgres -d capstone_project -f estructura.sql
psql -U postgres -d capstone_project -f analisis.sql
```

`estructura.sql` borra y vuelve a crear las tablas, así que se puede correr las veces que haga falta.

## Archivos

- `estructura.sql`: creación de tablas y carga de datos
- `analisis.sql`: limpieza y consultas
- `README.md`: este archivo
