-- Evidencia histórica disponible: cero en los cuatro primeros controles.
SELECT
    COUNT(*) FILTER (WHERE numero_pedido IS NULL) AS nulos_numero_pedido,
    COUNT(*) FILTER (WHERE clave_producto IS NULL) AS nulos_clave_producto,
    COUNT(*) FILTER (WHERE clave_territorio IS NULL) AS nulos_clave_territorio
FROM ventas_2017;

SELECT COUNT(*) AS filas_cantidad_no_valida
FROM ventas_2017 WHERE cantidad_pedido <= 0;

-- Corrección y controles adicionales: pendientes de ejecución en la base real.
SELECT COUNT(*) AS productos_precio_negativo
FROM productos WHERE precio_producto < 0;

SELECT
    COUNT(*) FILTER (WHERE precio_producto IS NULL) AS precios_nulos,
    COUNT(*) FILTER (WHERE costo_producto IS NULL) AS costos_nulos,
    COUNT(*) FILTER (WHERE costo_producto < 0) AS costos_negativos
FROM productos;

SELECT COUNT(*) AS cantidades_nulas
FROM ventas_2017 WHERE cantidad_pedido IS NULL;

-- Cada consulta debe devolver cero filas para una dimensión de clave única.
SELECT clave_producto, COUNT(*) AS filas
FROM productos GROUP BY clave_producto HAVING COUNT(*) > 1;
SELECT clave_subcategoria, COUNT(*) AS filas
FROM productos_categorias GROUP BY clave_subcategoria HAVING COUNT(*) > 1;
SELECT clave_territorio, COUNT(*) AS filas
FROM territorios GROUP BY clave_territorio HAVING COUNT(*) > 1;

-- Varias filas de campañas requieren confirmar que representan gastos distintos.
SELECT clave_territorio::integer, COUNT(*) AS filas
FROM campanas GROUP BY clave_territorio::integer HAVING COUNT(*) > 1;

SELECT COUNT(*) AS ventas_sin_producto
FROM ventas_2017 AS v
WHERE NOT EXISTS (
    SELECT 1 FROM productos AS p WHERE p.clave_producto = v.clave_producto
);
SELECT COUNT(*) AS ventas_sin_territorio
FROM ventas_2017 AS v
WHERE NOT EXISTS (
    SELECT 1 FROM territorios AS t WHERE t.clave_territorio = v.clave_territorio
);
SELECT COUNT(*) AS productos_sin_categoria
FROM productos AS p
WHERE NOT EXISTS (
    SELECT 1 FROM productos_categorias AS pc
    WHERE pc.clave_subcategoria = p.clave_subcategoria
);
SELECT
    COUNT(*) FILTER (WHERE clave_territorio IS NULL) AS territorios_nulos,
    COUNT(*) FILTER (WHERE costo_campana IS NULL) AS gastos_nulos,
    COUNT(*) FILTER (WHERE costo_campana::numeric < 0) AS gastos_negativos
FROM campanas;
