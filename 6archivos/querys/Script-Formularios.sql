--Obtiene area_unidad_responsables
SELECT
      au.aun_codigo AS aun_codigo_ejecutora, au.aun_nombre, au.aun_sigla, au.cau_codigo, au.aun_numero,
      CONCAT(au.aun_nombre, ' - ', au.aun_sigla) AS nom_ejecutora,
      au.aun_reporte_habilitado,
      COALESCE(
        ARRAY_AGG(
          DISTINCT aur.rol_codigo ORDER BY aur.rol_codigo ASC
        ) FILTER (WHERE aur.per_codigo = 1914),
        '{}'
      ) AS roles,
      COUNT(DISTINCT aur.rol_codigo) AS cantidad_roles
FROM	estructura_poa.area_unidad_responsables aur
      LEFT JOIN estructura_organizacional.areas_unidades au ON aur.aun_codigo_ejecutora = au.aun_codigo
WHERE	aur.aur_estado != 0 -- ESTADO ROL-RESPONSABLE
      AND au.aun_estado IN (2) -- ESTADO AREA-UNIDAD (CONSOLIDADO)
      AND aur.rol_codigo IN (1,2,3,4) -- ROL SELECCIONADO
      AND aur.poa_codigo IN (3) -- POA SELECCIONADO
GROUP BY au.aun_codigo, au.aun_nombre, au.aun_sigla, au.cau_codigo, au.aun_numero, au.aun_reporte_habilitado
ORDER BY au.aun_sigla ASC, au.aun_nombre ASC
;
--Prueba el JOIN básico:
SELECT au.aun_codigo, au.aun_nombre
FROM estructura_poa.area_unidad_responsables aur
LEFT JOIN estructura_organizacional.areas_unidades au ON aur.aun_codigo_ejecutora = au.aun_codigo;

--Agrega las condiciones WHERE:
SELECT au.aun_codigo, au.aun_nombre
FROM estructura_poa.area_unidad_responsables aur
LEFT JOIN estructura_organizacional.areas_unidades au ON aur.aun_codigo_ejecutora = au.aun_codigo
WHERE aur.aur_estado != 0 AND au.aun_estado IN (2);

--Agrega GROUP BY y ORDER BY:
SELECT au.aun_codigo, au.aun_nombre
FROM estructura_poa.area_unidad_responsables aur
LEFT JOIN estructura_organizacional.areas_unidades au ON aur.aun_codigo_ejecutora = au.aun_codigo
WHERE aur.aur_estado != 0 AND au.aun_estado IN (2)
GROUP BY au.aun_codigo, au.aun_nombre
ORDER BY au.aun_nombre ASC;

--Agrega ARRAY_AGG:
SELECT
    ARRAY_AGG(aur.rol_codigo) AS roles
FROM estructura_poa.area_unidad_responsables aur
WHERE aur.aun_codigo_ejecutora = 1;
--Aplica DISTINCT y ORDER BY:
SELECT
    ARRAY_AGG(DISTINCT aur.rol_codigo ORDER BY aur.rol_codigo ASC) AS roles
FROM estructura_poa.area_unidad_responsables aur
WHERE aur.aun_codigo_ejecutora = 1;
--Añade ARRAY_AGG, FILTER, y COALESCE para manejar los roles:
SELECT
    au.aun_codigo,
    au.aun_nombre,
    COALESCE(
        ARRAY_AGG(DISTINCT aur.rol_codigo ORDER BY aur.rol_codigo ASC) FILTER (WHERE aur.per_codigo = 1914),
        '{}'
    ) AS roles
FROM estructura_poa.area_unidad_responsables aur
LEFT JOIN estructura_organizacional.areas_unidades au ON aur.aun_codigo_ejecutora = au.aun_codigo
WHERE aur.aur_estado != 0 AND au.aun_estado IN (2)
GROUP BY au.aun_codigo, au.aun_nombre;

--##########################
SELECT
      a.act_estado, a.act_codigo_anterior, av.avi_estado, COALESCE(COUNT(DISTINCT a.act_codigo), 0) AS cantidad_actividades,
      COALESCE(COUNT(DISTINCT av.avi_codigo), 0) AS cantidad_viaticos
FROM	estructura_poa.poas_objetivos po
      LEFT JOIN estructura_poa.objetivos_area_unidad oau ON po.pobj_codigo = oau.pobj_codigo
      LEFT JOIN estructura_poa.actividades a ON po.pobj_codigo = a.pobj_codigo AND a.act_estado IN (4,10,14,11,12,13,45,1,3,8,7,17,2,5)
      LEFT JOIN estructura_poa.actividades_viaticos av ON a.act_codigo = av.act_codigo AND av.avi_estado IN (4,10,14,11,12,13,45,1,3,8,7,17,2,5)
WHERE	TRUE
      AND oau.oau_estado != 0
      AND po.poa_codigo IN (3)
      AND po.pobj_estado IN (2,8)
      AND oau.aun_codigo_ejecutora IN (27)
      AND a.aun_codigo_ejecutora IN (27)
      AND a.cac_codigo IN (1,3,4)
GROUP BY a.act_estado, av.avi_estado, a.act_codigo_anterior
ORDER BY
      array_position( array[4,10,14,11,12,13,45,1,3,8,7,17,2,5], av.avi_estado ),
      array_position( array[4,10,14,11,12,13,45,1,3,8,7,17,2,5], a.act_estado )
;
--Prueba Individual de SELECT y FROM:
SELECT a.act_estado, av.avi_estado
FROM estructura_poa.actividades a
LEFT JOIN estructura_poa.actividades_viaticos av ON a.act_codigo = av.act_codigo
WHERE a.act_estado IN (4,10,14,11,12,13,45,1,3,8,7,17,2,5);
--Agrega los LEFT JOIN y Filtros:
SELECT a.act_estado, av.avi_estado
FROM estructura_poa.poas_objetivos po
LEFT JOIN estructura_poa.objetivos_area_unidad oau ON po.pobj_codigo = oau.pobj_codigo
LEFT JOIN estructura_poa.actividades a ON po.pobj_codigo = a.pobj_codigo AND a.act_estado IN (4,10,14,11,12,13,45,1,3,8,7,17,2,5)
LEFT JOIN estructura_poa.actividades_viaticos av ON a.act_codigo = av.act_codigo AND av.avi_estado IN (4,10,14,11,12,13,45,1,3,8,7,17,2,5)
WHERE oau.oau_estado != 0 AND po.poa_codigo IN (3) AND po.pobj_estado IN (2,8);
--Aplica el GROUP BY y usa COUNT para ver la cantidad de actividades y viáticos:
SELECT
   a.act_estado,
   av.avi_estado,
   COALESCE(COUNT(DISTINCT a.act_codigo), 0) AS cantidad_actividades,
   COALESCE(COUNT(DISTINCT av.avi_codigo), 0) AS cantidad_viaticos
FROM estructura_poa.actividades a
LEFT JOIN estructura_poa.actividades_viaticos av ON a.act_codigo = av.act_codigo
WHERE a.act_estado IN (4,10,14,11,12,13,45,1,3,8,7,17,2,5)
GROUP BY a.act_estado, av.avi_estado;
--Finalmente, añade la ordenación con array_position:
SELECT
   a.act_estado,
   av.avi_estado,
   COALESCE(COUNT(DISTINCT a.act_codigo), 0) AS cantidad_actividades,
   COALESCE(COUNT(DISTINCT av.avi_codigo), 0) AS cantidad_viaticos
FROM estructura_poa.actividades a
LEFT JOIN estructura_poa.actividades_viaticos av ON a.act_codigo = av.act_codigo
WHERE a.act_estado IN (4,10,14,11,12,13,45,1,3,8,7,17,2,5)
GROUP BY a.act_estado, av.avi_estado
ORDER BY array_position(array[4,10,14,11,12,13,45,1,3,8,7,17,2,5], av.avi_estado),
         array_position(array[4,10,14,11,12,13,45,1,3,8,7,17,2,5], a.act_estado);






