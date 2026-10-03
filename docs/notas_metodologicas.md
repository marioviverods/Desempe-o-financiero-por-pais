# Alcance y revisión metodológica

## Procedencia

Proyecto académico con ventas de la tabla `ventas_2017`. El repositorio se reconstruyó a partir del SQL y capturas del autor. No se dispone de la base completa, de su licencia de redistribución, de un enlace público al dashboard ni del archivo editable. No se fabricaron datos de origen.

## Correcciones de esta versión

- Se uniformó el uso de `LEFT JOIN` al integrar productos para conservar ventas sin coincidencia. Esto puede cambiar los resultados frente al `JOIN` original si existen claves huérfanas.
- Se agregó una vista temporal explícita, evitando depender de `ventas_clean`, `pais_ingreso_costo` y `pais_campanas`, cuyas definiciones no se proporcionaron.
- Se agregó el gasto por territorio antes de unirlo a las ventas agregadas. Sumar el gasto después de unirlo a cada venta lo repetía por cada registro.
- Se conservó precisión decimal en los cálculos y se redondea solo al mostrar los KPIs.
- Se corrigió `LECT` a `SELECT` y se sustituyó el control de cantidades negativas repetido por el control de precios negativos solicitado.
- Se renombró el indicador de beneficio bruto/gasto de campañas para explicar su fórmula y evitar confundirlo con retorno neto o incremental.
- Se incorporaron controles adicionales de claves y cobertura, que no forman parte de los resultados históricos verificados.

## Supuestos que deben comprobarse

Los importes deben compartir moneda, periodo y alcance. Las claves de producto, subcategoría y territorio deben ser únicas en sus dimensiones. Varias filas por territorio en campañas solo deben sumarse si representan gastos distintos. Los casts a entero y numeric requieren datos convertibles; los errores de conversión deben resolverse en la fuente, no ocultarse.

La tabla final está al nivel país-territorio: si un país tiene varios territorios aparecerá en varias filas. En las capturas hay un territorio por país. La consulta parte de ventas, por lo que los territorios que solo tengan campañas y ninguna venta no aparecerán en la salida.

`COALESCE` mantiene el tratamiento original de nulos en las métricas de venta, pero puede subestimar ingresos o costos. Debe revisarse la bandera `datos_incompletos`. Un gasto de campaña nulo o sin coincidencia no se convierte en cero; un gasto cero produce una relación nula mediante `NULLIF`.

## Evidencia y límites

- `qa_claves_original.png`: cero nulos en las tres claves revisadas.
- `qa_cantidades_original.png`: cero cantidades menores o iguales a cero, según la consulta correspondiente aportada.
- `tabla_kpis_original.png`: salida histórica con importes enteros; no es salida del nuevo SQL.
- `dashboard_original.png`: evidencia visual original con decimales y narrativa histórica.

No se certifica que la base esté libre de duplicados, precios negativos o problemas de correspondencia: esas consultas deben ejecutarse. No se ejecutó el SQL revisado contra la fuente ni se comprobó que reproduzca exactamente los totales. Diferencias de redondeo entre dashboard y SQL original son visibles.

Los datos agregados por país permiten describir relaciones, pero no atribuir ventas a campañas, estimar causalidad ni garantizar resultados al reasignar presupuesto. Las recomendaciones del README son acciones de investigación y validación, no impactos ya obtenidos.
