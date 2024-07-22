--TIPO DE F
SELECT	t.iap_codigo, t.iap_estado, t.tia_codigo, tia.tia_nombre, t.fecha_registro,
        a.act_codigo, a.act_numero,
        au.aun_sigla, 
        ia.iac_codigo, ia.iac_codigo_control,
        tt.ett_codigo
FROM	ejecucion_actividades.inicio_actividad_poa t
		LEFT JOIN parametricas.tipos_inicios_actividades tia ON t.tia_codigo = tia.tia_codigo
        LEFT JOIN estructura_poa.actividades a on t.act_codigo = a.act_codigo
        LEFT JOIN estructura_organizacional.areas_unidades au ON a.aun_codigo_ejecutora = au.aun_codigo 
        LEFT JOIN ejecucion_actividades.inicios_actividades ia on t.iac_codigo = ia.iac_codigo
        LEFT JOIN parametricas.tipos_trabajos tt on ia.ttr_codigo = tt.ttr_codigo
        LEFT JOIN parametricas.especificacion_tipos_trabajo ett on tt.ett_codigo = ett.ett_codigo
WHERE	TRUE
--      AND t.iac_codigo IN (1)
--		AND t.tia_codigo IN (1)--F1
--		AND t.tia_codigo IN (2)--F1-A
		AND t.tia_codigo IN (3)--F2
--		AND t.tia_codigo IN (4)--F2-A
--		AND t.iap_estado IN (5)
        AND t.iap_estado NOT IN (0)
ORDER BY t.fecha_registro DESC
;
--ACTIVIDADES
select 	a.act_codigo , a.act_ejecucion_conaud, a.act_codigo_anterior ,a.act_numero ,a.cac_codigo ,a.iac_codigo_apoyo, a.act_estado, a.act_descripcion , a.aun_codigo_ejecutora, a.tipact_codigo, a.fecha_registro, a.ttr_codigo, 
		ett.ett_codigo, ett.ett_nombre, 
		au.aun_nombre, au.aun_sigla, au.aun_estado,
		po.pobj_codigo ,po.pobj_nombre, po.pobj_estado,
		p.poa_codigo
--		oau.oau_codigo, oau.oau_descripcion ,oau.oau_estado 
from 	estructura_poa.actividades a
		left join parametricas.tipos_trabajos tt on a.ttr_codigo = tt.ttr_codigo
		left join parametricas.especificacion_tipos_trabajo ett on tt.ett_codigo = ett.ett_codigo 
		left join estructura_organizacional.areas_unidades au on a.aun_codigo_ejecutora = au.aun_codigo 
		left join estructura_poa.poas_objetivos po on a.pobj_codigo = po.pobj_codigo 
		left join estructura_poa.poas p on p.poa_codigo = po.poa_codigo
--		left join estructura_poa.objetivos_area_unidad oau on po.pobj_codigo = oau.pobj_codigo 
where	true 	
		and a.act_numero = '510.1202.17.14.24'
--		and a.act_codigo in (14)
--		and a.act_codigo_anterior in (613,609,592,585,580,478,396,219,217,198)
--		and a.act_codigo_anterior in (396,219,217)
--		and au.aun_sigla like 'GDB-GAM'
--		and a.act_estado not in (2,7,9,0,13)
--		and a.act_estado not in (9)
--		and a.iac_codigo_apoyo is not null
--		and a.tipact_codigo in (2)
--		and a.cac_codigo in (1)
--		and po.pobj_codigo in (1145)
--		and p.poa_codigo in (3)
--		and a.act_ejecucion_conaud in (true)
--order by au.aun_estado asc;
order by a.act_codigo desc;