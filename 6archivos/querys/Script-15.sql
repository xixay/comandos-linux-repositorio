--################# BASE ########################33
SELECT	
		a.act_codigo, a.act_numero, a.ttr_codigo, a.act_estado, -- ACTIVIDAD
		iap.tia_codigo, iap.iap_codigo,  iap.iap_estado, -- INICIO-ACTIVIDAD-POA
		ia.iac_codigo, ia.iac_codigo_control, ia.iac_correlativo ,ia.iac_estado, -- INICIOS-ACTIVIDADES
		asi.asi_codigo, asi.asi_estado,-- asi.asi_detalle_asignaciones_cargos_items, asi.asi_detalle_asignaciones_horas_usadas, asi.asi_detalle_reposicion_cargos_item,  -- ASIGNACION
		aci.aci_codigo,  aci.aci_estado,aci.aci_horas , -- ASIGNACION-CARGOS-ITEM
		iai.iai_codigo, iai.iai_estado, ---INICIOS ACTIVIDADES INFORMES 
		i.inf_codigo, i.inf_estado , i.iac_codigo AS iac_codigo_inf, ---INFORMES
		iei.iua_codigo, iu.iua_estado 
FROM	estructura_poa.actividades a
		LEFT JOIN ejecucion_actividades.inicio_actividad_poa iap ON a.act_codigo = iap.act_codigo --AND iap.iap_estado NOT IN (5)
		LEFT JOIN ejecucion_actividades.inicios_actividades ia ON iap.iac_codigo = ia.iac_codigo 
		LEFT JOIN ejecucion_actividades.inicio_actividad_informe iai ON ia.iac_codigo = iai.iac_codigo
		LEFT JOIN ejecucion_actividades.informes i ON iai.inf_codigo = i.inf_codigo 
		LEFT JOIN ejecucion_informes.informes_uai iu ON iu.act_codigo = a.act_codigo 
		LEFT JOIN ejecucion_actividades.inicio_actividad_poa_asignaciones iapa ON iap.iap_codigo = iapa.iap_codigo
		LEFT JOIN ejecucion_poa.asignaciones asi ON iapa.asi_codigo = asi.asi_codigo
		LEFT JOIN ejecucion_poa.asignaciones_cargos_item aci ON asi.asi_codigo = aci.asi_codigo 
		LEFT JOIN ejecucion_informes.inicio_evaluacion_informe iei ON iei.iua_codigo = iu.iua_codigo  
WHERE	TRUE
		AND aci.cit_codigo IN (5)
--		AND a.act_codigo IN (1409)
;
--############################################################################3333
	        SELECT
              a.act_codigo,
              COALESCE(SUM(inicio_auditoria.horas_auditorias), 0) AS horas_auditorias,
              COALESCE(SUM(inicio_evaluacion.horas_evaluaciones), 0) AS horas_evaluaciones,
              COALESCE(SUM(inicio_apoyos.horas_apoyos), 0) AS horas_apoyos,
              COALESCE(SUM(inicio_auditoria.horas_auditorias), 0) + COALESCE(SUM(inicio_evaluacion.horas_evaluaciones), 0) + COALESCE(SUM(inicio_apoyos.horas_apoyos), 0) AS horas_comision
        FROM 	estructura_poa.actividades a
              LEFT JOIN (
                SELECT
                      iap.act_codigo,
                      SUM(aci.aci_horas) AS horas_auditorias
                FROM	ejecucion_actividades.inicio_actividad_poa iap
                      LEFT JOIN ejecucion_actividades.inicio_actividad_poa_asignaciones iapa ON iap.iap_codigo = iapa.iap_codigo
                      LEFT JOIN ejecucion_poa.asignaciones asi ON iapa.asi_codigo = asi.asi_codigo AND asi.asi_estado NOT IN (0, 5, 9)
                      LEFT JOIN ejecucion_poa.asignaciones_cargos_item aci ON asi.asi_codigo = aci.asi_codigo AND aci.aci_estado NOT IN (0, 5, 9)
                WHERE	iap.iap_estado NOT IN (0, 5, 9)
                GROUP BY iap.act_codigo
              ) inicio_auditoria ON a.act_codigo = inicio_auditoria.act_codigo
              LEFT JOIN (
                SELECT
                      iu.act_codigo,
                      SUM(aci.aci_horas) AS horas_evaluaciones
                FROM	ejecucion_informes.informes_uai iu
                      LEFT JOIN ejecucion_informes.inicio_evaluacion_informe iei ON iu.iua_codigo = iei.iua_codigo AND iei.iei_estado NOT IN (0, 5, 9)
                      LEFT JOIN ejecucion_informes.inicio_evaluacion_informe_asignaciones ieia ON iei.iei_codigo = ieia.iei_codigo
                      LEFT JOIN ejecucion_poa.asignaciones asi ON ieia.asi_codigo = asi.asi_codigo AND asi.asi_estado NOT IN (0, 5, 9)
                      LEFT JOIN ejecucion_poa.asignaciones_cargos_item aci ON asi.asi_codigo = aci.asi_codigo AND aci.aci_estado NOT IN (0, 5, 9)
                WHERE	iu.iua_estado NOT IN (0, 5, 9)
                GROUP BY iu.act_codigo
              ) inicio_evaluacion ON a.act_codigo = inicio_evaluacion.act_codigo
              LEFT JOIN (
                SELECT
                      aiap.act_codigo,
                      SUM(aci.aci_horas) AS horas_apoyos
                FROM	ejecucion_actividades.apoyo_inicio_actividad_poa aiap
                      LEFT JOIN ejecucion_poa.asignaciones asi ON aiap.asi_codigo = asi.asi_codigo
                      LEFT JOIN ejecucion_poa.asignaciones_cargos_item aci ON asi.asi_codigo = aci.asi_codigo AND aci.aci_estado NOT IN (0, 5, 9)
                WHERE	TRUE
                      AND aiap.aiap_estado NOT IN (0,5,9)
                GROUP BY aiap.act_codigo
              ) inicio_apoyos ON a.act_codigo = inicio_apoyos.act_codigo
        WHERE	TRUE
              AND a.act_codigo IN (:act_codigo)
        GROUP BY a.act_codigo
        ;
--UNO
WITH 
inicio_auditoria AS 
(
SELECT 	
		iap.iap_codigo, iap.iap_estado,
		a.act_codigo, a.act_estado,
		iapa.iapa_codigo, iapa.iapa_estado,
		asi.asi_codigo, asi.asi_estado
FROM 	ejecucion_actividades.inicio_actividad_poa iap
		LEFT JOIN estructura_poa.actividades a ON iap.act_codigo = a.act_codigo
		LEFT JOIN ejecucion_actividades.inicio_actividad_poa_asignaciones iapa ON iap.iap_codigo = iapa.iap_codigo
		LEFT JOIN ejec10ucion_poa.asignaciones asi ON iapa.asi_codigo = asi.asi_codigo
)
SELECT 	* 
FROM 	inicio_auditoria
WHERE 	TRUE
		AND inicio_auditoria.iap_estado IN (2)
		--AND inicio_auditoria.asi_codigo IN (7)
		AND inicio_auditoria.act_codigo IN (3176)
;
--################### inicio_auditoria ######################
SELECT 	
		asi.asi_codigo, asi.asi_estado,
		inicio_auditoria.iap_codigo, inicio_auditoria.ttr_codigo
FROM 	ejecucion_poa.asignaciones asi
		LEFT JOIN (
			SELECT 	
					iap.iap_codigo, iap.iap_estado,
					iapa.iapa_codigo, iapa.iapa_estado, iapa.asi_codigo,
					a.ttr_codigo
			FROM 	ejecucion_actividades.inicio_actividad_poa iap
					LEFT JOIN ejecucion_actividades.inicio_actividad_poa_asignaciones iapa ON iap.iap_codigo = iapa.iap_codigo
					LEFT JOIN estructura_poa.actividades a ON iap.act_codigo = a.act_codigo
			WHERE 	iap.iap_estado IN (2)
		) inicio_auditoria ON asi.asi_codigo = inicio_auditoria.asi_codigo
WHERE 	asi.asi_codigo IN (1409)
;
--################### inicio_evaluacion ######################
SELECT 	
		asi.asi_codigo, asi.asi_estado,
		inicio_evaluacion.iua_codigo, inicio_evaluacion.iua_fecha, inicio_evaluacion.iua_fecha_inicio_evaluacion, inicio_evaluacion.ttr_codigo
FROM 	ejecucion_poa.asignaciones asi
		LEFT JOIN (
			SELECT 	
					iu.iua_codigo, iu.iua_estado,iu.iua_fecha,iu.iua_fecha_inicio_evaluacion,
					a.ttr_codigo,	
					iei.iei_codigo, iei.iei_estado,
					ieia.ieia_codigo, ieia.ieia_estado, ieia.asi_codigo
			FROM 	ejecucion_informes.informes_uai iu
					LEFT JOIN estructura_poa.actividades a ON iu.act_codigo = a.act_codigo
					LEFT JOIN ejecucion_informes.inicio_evaluacion_informe iei ON iu.iua_codigo = iei.iua_codigo
					LEFT JOIN ejecucion_informes.inicio_evaluacion_informe_asignaciones ieia ON iei.iei_codigo = ieia.iei_codigo
			WHERE	iu.iua_estado IN (22)
		) inicio_evaluacion ON asi.asi_codigo = inicio_evaluacion.asi_codigo
WHERE 	asi.asi_codigo IN (136)
;
--################### inicio_apoyos ######################
SELECT 	asi.asi_codigo, asi.asi_estado,
		inicio_apoyos.aiap_codigo, inicio_apoyos.ttr_codigo
FROM	ejecucion_poa.asignaciones asi
		LEFT JOIN (
			SELECT	aiap.aiap_codigo, aiap.aiap_estado, aiap.asi_codigo,
					a.ttr_codigo
			FROM	ejecucion_actividades.apoyo_inicio_actividad_poa aiap
					LEFT JOIN estructura_poa.actividades a ON aiap.act_codigo = a.act_codigo
			WHERE 	aiap.aiap_estado IN (2)
		) inicio_apoyos ON asi.asi_codigo = inicio_apoyos.asi_codigo
WHERE 	asi.asi_codigo IN (2055)
;
--##########################################################3333
SELECT 	iu.iua_codigo, iu.iua_estado 
FROM 	ejecucion_informes.informes_uai iu ;

SELECT
		asi.asi_codigo,
		asi.asi_estado,
		COALESCE(inicio_auditoria.ttr_codigo, inicio_evaluacion.ttr_codigo, inicio_apoyos.ttr_codigo) AS ttr_codigo,
		COALESCE(inicio_auditoria.fecha_inicio_po, inicio_evaluacion.fecha_inicio_po, inicio_apoyos.fecha_inicio_po) AS fecha_inicio_po,
		COALESCE(inicio_auditoria.fecha_inicio, inicio_evaluacion.fecha_inicio, inicio_apoyos.fecha_inicio) AS fecha_inicio		
FROM 	ejecucion_poa.asignaciones asi
		LEFT JOIN (
		    SELECT
					iap.iap_codigo,
					iapa.asi_codigo,
					TO_CHAR(a.act_fecha_inicio, 'dd/mm/yyyy') AS fecha_inicio_po,
					TO_CHAR(ia.iac_fecha_inicio, 'dd/mm/yyyy') AS fecha_inicio,
					a.ttr_codigo
		    FROM 	ejecucion_actividades.inicio_actividad_poa iap
		    		LEFT JOIN ejecucion_actividades.inicios_actividades ia ON iap.iac_codigo = ia.iac_codigo
		    		LEFT JOIN ejecucion_actividades.inicio_actividad_poa_asignaciones iapa ON iap.iap_codigo = iapa.iap_codigo
		    		LEFT JOIN ejecucion_poa.asignaciones_cargos_item aci ON iapa.asi_codigo = aci.asi_codigo AND aci.aci_estado NOT IN (0,5,9)
		    		LEFT JOIN estructura_poa.actividades a ON iap.act_codigo = a.act_codigo
		    WHERE 	iap.iap_estado IN (2)
		) inicio_auditoria ON asi.asi_codigo = inicio_auditoria.asi_codigo
		LEFT JOIN (
		    SELECT
		        	iu.iua_codigo,
		        	TO_CHAR(iu.iua_fecha, 'dd/mm/yyyy') AS fecha_inicio_po,
		        	TO_CHAR(iu.iua_fecha_inicio_evaluacion, 'dd/mm/yyyy') AS fecha_inicio,
			        a.ttr_codigo,
			        ieia.asi_codigo
		    FROM 	ejecucion_informes.informes_uai iu
		    		LEFT JOIN estructura_poa.actividades a ON iu.act_codigo = a.act_codigo
		    		LEFT JOIN ejecucion_informes.inicio_evaluacion_informe iei ON iu.iua_codigo = iei.iua_codigo
		    		LEFT JOIN ejecucion_informes.inicio_evaluacion_informe_asignaciones ieia ON iei.iei_codigo = ieia.iei_codigo
		    WHERE 	iu.iua_estado IN (22)
		) inicio_evaluacion ON asi.asi_codigo = inicio_evaluacion.asi_codigo
		LEFT JOIN (
		    SELECT
		        	aiap.aiap_codigo,
		        	aiap.asi_codigo,
		        	TO_CHAR(a.act_fecha_inicio, 'dd/mm/yyyy') AS fecha_inicio_po,
					TO_CHAR(ia.iac_fecha_inicio, 'dd/mm/yyyy') AS fecha_inicio,
		        	a.ttr_codigo
		    FROM 	ejecucion_actividades.apoyo_inicio_actividad_poa aiap
		    		LEFT JOIN ejecucion_actividades.inicios_actividades ia ON aiap.iac_codigo = ia.iac_codigo
		    		LEFT JOIN estructura_poa.actividades a ON aiap.act_codigo = a.act_codigo
		    WHERE 	aiap.aiap_estado IN (2)
		) inicio_apoyos ON asi.asi_codigo = inicio_apoyos.asi_codigo
WHERE 	TRUE
		AND asi.asi_codigo IN (1476)
--		AND asi.asi_codigo IN (1409, 136, 2055); -- Sustituye los códigos por los que desees filtrar
;
--
SELECT  a.asi_codigo, a.asi_estado,
		t.aci_codigo, t.aci_estado,t.aci_horas,t.per_codigo,
		ci.cit_codigo, ci.cit_estado, ci.aun_codigo,
		ahu.ahu_codigo,ahu.ahu_estado,ahu.ahu_horas, ahu.ahu_fecha,
		a2.act_codigo, a2.act_numero, au.aun_sigla
FROM 	ejecucion_poa.asignaciones a
		LEFT JOIN ejecucion_actividades.inicio_actividad_poa_asignaciones iapa ON a.asi_codigo = iapa.asi_codigo
		LEFT JOIN ejecucion_actividades.inicio_actividad_poa iap ON iapa.iap_codigo = iap.iap_codigo
		LEFT JOIN estructura_poa.actividades a2 ON iap.act_codigo = a2.act_codigo
		LEFT JOIN estructura_organizacional.areas_unidades au ON a2.aun_codigo_ejecutora = au.aun_codigo
		LEFT JOIN ejecucion_poa.asignaciones_cargos_item t ON a.asi_codigo = t.asi_codigo AND t.aci_estado NOT IN (0,5,9)
		LEFT JOIN estructura_organizacional.cargos_items ci ON t.cit_codigo = ci.cit_codigo AND ci.cit_estado NOT IN (0,5,9)
		LEFT JOIN ejecucion_poa.asignaciones_horas_usadas ahu ON t.aci_codigo = ahu.aci_codigo AND ahu.ahu_estado NOT IN (0,5,9)
WHERE 	ci.aun_codigo IN (56)
		AND ci.cit_codigo IN (2)
		AND a.asi_codigo IN (1476)
		AND a.asi_estado NOT IN (0,5,9)
		AND a2.act_codigo IS NOT NULL
UNION ALL
SELECT  a.asi_codigo, a.asi_estado,
		t.aci_codigo, t.aci_estado,t.aci_horas,t.per_codigo,
		ci.cit_codigo, ci.cit_estado, ci.aun_codigo,
		ahu.ahu_codigo,ahu.ahu_estado,ahu.ahu_horas, ahu.ahu_fecha,
		a2.act_codigo, a2.act_numero, au.aun_sigla
FROM 	ejecucion_poa.asignaciones a
		LEFT JOIN ejecucion_informes.inicio_evaluacion_informe_asignaciones ieia ON a.asi_codigo = ieia.asi_codigo
		LEFT JOIN ejecucion_informes.inicio_evaluacion_informe iei ON ieia.iei_codigo = iei.iei_codigo
		LEFT JOIN ejecucion_informes.informes_uai iu ON iei.iua_codigo = iu.iua_codigo
		LEFT JOIN estructura_poa.actividades a2 ON iu.act_codigo = a2.act_codigo
		LEFT JOIN estructura_organizacional.areas_unidades au ON a2.aun_codigo_ejecutora = au.aun_codigo
		LEFT JOIN ejecucion_poa.asignaciones_cargos_item t ON a.asi_codigo = t.asi_codigo AND t.aci_estado NOT IN (0,5,9)
		LEFT JOIN estructura_organizacional.cargos_items ci ON t.cit_codigo = ci.cit_codigo AND ci.cit_estado NOT IN (0,5,9)
		LEFT JOIN ejecucion_poa.asignaciones_horas_usadas ahu ON t.aci_codigo = ahu.aci_codigo AND ahu.ahu_estado NOT IN (0,5,9)
WHERE 	ci.aun_codigo IN (56)
		AND ci.cit_codigo IN (2)
		AND a.asi_codigo IN (1476)
		AND a.asi_estado NOT IN (0,5,9)
		AND a2.act_codigo IS NOT NULL
;
--##########################################################################################################
WITH inicio_auditoria AS (
    SELECT 
        a.asi_codigo, 
        a.asi_estado,
        t.aci_codigo, 
        t.aci_estado,
        t.aci_horas,
        t.per_codigo,
        ci.cit_codigo, 
        ci.cit_estado, 
        ci.aun_codigo,
        ahu.ahu_codigo,
        ahu.ahu_estado, 
        ahu.ahu_horas, 
        ahu.ahu_fecha,
        a2.act_codigo, 
        a2.act_numero, 
        au.aun_sigla
    FROM ejecucion_poa.asignaciones a
    LEFT JOIN ejecucion_actividades.inicio_actividad_poa_asignaciones iapa ON a.asi_codigo = iapa.asi_codigo
    LEFT JOIN ejecucion_actividades.inicio_actividad_poa iap ON iapa.iap_codigo = iap.iap_codigo
    LEFT JOIN estructura_poa.actividades a2 ON iap.act_codigo = a2.act_codigo
    LEFT JOIN estructura_organizacional.areas_unidades au ON a2.aun_codigo_ejecutora = au.aun_codigo
    LEFT JOIN ejecucion_poa.asignaciones_cargos_item t ON a.asi_codigo = t.asi_codigo AND t.aci_estado NOT IN (0,5,9)
    LEFT JOIN estructura_organizacional.cargos_items ci ON t.cit_codigo = ci.cit_codigo AND ci.cit_estado NOT IN (0,5,9)
    LEFT JOIN ejecucion_poa.asignaciones_horas_usadas ahu ON t.aci_codigo = ahu.aci_codigo AND ahu.ahu_estado NOT IN (0,5,9)
    WHERE 
        ci.aun_codigo IN (56)
        AND ci.cit_codigo IN (2)
        AND a.asi_codigo IN (1476)
        AND a.asi_estado NOT IN (0,5,9)
        AND a2.act_codigo IS NOT NULL
),
inicio_evaluacion AS (
    SELECT 
        a.asi_codigo, 
        a.asi_estado,
        t.aci_codigo, 
        t.aci_estado,
        t.aci_horas,
        t.per_codigo,
        ci.cit_codigo, 
        ci.cit_estado, 
        ci.aun_codigo,
        ahu.ahu_codigo,
        ahu.ahu_estado, 
        ahu.ahu_horas, 
        ahu.ahu_fecha,
        a2.act_codigo, 
        a2.act_numero, 
        au.aun_sigla
    FROM ejecucion_poa.asignaciones a
    LEFT JOIN ejecucion_informes.inicio_evaluacion_informe_asignaciones ieia ON a.asi_codigo = ieia.asi_codigo
    LEFT JOIN ejecucion_informes.inicio_evaluacion_informe iei ON ieia.iei_codigo = iei.iei_codigo
    LEFT JOIN ejecucion_informes.informes_uai iu ON iei.iua_codigo = iu.iua_codigo
    LEFT JOIN estructura_poa.actividades a2 ON iu.act_codigo = a2.act_codigo
    LEFT JOIN estructura_organizacional.areas_unidades au ON a2.aun_codigo_ejecutora = au.aun_codigo
    LEFT JOIN ejecucion_poa.asignaciones_cargos_item t ON a.asi_codigo = t.asi_codigo AND t.aci_estado NOT IN (0,5,9)
    LEFT JOIN estructura_organizacional.cargos_items ci ON t.cit_codigo = ci.cit_codigo AND ci.cit_estado NOT IN (0,5,9)
    LEFT JOIN ejecucion_poa.asignaciones_horas_usadas ahu ON t.aci_codigo = ahu.aci_codigo AND ahu.ahu_estado NOT IN (0,5,9)
    WHERE 
        ci.aun_codigo IN (56)
        AND ci.cit_codigo IN (2)
        AND a.asi_codigo IN (1476)
        AND a.asi_estado NOT IN (0,5,9)
        AND a2.act_codigo IS NOT NULL
)
SELECT 
    a.asi_codigo, 
    a.asi_estado,
    COALESCE(ia.aci_codigo, ie.aci_codigo) AS aci_codigo,
    COALESCE(ia.aci_estado, ie.aci_estado) AS aci_estado,
    COALESCE(ia.aci_horas, ie.aci_horas) AS aci_horas,
    COALESCE(ia.per_codigo, ie.per_codigo) AS per_codigo,
    COALESCE(ia.cit_codigo, ie.cit_codigo) AS cit_codigo,
    COALESCE(ia.cit_estado, ie.cit_estado) AS cit_estado,
    COALESCE(ia.aun_codigo, ie.aun_codigo) AS aun_codigo,
    COALESCE(ia.ahu_codigo, ie.ahu_codigo) AS ahu_codigo,
    COALESCE(ia.ahu_estado, ie.ahu_estado) AS ahu_estado,
    COALESCE(ia.ahu_horas, ie.ahu_horas) AS ahu_horas,
    COALESCE(ia.ahu_fecha, ie.ahu_fecha) AS ahu_fecha,
    COALESCE(ia.act_codigo, ie.act_codigo) AS act_codigo,
    COALESCE(ia.act_numero, ie.act_numero) AS act_numero,
    COALESCE(ia.aun_sigla, ie.aun_sigla) AS aun_sigla
FROM ejecucion_poa.asignaciones a
LEFT JOIN inicio_auditoria ia ON a.asi_codigo = ia.asi_codigo
LEFT JOIN inicio_evaluacion ie ON a.asi_codigo = ie.asi_codigo
WHERE TRUE
;
		AND a.asi_codigo IN (1476);
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
WITH inicio_auditoria AS (
    SELECT 
        a.asi_codigo, 
        a.asi_estado,
        t.aci_codigo, 
        t.aci_estado,
        t.aci_horas,
        t.per_codigo,
        ci.cit_codigo, 
        ci.cit_estado, 
        ci.aun_codigo,
        ahu.ahu_codigo,
        ahu.ahu_estado, 
        ahu.ahu_horas, 
        ahu.ahu_fecha,
        a2.act_codigo, 
        a2.act_numero, 
        au.aun_sigla
    FROM ejecucion_poa.asignaciones a
    LEFT JOIN ejecucion_actividades.inicio_actividad_poa_asignaciones iapa ON a.asi_codigo = iapa.asi_codigo
    LEFT JOIN ejecucion_actividades.inicio_actividad_poa iap ON iapa.iap_codigo = iap.iap_codigo
    LEFT JOIN estructura_poa.actividades a2 ON iap.act_codigo = a2.act_codigo
    LEFT JOIN estructura_organizacional.areas_unidades au ON a2.aun_codigo_ejecutora = au.aun_codigo
    LEFT JOIN ejecucion_poa.asignaciones_cargos_item t ON a.asi_codigo = t.asi_codigo AND t.aci_estado NOT IN (0,5,9)
    LEFT JOIN estructura_organizacional.cargos_items ci ON t.cit_codigo = ci.cit_codigo AND ci.cit_estado NOT IN (0,5,9)
    LEFT JOIN ejecucion_poa.asignaciones_horas_usadas ahu ON t.aci_codigo = ahu.aci_codigo AND ahu.ahu_estado NOT IN (0,5,9)
    WHERE 
        ci.aun_codigo = 56
        AND ci.cit_codigo = 2
        AND a.asi_estado NOT IN (0,5,9)
        AND a2.act_codigo IS NOT NULL
),
inicio_evaluacion AS (
    SELECT 
        a.asi_codigo, 
        a.asi_estado,
        t.aci_codigo, 
        t.aci_estado,
        t.aci_horas,
        t.per_codigo,
        ci.cit_codigo, 
        ci.cit_estado, 
        ci.aun_codigo,
        ahu.ahu_codigo,
        ahu.ahu_estado, 
        ahu.ahu_horas, 
        ahu.ahu_fecha,
        a2.act_codigo, 
        a2.act_numero, 
        au.aun_sigla
    FROM ejecucion_poa.asignaciones a
    LEFT JOIN ejecucion_informes.inicio_evaluacion_informe_asignaciones ieia ON a.asi_codigo = ieia.asi_codigo
    LEFT JOIN ejecucion_informes.inicio_evaluacion_informe iei ON ieia.iei_codigo = iei.iei_codigo
    LEFT JOIN ejecucion_informes.informes_uai iu ON iei.iua_codigo = iu.iua_codigo
    LEFT JOIN estructura_poa.actividades a2 ON iu.act_codigo = a2.act_codigo
    LEFT JOIN estructura_organizacional.areas_unidades au ON a2.aun_codigo_ejecutora = au.aun_codigo
    LEFT JOIN ejecucion_poa.asignaciones_cargos_item t ON a.asi_codigo = t.asi_codigo AND t.aci_estado NOT IN (0,5,9)
    LEFT JOIN estructura_organizacional.cargos_items ci ON t.cit_codigo = ci.cit_codigo AND ci.cit_estado NOT IN (0,5,9)
    LEFT JOIN ejecucion_poa.asignaciones_horas_usadas ahu ON t.aci_codigo = ahu.aci_codigo AND ahu.ahu_estado NOT IN (0,5,9)
    WHERE 
        ci.aun_codigo = 56
        AND ci.cit_codigo = 2
        AND a.asi_estado NOT IN (0,5,9)
        AND a2.act_codigo IS NOT NULL
),
inicio_apoyos AS (
    SELECT 
        a.asi_codigo, 
        a.asi_estado,
        t.aci_codigo, 
        t.aci_estado,
        t.aci_horas,
        t.per_codigo,
        ci.cit_codigo, 
        ci.cit_estado, 
        ci.aun_codigo,
        ahu.ahu_codigo,
        ahu.ahu_estado, 
        ahu.ahu_horas, 
        ahu.ahu_fecha,
        a2.act_codigo, 
        a2.act_numero, 
        au.aun_sigla
    FROM ejecucion_poa.asignaciones a
    LEFT JOIN ejecucion_actividades.apoyo_inicio_actividad_poa aiap ON aiap.asi_codigo = a.asi_codigo
    LEFT JOIN ejecucion_actividades.inicios_actividades ia ON aiap.iac_codigo = ia.iac_codigo
    LEFT JOIN estructura_poa.actividades a2 ON aiap.act_codigo = a2.act_codigo
	LEFT JOIN estructura_organizacional.areas_unidades au ON a2.aun_codigo_ejecutora = au.aun_codigo
    LEFT JOIN ejecucion_poa.asignaciones_cargos_item t ON a.asi_codigo = t.asi_codigo AND t.aci_estado NOT IN (0,5,9)
    LEFT JOIN estructura_organizacional.cargos_items ci ON t.cit_codigo = ci.cit_codigo AND ci.cit_estado NOT IN (0,5,9)
    LEFT JOIN ejecucion_poa.asignaciones_horas_usadas ahu ON t.aci_codigo = ahu.aci_codigo AND ahu.ahu_estado NOT IN (0,5,9)
    WHERE 
        ci.aun_codigo = 56
        AND ci.cit_codigo = 2
        AND a.asi_estado NOT IN (0,5,9)
        AND a2.act_codigo IS NOT NULL
)
SELECT 
    COALESCE(ia.asi_codigo, ie.asi_codigo) AS asi_codigo,
    COALESCE(ia.asi_estado, ie.asi_estado) AS asi_estado,
    COALESCE(ia.aci_codigo, ie.aci_codigo) AS aci_codigo,
    COALESCE(ia.aci_estado, ie.aci_estado) AS aci_estado,
    COALESCE(ia.aci_horas, ie.aci_horas) AS aci_horas,
    COALESCE(ia.per_codigo, ie.per_codigo) AS per_codigo,
    COALESCE(ia.cit_codigo, ie.cit_codigo) AS cit_codigo,
    COALESCE(ia.cit_estado, ie.cit_estado) AS cit_estado,
    COALESCE(ia.aun_codigo, ie.aun_codigo) AS aun_codigo,
    COALESCE(ia.ahu_codigo, ie.ahu_codigo) AS ahu_codigo,
    COALESCE(ia.ahu_estado, ie.ahu_estado) AS ahu_estado,
    COALESCE(ia.ahu_horas, ie.ahu_horas) AS ahu_horas,
    COALESCE(ia.ahu_fecha, ie.ahu_fecha) AS ahu_fecha,
    COALESCE(ia.act_codigo, ie.act_codigo) AS act_codigo,
    COALESCE(ia.act_numero, ie.act_numero) AS act_numero,
    COALESCE(ia.aun_sigla, ie.aun_sigla) AS aun_sigla
FROM inicio_auditoria ia
FULL OUTER JOIN inicio_evaluacion ie ON ia.asi_codigo = ie.asi_codigo;
--
      WITH inicio_auditoria AS (
          SELECT
                a.asi_codigo,
                a.asi_estado,
                t.aci_codigo,
                t.aci_estado,
                t.aci_horas,
                t.per_codigo,
                ci.cit_codigo,
                ci.cit_estado,
                ci.aun_codigo,
                ahu.ahu_codigo,
                ahu.ahu_estado,
                ahu.ahu_horas,
                ahu.ahu_fecha,
                a2.act_codigo,
                a2.act_numero,
                au.aun_sigla
          FROM  ejecucion_poa.asignaciones a
                LEFT JOIN ejecucion_actividades.inicio_actividad_poa_asignaciones iapa ON a.asi_codigo = iapa.asi_codigo
                LEFT JOIN ejecucion_actividades.inicio_actividad_poa iap ON iapa.iap_codigo = iap.iap_codigo
                LEFT JOIN estructura_poa.actividades a2 ON iap.act_codigo = a2.act_codigo
                LEFT JOIN estructura_organizacional.areas_unidades au ON a2.aun_codigo_ejecutora = au.aun_codigo
                LEFT JOIN ejecucion_poa.asignaciones_cargos_item t ON a.asi_codigo = t.asi_codigo AND t.aci_estado NOT IN (0,5,9)
                LEFT JOIN estructura_organizacional.cargos_items ci ON t.cit_codigo = ci.cit_codigo AND ci.cit_estado NOT IN (0,5,9)
                LEFT JOIN ejecucion_poa.asignaciones_horas_usadas ahu ON t.aci_codigo = ahu.aci_codigo AND ahu.ahu_estado NOT IN (0,5,9)
          WHERE
                ci.aun_codigo IN (56)
                AND ci.cit_codigo IN (2)
                AND a.asi_estado NOT IN (0,5,9)
                AND a2.act_codigo IS NOT NULL
      ),
      inicio_evaluacion AS (
          SELECT
                a.asi_codigo,
                a.asi_estado,
                t.aci_codigo,
                t.aci_estado,
                t.aci_horas,
                t.per_codigo,
                ci.cit_codigo,
                ci.cit_estado,
                ci.aun_codigo,
                ahu.ahu_codigo,
                ahu.ahu_estado,
                ahu.ahu_horas,
                ahu.ahu_fecha,
                a2.act_codigo,
                a2.act_numero,
                au.aun_sigla
          FROM  ejecucion_poa.asignaciones a
                LEFT JOIN ejecucion_informes.inicio_evaluacion_informe_asignaciones ieia ON a.asi_codigo = ieia.asi_codigo
                LEFT JOIN ejecucion_informes.inicio_evaluacion_informe iei ON ieia.iei_codigo = iei.iei_codigo
                LEFT JOIN ejecucion_informes.informes_uai iu ON iei.iua_codigo = iu.iua_codigo
                LEFT JOIN estructura_poa.actividades a2 ON iu.act_codigo = a2.act_codigo
                LEFT JOIN estructura_organizacional.areas_unidades au ON a2.aun_codigo_ejecutora = au.aun_codigo
                LEFT JOIN ejecucion_poa.asignaciones_cargos_item t ON a.asi_codigo = t.asi_codigo AND t.aci_estado NOT IN (0,5,9)
                LEFT JOIN estructura_organizacional.cargos_items ci ON t.cit_codigo = ci.cit_codigo AND ci.cit_estado NOT IN (0,5,9)
                LEFT JOIN ejecucion_poa.asignaciones_horas_usadas ahu ON t.aci_codigo = ahu.aci_codigo AND ahu.ahu_estado NOT IN (0,5,9)
          WHERE
                ci.aun_codigo IN (56)
                AND ci.cit_codigo IN (2)
                AND a.asi_estado NOT IN (0,5,9)
                AND a2.act_codigo IS NOT NULL
      ),
      inicio_apoyos AS (
          SELECT
                a.asi_codigo,
                a.asi_estado,
                t.aci_codigo,
                t.aci_estado,
                t.aci_horas,
                t.per_codigo,
                ci.cit_codigo,
                ci.cit_estado,
                ci.aun_codigo,
                ahu.ahu_codigo,
                ahu.ahu_estado,
                ahu.ahu_horas,
                ahu.ahu_fecha,
                a2.act_codigo,
                a2.act_numero,
                au.aun_sigla
          FROM  ejecucion_poa.asignaciones a
                LEFT JOIN ejecucion_actividades.apoyo_inicio_actividad_poa aiap ON aiap.asi_codigo = a.asi_codigo
                LEFT JOIN ejecucion_actividades.inicios_actividades ia ON aiap.iac_codigo = ia.iac_codigo
                LEFT JOIN estructura_poa.actividades a2 ON aiap.act_codigo = a2.act_codigo
                LEFT JOIN estructura_organizacional.areas_unidades au ON a2.aun_codigo_ejecutora = au.aun_codigo
                LEFT JOIN ejecucion_poa.asignaciones_cargos_item t ON a.asi_codigo = t.asi_codigo AND t.aci_estado NOT IN (0,5,9)
                LEFT JOIN estructura_organizacional.cargos_items ci ON t.cit_codigo = ci.cit_codigo AND ci.cit_estado NOT IN (0,5,9)
                LEFT JOIN ejecucion_poa.asignaciones_horas_usadas ahu ON t.aci_codigo = ahu.aci_codigo AND ahu.ahu_estado NOT IN (0,5,9)
          WHERE
                ci.aun_codigo IN (56)
                AND ci.cit_codigo IN (2)
                AND a.asi_estado NOT IN (0,5,9)
                AND a2.act_codigo IS NOT NULL
      )
      SELECT
            COALESCE(ia.asi_codigo, ie.asi_codigo) AS asi_codigo,
            COALESCE(ia.asi_estado, ie.asi_estado) AS asi_estado,
            COALESCE(ia.aci_codigo, ie.aci_codigo) AS aci_codigo,
            COALESCE(ia.aci_estado, ie.aci_estado) AS aci_estado,
            COALESCE(ia.aci_horas, ie.aci_horas) AS aci_horas,
            COALESCE(ia.per_codigo, ie.per_codigo) AS per_codigo,
            COALESCE(ia.cit_codigo, ie.cit_codigo) AS cit_codigo,
            COALESCE(ia.cit_estado, ie.cit_estado) AS cit_estado,
            COALESCE(ia.aun_codigo, ie.aun_codigo) AS aun_codigo,
            COALESCE(ia.ahu_codigo, ie.ahu_codigo) AS ahu_codigo,
            COALESCE(ia.ahu_estado, ie.ahu_estado) AS ahu_estado,
            COALESCE(ia.ahu_horas, ie.ahu_horas) AS ahu_horas,
            COALESCE(ia.ahu_fecha, ie.ahu_fecha) AS ahu_fecha,
            COALESCE(ia.act_codigo, ie.act_codigo) AS act_codigo,
            COALESCE(ia.act_numero, ie.act_numero) AS act_numero,
            COALESCE(ia.aun_sigla, ie.aun_sigla) AS aun_sigla
      FROM  inicio_auditoria ia
            FULL OUTER JOIN inicio_evaluacion ie ON ia.asi_codigo = ie.asi_codigo;








