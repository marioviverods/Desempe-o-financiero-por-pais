-- Ejecutar después de revisar QA. No modifica las tablas de origen.
-- La vista existe únicamente en la sesión actual.
CREATE OR REPLACE TEMP VIEW ventas_financieras_preparadas AS
SELECT
    v.numero_pedido,
    v.clave_producto,
    p.nombre_producto,
    pc.clave_categoria,
    v.clave_territorio,
    t.pais,
    t.continente,
    COALESCE(p.precio_producto::numeric, 0) AS precio_producto,
    COALESCE(v.cantidad_pedido::numeric, 0) AS cantidad_pedido,
    COALESCE(p.costo_producto::numeric, 0) AS costo_producto,
    COALESCE(p.precio_producto::numeric, 0)
        * COALESCE(v.cantidad_pedido::numeric, 0) AS ingreso_total,
    COALESCE(p.costo_producto::numeric, 0)
        * COALESCE(v.cantidad_pedido::numeric, 0) AS costo_total,
    (p.precio_producto IS NULL OR p.costo_producto IS NULL
        OR v.cantidad_pedido IS NULL OR t.pais IS NULL) AS datos_incompletos
FROM ventas_2017 AS v
LEFT JOIN productos AS p ON v.clave_producto = p.clave_producto
LEFT JOIN productos_categorias AS pc ON p.clave_subcategoria = pc.clave_subcategoria
LEFT JOIN territorios AS t ON v.clave_territorio = t.clave_territorio;

-- Los conteos deben coincidir; diferencias indican multiplicación por joins.
SELECT
    (SELECT COUNT(*) FROM ventas_2017) AS filas_origen,
    COUNT(*) AS filas_integradas,
    COUNT(*) FILTER (WHERE datos_incompletos) AS filas_a_investigar
FROM ventas_financieras_preparadas;
