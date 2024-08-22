--Obtiene area_unidad_responsables
SELECT
      au.aun_codigo AS aun_codigo_ejecutora, au.aun_nombre, au.aun_sigla, au.cau_codigo, au.aun_numero,
      CONCAT(au.aun_nombre, ' - ', au.aun_sigla) AS nom_ejecutora,
      au.aun_reporte_habilitado,
      COALESCE(
        ARRAY_AGG(
          DISTINCT aur.rol_codigo ORDER BY aur.rol_codigo ASC
        ) FILTER (WHERE aur.per_codigo = 1262),
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
--&&&&&&&&&&&&&&&&&&&&&&
SELECT
      po.pobj_codigo, po.pobj_estado, pr.pro_numero, au.aun_numero, po.pobj_numero,
      CONCAT(pr.pro_numero, '.', au.aun_numero, '.', po.pobj_numero) AS pobj_codigo_sigla,
      po.pobj_nombre, po.pro_codigo
FROM	estructura_poa.poas_objetivos po
      LEFT JOIN pei.programas pr ON po.pro_codigo = pr.pro_codigo
      LEFT JOIN estructura_poa.objetivos_area_unidad oau ON po.pobj_codigo = oau.pobj_codigo AND oau.oau_estado NOT IN (0)
      LEFT JOIN estructura_organizacional.areas_unidades au ON oau.aun_codigo_ejecutora = au.aun_codigo
WHERE	TRUE
      AND po.poa_codigo IN (3) -- POA-SELECCIONADO
      AND po.pobj_estado IN (2,8) -- ESTADOS
      AND oau.oau_estado IN (2,8) -- ESTADOS
      AND oau.aun_codigo_ejecutora IN (2) -- UNIDAD-EJECUTORA
GROUP BY po.pobj_codigo, pr.pro_numero, po.pobj_numero, po.pobj_nombre, au.aun_numero
;

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

SELECT 	*
FROM 	pei.plan_estrategico_institucional pei 
;

SELECT 	*
FROM 	estructura_poa.area_unidad_responsables aur ;

SELECT 	po.pobj_codigo, po.pobj_nombre, po.pobj_estado ,po.poa_codigo,p2.tpo_codigo ,
		po.cpr_codigo, cp.cpr_numero , 
		cp.pro_codigo AS pro_codigo_cat_pro, cp.cpr_estado,
		po.pro_codigo AS pro_codigo_pobj, p.pro_numero AS pro_numero_pobj,
		po.tacp_codigo, tacp.tacp_descripcion ,tacp.tacp_estado ,
		po.aeg_codigo, aeg.aeg_indicador ,aeg.ges_codigo ,aeg.aeg_estado,
		aeg.aes_codigo, ae.aes_numero ,ae.pro_codigo AS pro_codigo_aes,
		ae.est_codigo , e.est_numero, e.est_estado,
		e.oes_codigo , oe.oes_numero ,oe.oes_estado ,
		oe.dim_codigo ,d.dim_numero ,d.dim_estado ,
		d.pei_codigo, pei.pei_descripcion, pei.ges_codigo_inicio, pei.ges_codigo_final , pei.pei_estado 
FROM 	estructura_poa.poas_objetivos po
		LEFT JOIN estructura_poa.poas p2 ON po.poa_codigo =p2.poa_codigo 
		LEFT JOIN pei.categorias_programaticas cp ON po.cpr_codigo = cp.cpr_codigo 
		LEFT JOIN pei.programas p ON po.pro_codigo = p.pro_codigo 
		LEFT JOIN parametricas.tipo_accion_corto_plazo tacp ON po.tacp_codigo = tacp.tacp_codigo 
		LEFT JOIN pei.acciones_estrategicas_gestiones aeg ON po.aeg_codigo = aeg.aeg_codigo 
		LEFT JOIN pei.acciones_estrategicas ae ON aeg.aes_codigo = ae.aes_codigo
		LEFT JOIN pei.estrategias e ON ae.est_codigo = e.est_codigo 
		LEFT JOIN pei.objetivos_estrategicos oe ON e.oes_codigo = oe.oes_codigo 
		LEFT JOIN pei.dimensiones d ON oe.dim_codigo = d.dim_codigo 
		LEFT JOIN pei.plan_estrategico_institucional pei ON d.pei_codigo = pei.pei_codigo
WHERE 	po.poa_codigo IN (3)
;

SELECT 	*
FROM 	pei.categorias_programaticas cp 
;

SELECT 	*
FROM 	pei.programas p ;

SELECT 	*
FROM 	parametricas.tipo_accion_corto_plazo tacp ;

SELECT 	*
FROM 	pei.acciones_estrategicas_gestiones aeg ;

SELECT 	*
FROM 	pei.acciones_estrategicas ae ;

SELECT 	*
FROM 	pei.estrategias e ;

SELECT 	*
FROM 	pei.objetivos_estrategicos oe ;

SELECT 	*
FROM 	pei.dimensiones d ;

SELECT 	*
FROM 	pei.plan_estrategico_institucional pei ;

po.pobj_codigo, po.pobj_nombre, po.pobj_estado ,po.poa_codigo,
		po.cpr_codigo, cp.cpr_numero , 
		cp.pro_codigo AS pro_codigo_cat_pro, cp.cpr_estado,
		p2.pro_numero AS pro_numero_cat_pro ,p2.pro_estado AS pro_estado_cat_pro,
		po.pro_codigo AS pro_codigo_pobj, p.pro_numero AS pro_numero_pobj,
		po.tacp_codigo, tacp.tacp_descripcion ,tacp.tacp_estado ,
		po.aeg_codigo, aeg.aeg_indicador ,aeg.ges_codigo ,aeg.aeg_estado,
		aeg.aes_codigo, ae.aes_numero ,ae.pro_codigo AS pro_codigo_aes,
		ae.est_codigo , e.est_numero, e.est_estado,
		e.oes_codigo , oe.oes_numero ,oe.oes_estado ,
		oe.dim_codigo ,d.dim_numero ,d.dim_estado ,
		d.pei_codigo, pei.pei_descripcion, pei.ges_codigo_inicio, pei.ges_codigo_final , pei.pei_estado 


