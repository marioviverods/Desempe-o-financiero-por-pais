-- Requiere 03_preparacion_datos.sql ejecutado en la misma sesión.
-- Confirmar que cada fila de campanas es un gasto distinto y no un duplicado.
-- Agregar ambos lados antes del JOIN evita repetir gastos por línea de venta.
WITH ventas_por_territorio AS (
    SELECT pais, clave_territorio,
        SUM(ingreso_total) AS ingresos,
        SUM(costo_total) AS costos,
        COUNT(*) FILTER (WHERE datos_incompletos) AS filas_a_investigar
    FROM ventas_financieras_preparadas
    GROUP BY pais, clave_territorio
), campanas_por_territorio AS (
    SELECT clave_territorio::integer AS clave_territorio,
        CASE WHEN COUNT(*) FILTER (WHERE costo_campana IS NULL) > 0
            THEN NULL ELSE SUM(costo_campana::numeric) END AS costo_campana
    FROM campanas
    GROUP BY clave_territorio::integer
)
SELECT v.pais, v.clave_territorio,
    ROUND(v.ingresos, 2) AS ingresos,
    ROUND(v.costos, 2) AS costos,
    ROUND(c.costo_campana, 2) AS costo_campana,
    ROUND(v.ingresos - v.costos, 2) AS beneficio_bruto,
    ROUND((v.ingresos - v.costos) * 100.0
        / NULLIF(v.ingresos, 0), 2) AS margen_bruto_pct,
    -- En la captura original esta relación se llamaba roi_pct.
    ROUND((v.ingresos - v.costos) * 100.0
        / NULLIF(c.costo_campana, 0), 2) AS beneficio_sobre_campanas_pct,
    v.filas_a_investigar
FROM ventas_por_territorio AS v
LEFT JOIN campanas_por_territorio AS c
    ON v.clave_territorio = c.clave_territorio
ORDER BY beneficio_sobre_campanas_pct DESC NULLS LAST;
