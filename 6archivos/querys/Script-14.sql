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
		
		AND a.act_codigo IN (1348);
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
WHERE 	asi.asi_codigo IN (1409, 136, 2055); -- Sustituye los códigos por los que desees filtrar
--
SELECT	*
FROM 	ejecucion_poa.asignaciones_cargos_item aci
WHERE 	TRUE
		AND aci.asi_codigo = :asi_codigo
		AND aci.cit_codigo IN (
            SELECT 	ci.cit_codigo
            FROM 	estructura_organizacional.cargos_items ci
            WHERE   TRUE
                    AND ci.cit_codigo IN (
                    						SELECT 	cit_codigo
                                            FROM 	estructura_organizacional.cargos_items_persona cip
                                            WHERE 	cip.per_codigo IN (
                                            							SELECT	per_codigo
                                                        				FROM 	estructura_organizacional.cargos_items_persona cip
                                                        				WHERE 	cip.cit_codigo = :cit_codigo
                                                    				  )
                                         )
  							   );
--
SELECT 	*
FROM 	ejecucion_actividades.inicios_actividades ia;
--
WITH 
cargos_items_persona AS (
    SELECT 	per_codigo
    FROM 	estructura_organizacional.cargos_items_persona
    WHERE 	TRUE
--    		AND cit_codigo = :cit_codigo
),
cargos_items_filtrados AS (
    SELECT 	cit_codigo
    FROM 	estructura_organizacional.cargos_items_persona cip
    WHERE 	cip.per_codigo IN (
        		SELECT per_codigo
        		FROM cargos_items_persona
    		)
),
cargos_items AS (
    SELECT 	cit_codigo
    FROM 	estructura_organizacional.cargos_items ci
    WHERE 	ci.cit_codigo IN (
        		SELECT 	cit_codigo
        		FROM 	cargos_items_filtrados
    		)
)
SELECT 	*
FROM 	ejecucion_poa.asignaciones_cargos_item aci
WHERE 	TRUE
		AND aci.aci_estado NOT IN (0,5,9)
  		AND aci.asi_codigo = :asi_codigo
  		AND aci.cit_codigo IN (
      		SELECT 	cit_codigo
      		FROM 	cargos_items
  		)
;
