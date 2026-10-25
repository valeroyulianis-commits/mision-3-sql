# Misión 3 · Los datos tienen que vivir en algún sitio: SQL

**Máster en IA Aplicada · Universidad Europea · Programación y Entornos en IA**

Equipo: Yulianis Valero y Yuleimis Valero

## Contexto
Proyecto *AI Customer Intelligence*: organizamos los datos de clientes y operaciones (antes en CSV sueltos) en una base de datos relacional MySQL y extraemos un dataset de variables para un futuro modelo de abandono (*churn*).

## Contenido del repositorio
| Archivo | Qué hace |
|---|---|
| `01_creacion.sql` | Crea la base `ai_customer` y las tablas `clientes` y `operaciones` con sus claves |
| `02_datos.sql` | Carga 30 clientes y 99 operaciones de ejemplo |
| `03_retos.sql` | Consultas comentadas de los Retos 1 a 4 y del Reto final, con sus validaciones |
| `04_dataset_ia.sql` | Consulta final: una fila por cliente con las variables para IA |
| `clientes.csv`, `operaciones.csv` | Datos de origen |
| `Informe_Mision3_SQL.pdf` | Informe de resultados con las evidencias de ejecución |

## Cómo ejecutarlo
Requisitos: MySQL Server 8.4 y MySQL Workbench.

1. Abre una conexión local (127.0.0.1:3306, usuario root).
2. Ejecuta `01_creacion.sql` y después `02_datos.sql`.
3. Ejecuta `03_retos.sql` para ver los retos.
4. Ejecuta `04_dataset_ia.sql` para obtener el dataset final.

## Modelo de datos
- `clientes` (PK `id_cliente`): nombre, ciudad, antigüedad en meses y abandono (0/1).
- `operaciones` (PK `id_operacion`, FK `id_cliente` → `clientes`): fecha, importe y canal.
- La relación es **1:N**: un cliente puede tener muchas operaciones (o ninguna), pero cada operación pertenece a un solo cliente. La clave foránea impide registrar operaciones de clientes que no existen.

## Resultado principal
El dataset final tiene **30 filas** (una por cliente), **ningún duplicado** y **ningún nulo**. Los 4 clientes sin operaciones aparecen con `num_operaciones = 0`, `gasto_total = 0` y `ticket_medio = 0` gracias a `LEFT JOIN` y `COALESCE`.

## Siguiente paso (Misión 4)
Conectar Python a MySQL, ejecutar `04_dataset_ia.sql` y cargar el resultado en un DataFrame de pandas.
