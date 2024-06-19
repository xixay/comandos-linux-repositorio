select 	*
from 	estructura_organizacional.areas_unidades au ;
--TIPOS DE INICIOS DE ACTIVIDADES
select 	*
from 	parametricas.tipos_inicios_actividades tia ;
--TIPOS DE TRABAJO
select	*
from 	parametricas.tipos_trabajos tt ;
--ESPECIFICACION TIPOS DE TRABAJO
select 	*
from 	parametricas.especificacion_tipos_trabajo ett;
--TIPO DE ACTIVIDAD
select 	*
from 	parametricas.tipos_actividades ta ;
-- POA
select 	*  
from 	estructura_poa.poas p
where 	true 
--		and p.poa_estado not in (2,9,0,13)
		and p.poa_codigo in (3)
order by p.poa_codigo desc
limit 5;
-- POA OBJETIVOS
select	*
from 	estructura_poa.poas_objetivos po 
where 	true 
--		and po.pobj_estado not in (2,9,0,13)
--		and po.pobj_estado in (0)
		and po.pobj_codigo in (1181)
order by	po.pobj_codigo desc;
-- VIATICOS
select 	av.avi_codigo ,av.act_codigo, av.avi_estado, av.fecha_registro ,
		au.aun_sigla, a.pobj_codigo, p.poa_codigo  
from 	estructura_poa.actividades_viaticos av
		left join estructura_poa.actividades a on av.act_codigo = a.act_codigo
		left join estructura_poa.poas_objetivos po on a.pobj_codigo = po.pobj_codigo 
		left join estructura_poa.poas p on po.poa_codigo = p.poa_codigo 
		left join estructura_organizacional.areas_unidades au on a.aun_codigo_ejecutora = au.aun_codigo
where 	true 
--		and av.avi_estado in (1)
		and p.poa_codigo in (3)
order by av.avi_codigo desc; 
-- ACTIVIDADES
--select 	*
--select 	a.act_codigo ,a.act_numero ,a.act_descripcion ,a.act_fecha_inicio ,a.act_fecha_fin ,a.act_objeto ,a.ttr_codigo ,a.tipact_codigo,a.cac_codigo 
select 	a.act_codigo ,a.act_numero ,a.cac_codigo ,a.iac_codigo_apoyo, a.act_estado, a.act_descripcion , a.aun_codigo_ejecutora, a.tipact_codigo, a.fecha_registro, 
		au.aun_nombre, au.aun_sigla, au.aun_estado,
		po.pobj_codigo ,po.pobj_nombre, po.pobj_estado,
		p.poa_codigo 
from 	estructura_poa.actividades a 
		left join estructura_organizacional.areas_unidades au on a.aun_codigo_ejecutora = au.aun_codigo 
		left join estructura_poa.poas_objetivos po on a.pobj_codigo = po.pobj_codigo 
		left join estructura_poa.poas p on p.poa_codigo = po.poa_codigo 
where	true 	
--		and a.act_numero = '530.0022.15.1.24'
--		and a.act_codigo in (1121)
--		and au.aun_sigla like 'GPA-GA3'
--		and a.act_estado not in (2,9,0,13)
--		and a.act_estado in (1)
--		and a.iac_codigo_apoyo is not null
--		and a.tipact_codigo in (2)
--		and a.cac_codigo in (2)
--		and po.pobj_codigo in (1181)
		and p.poa_codigo in (2)
order by au.aun_codigo desc;
--order by a.act_codigo desc;
--#################
        SELECT
              t.for_estado, fob.fob_estado, act.act_estado, avi.avi_estado
              ,COALESCE(COUNT(DISTINCT act.act_codigo), 0) AS cantidad_actividades
        FROM	estructura_poa.formularios t
              LEFT JOIN estructura_poa.formularios_objetivos fob ON
                t.for_codigo = fob.for_codigo
                AND fob.fob_estado IN (4,10,14,11,12,13,1,3,8,7,2,5)
              LEFT JOIN (
                SELECT	*
                FROM	estructura_poa.actividades act
                WHERE	TRUE
                    AND act.act_estado IN (4,10,14,11,12,13,1,3,8,7,2,5)
                    --AND act.cac_codigo IN (1)
                    --${queryAddConditionAreaUnidadRolPersonaForActividades || ''}
              ) act ON fob.fob_codigo = act.fob_codigo
              LEFT JOIN estructura_poa.actividades_viaticos avi ON
                act.act_codigo = avi.act_codigo
                AND avi.avi_estado IN (4,10,14,11,12,13,1,3,8,7,2,5)
        WHERE TRUE
              AND t.poa_codigo IN (3)
        GROUP BY t.for_estado, fob.fob_estado, act.act_estado, avi.avi_estado
        ORDER BY
          array_position( array[4,10,14,11,12,13,1,3,8,7,2,5], avi.avi_estado ),
          array_position( array[4,10,14,11,12,13,1,3,8,7,2,5], act.act_estado ),
          array_position( array[4,10,14,11,12,13,1,3,8,7,2,5], fob.fob_estado ),
          array_position( array[4,10,14,11,12,13,1,3,8,7,2,5], t.for_estado )
        ;
--##############
--##############
SELECT	*
FROM	estructura_poa.actividades act
WHERE	TRUE
    AND act.act_estado IN (4,10,14,11,12,13,1,3,8,7,2,5);
    --AND act.cac_codigo IN (1);
    --${queryAddConditionAreaUnidadRolPersonaForActividades || ''};
--##############
--##############
SELECT
      t.poa_estado, po.pobj_estado, act.act_estado, avi.avi_estado
      ,COALESCE(COUNT(DISTINCT act.act_codigo), 0) AS cantidad_actividades
FROM	estructura_poa.poas t
      LEFT JOIN estructura_poa.poas_objetivos po ON
        t.poa_codigo = po.poa_codigo
        AND po.pobj_estado IN (4,10,14,11,12,13,1,3,8,7,2,5)
      LEFT JOIN (
        SELECT	*
        FROM	estructura_poa.actividades act
        WHERE	TRUE
            AND act.act_estado IN (4,10,14,11,12,13,1,3,8,7,2,5)
            --AND act.cac_codigo IN (1)
            --${queryAddConditionAreaUnidadRolPersonaForActividades || ''}
      ) act ON po.pobj_codigo = act.pobj_codigo
      LEFT JOIN estructura_poa.actividades_viaticos avi ON
        act.act_codigo = avi.act_codigo
        AND avi.avi_estado IN (4,10,14,11,12,13,1,3,8,7,2,5)
WHERE TRUE
      AND t.poa_codigo IN (3)
GROUP BY t.poa_estado, po.pobj_estado, act.act_estado, avi.avi_estado
ORDER BY
  array_position( array[4,10,14,11,12,13,1,3,8,7,2,5], avi.avi_estado ),
  array_position( array[4,10,14,11,12,13,1,3,8,7,2,5], act.act_estado ),
  array_position( array[4,10,14,11,12,13,1,3,8,7,2,5], po.pobj_estado ),
  array_position( array[4,10,14,11,12,13,1,3,8,7,2,5], t.poa_estado )
;
--##############
--$$$$$$$$$$$$$$$$$$$$
      SELECT
              t.oau_codigo,
              t.oau_descripcion,
              t.pobj_codigo,
              po.pobj_nombre AS oau_pobj_nombre,
              t.aun_codigo_ejecutora,
              CONCAT_WS(' - ', au1.aun_nombre, au1.aun_sigla) AS oau_aun_nombre_ejecutora,
              au1.aun_sigla AS oau_aun_sigla_ejecutora,
              au1.aun_inicial AS aun_inicial_ejecutora,
              au1.cau_codigo,
              t.aun_codigo_supervisora,
              CONCAT_WS(' - ', au2.aun_nombre, au2.aun_sigla) AS oau_aun_nombre_supervisora,
              au2.aun_sigla AS oau_aun_sigla_supervisora,
              au2.aun_inicial AS aun_inicial_supervisora,
              t.oau_estado,
              e.est_color,
              e.est_nombre AS oau_estado_descripcion,
              TO_CHAR(t.fecha_registro, 'HH24:MI am dd/mm/yyyy') as fecha_registro,
              po.poa_codigo, poa.ges_codigo,
              CONCAT(pr.pro_numero, '.', au1.aun_numero,'.',po.pobj_numero) AS poa_pobj_oau_codigo
        FROM	estructura_poa.objetivos_area_unidad t
              LEFT JOIN parametricas.estados e ON e.est_codigo = t.oau_estado
              LEFT JOIN estructura_poa.poas_objetivos po ON po.pobj_codigo = t.pobj_codigo
              LEFT JOIN estructura_poa.poas poa ON po.poa_codigo = poa.poa_codigo
              LEFT JOIN pei.programas pr ON pr.pro_codigo = po.pro_codigo
              LEFT JOIN estructura_organizacional.areas_unidades au1 ON au1.aun_codigo = t.aun_codigo_ejecutora
              LEFT JOIN estructura_organizacional.areas_unidades au2 ON au2.aun_codigo = t.aun_codigo_supervisora
        WHERE	TRUE
              AND t.oau_codigo IN (1745)
        		order by t.fecha_registro desc
        ;
--$$$$$$$$$$$$$$$$$
--AREA UNIDAD RESPONSABLES
select 	aur.aur_codigo , aur.aur_estado ,p.poa_codigo, aur.fecha_registro ,
		g.ges_anio 
from 	estructura_poa.area_unidad_responsables aur
		left join estructura_poa.poas p on aur.poa_codigo = p.poa_codigo 
		left join parametricas.gestiones g on p.ges_codigo = g.ges_codigo 
where 	true
		and aur.aur_estado in (1)
		and aur.poa_codigo in (3)
order by aur.aur_codigo desc;
--OBJETIVO AREA UNIDAD
select 	oau.oau_codigo , oau.oau_estado, oau.pobj_codigo, oau.fecha_registro, 
		au.aun_sigla,
		p.poa_codigo 
from 	estructura_poa.objetivos_area_unidad oau
		left join estructura_organizacional.areas_unidades au on oau.aun_codigo_ejecutora = au.aun_codigo 
		left join estructura_poa.poas_objetivos po on oau.pobj_codigo = po.pobj_codigo 
		left join estructura_poa.poas p on po.poa_codigo = p.poa_codigo 
where 	true
--		and oau.oau_estado in (1)
		and p.poa_codigo in (3)
order by oau.oau_codigo desc;
--FLUJO ESTADO
select 	*
from 	control_estados.flujos_tablas ft
where 	true 
		and ft.tab_codigo in (39)
;
--INICIOS ACTIVIDADES
select	*
FROM 	ejecucion_actividades.inicios_actividades t
--where 	t.iac_codigo_control in ('EHEN26Y00')
--where 	t.iac_codigo in (407)
--where 	t.iac_estado in (22)
order by t.iac_codigo desc ;
--INICIO ACTIVIDAD POA
select 	*
from 	ejecucion_actividades.inicio_actividad_poa iap
		left join ejecucion_actividades.inicios_actividades ia on iap.iac_codigo =ia.iac_codigo 
where 	true 
		and iap.iap_codigo in (478)
--where 	iap.act_codigo in (711)
--limit 5;
order 	by iap.iap_codigo desc;
--FLUJOS TABLAS SERVICES
select 	*
from 	control_estados.flujos_tablas ft
where 	true 
		and ft.tab_codigo in (64)
order by ft.fta_codigo asc;
--
--###  --- INICIO ACT POA - CAMBIO GLOBAL DE ESTADOS, POR ROL
	select iap.iap_codigo,iap.iac_codigo,iap.iap_observaciones ,iap.iap_estado  from ejecucion_actividades.inicio_actividad_poa iap where iap.iap_codigo in (17);
	select ia.iac_codigo,ia.iac_observaciones ,ia.iac_estado from ejecucion_actividades.inicios_actividades ia where ia.iac_codigo in (134); 
	select iaa.iaa_codigo ,iaa.iac_codigo ,iaa.iaa_estado  from ejecucion_actividades.inicios_actividades_adicional iaa where iaa.iac_codigo in (134);
	select iapa.iapa_codigo,iapa.asi_codigo, iapa.iap_codigo,iapa.iapa_estado from ejecucion_actividades.inicio_actividad_poa_asignaciones iapa where iapa.iap_codigo in (17); 
	select a.asi_codigo, a.asi_estado  from ejecucion_poa.asignaciones a where a.asi_codigo in (17);
	select aci.aci_codigo , aci.aci_estado  from ejecucion_poa.asignaciones_cargos_item aci where aci.asi_codigo in (17);
	-- obtiene los estados de cada uno
	select eiap.iap_codigo , eiap.eiap_estado from control_estados.estados_inicio_actividad_poa eiap where eiap.iap_codigo in (17) order by eiap.eiap_codigo desc;
	select eia.iac_codigo ,eia.eia_estado  from control_estados.estados_inicios_actividades eia where eia.iac_codigo in (134) order by eia.eia_codigo desc;
	select * from control_estados.estados_asignaciones ea  where ea.asi_codigo in (17) order by ea.asi_codigo desc;
	select * from control_estados.estados_asignaciones_cargos_item eaci  where eaci.aci_codigo in (51) order by eaci.eaci_codigo desc;
	select * from control_estados.estados_asignaciones_cargos_item eaci  where eaci.aci_codigo in (52) order by eaci.eaci_codigo desc;
	select * from control_estados.estados_asignaciones_cargos_item eaci  where eaci.aci_codigo in (53) order by eaci.eaci_codigo desc;
	select * from control_estados.estados_asignaciones_cargos_item eaci  where eaci.aci_codigo in (54) order by eaci.eaci_codigo desc;
	select * from control_estados.estados_asignaciones_cargos_item eaci  where eaci.aci_codigo in (55) order by eaci.eaci_codigo desc;
	select * from control_estados.estados_asignaciones_cargos_item eaci  where eaci.aci_codigo in (430) order by eaci.eaci_codigo desc;
--
--ACTIVIDADES CONTINUIDAD
select 	*
from 	estructura_poa.actividades_continuidad ac
--where 	ac.iac_codigo in (397)
order by ac.aco_codigo desc;
--ACTIVIDADES HORAS PLANIFICADAS
select 	*
from 	estructura_poa.actividades_horas_planificadas ahp 
--where 	ac.iac_codigo in (397)
order by ahp.ahp_codigo desc
limit 5;
--ACTIVIDAD MIGRADA CONAUD
select 	*
from 	ejecucion_actividades.actividad_migrada_conaud amc 
order by amc.amc_codigo desc;
--NRO RECOMENDACIONES POR IAP_CODIGO
SELECT	iap.iap_codigo, ia.iac_codigo, iai.inf_codigo, ir.ire_codigo
FROM	ejecucion_actividades.inicio_actividad_poa iap
		LEFT JOIN ejecucion_actividades.inicios_actividades ia ON iap.iac_codigo = ia.iac_codigo
		LEFT JOIN ejecucion_actividades.inicio_actividad_informe iai ON ia.iac_codigo = iai.iac_codigo
		LEFT JOIN ejecucion_actividades.informe_recomendaciones ir ON iai.inf_codigo = ir.inf_codigo
WHERE	TRUE
		AND ir.ire_estado NOT IN (0)
		AND iap.iap_codigo IN (285)
;
--INFORMES EMERGENTES
select 	*
from 	parametricas.informes_emergentes ie
where 	ie.iem_descripcion = 'Evaluacion de Confiabilidad de Estados Financieros'
;
--INFORMES
select 	*
from 	ejecucion_actividades.informes i 
--where 	i.iac_codigo in (403)
where 	i.inf_codigo in (78)
order by	i.inf_codigo desc;
--INICIO ACTIVIDAD INFORME
select 	*
from 	ejecucion_actividades.inicio_actividad_informe iai
order 	by	iai.iai_codigo desc;
--INFORME RECOMENDACIONES
select 	*
from 	ejecucion_actividades.informe_recomendaciones ir
where 	ir.inf_codigo in (78)
order by	ir.ire_codigo desc
limit 5;
--FLUJOS ESTADOS EVOLUCION
select 	*
from 	parametricas.flujos_estados_evolucion fee 
where 	fee.iem_codigo = 16;
--INFORME RECOMENDACIONES SEGUIMIENTOS
select 	*
from 	ejecucion_actividades.informe_recomendaciones_seguimientos irs
order by	irs.irs_codigo desc 
limit 5;
--RECOMENDACIONES INICIOS SEGUIMIENTOS
select 	*
from 	ejecucion_actividades.recomendaciones_inicios_seguimientos ris 
order by	ris.ris_codigo desc 
limit 5;
--AREA UNIDAD RESPONSABLES
select 	*
--select 	aur.aur_codigo , aur.aur_estado ,p.poa_codigo, aur.fecha_registro ,
--		g.ges_anio 
from 	estructura_poa.area_unidad_responsables aur
		left join estructura_poa.poas p on aur.poa_codigo = p.poa_codigo 
		left join parametricas.gestiones g on p.ges_codigo = g.ges_codigo 
where 	true
--		and aur.aur_estado in (1)
--		and aur.poa_codigo in (2)
		and aur.per_codigo in (1914)
order by aur.aur_codigo desc;








;