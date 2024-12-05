## Ruta
- components/sispoa/estructura_formulario/RFormularioRefactor.vue
## Llama Formularios

### Inicio

| cacCodigo       | 1                                                                  |
| --------------- | ------------------------------------------------------------------ |
| filter          | false                                                              |
| filterCacCodigo | &cac_codigo=(1,3,4)                                                |
| paso            | } else if (this.CacCodigo == 1) {                                  |
|                 | if (this.PoaRecordSelected && this.PoaRecordSelected.tpo_codigo) { |
|                 | } else if (this.PoaRecordSelected.tpo_codigo == 2) {               |
### F21

| cacCodigo       | 2                          |
| --------------- | -------------------------- |
| filter          | false                      |
| filterCacCodigo | &cac_codigo=(2,4)          |
| paso            | if (this.CacCodigo == 2) { |

### F26

| cacCodigo       | 2                                                                  |
| --------------- | ------------------------------------------------------------------ |
| filter          | false                                                              |
| filterCacCodigo | &cac_codigo=(1,3,4)                                                |
| paso            | } else if (this.CacCodigo == 1) {                                  |
|                 | if (this.PoaRecordSelected && this.PoaRecordSelected.tpo_codigo) { |
|                 | } else if (this.PoaRecordSelected.tpo_codigo == 2) {               |

### Todos

| cacCodigo       | 5                               |
| --------------- | ------------------------------- |
| filter          | false                           |
| filterCacCodigo | &cac_codigo=(1,2,3,4)           |
| paso            | else if (this.CacCodigo == 5) { |

## Sin filtro
-   
http://172.16.22.243:7091/poas-objetivos/formularios?poa_codigo=(3)&cac_codigo=(1,3,4)&with_rol_formulario=0
## Con filtro
- http://172.16.22.243:7091/poas-objetivos/formularios?poa_codigo=(3)&cac_codigo=(1,3,4)&with_rol_formulario=0&cod_estado_filter=(2)
- http://172.16.22.243:7091/poas-objetivos/formularios?poa_codigo=(3)&cac_codigo=(1,3,4)&with_rol_formulario=0&cod_estado_filter=(2)&aun_codigo_filter=(7)
```
cod_estado_filter: '(2)',  
aun_codigo_filter: '(7)'
```
## Roles
- **GDC-GAD**

| 3403668 | ANA MARIA BRIGGITTE DEL CARMEN ARRAZOLA DURAN | FORMULADOR         | EDICION |
| ------- | --------------------------------------------- | ------------------ | ------- |
| 2389409 | OLGA EDITH SUAREZ JIMENEZ                     | SUPERVISOR         | EDICION |
| 4385501 | JULIO CARLOS GUERRA VILLARROEL                | APROBADOR          | EDICION |
| 1397469 | RUTH TARCAYA GALLARDO                         | FORMULADOR GERENTE | EDICION |
| 1397469 | RUTH TARCAYA GALLARDO                         | FORMULADOR         | EDICION |
- **GDC**

|         |                                |                                               |            |         |
| ------- | ------------------------------ | --------------------------------------------- | ---------- | ------- |
| 4385501 | JULIO CARLOS GUERRA VILLARROEL | GERENTE CONSOLIDADOR                          | EDICION    |         |
|         | 4755293                        | NORKA VALERIA CHAVEZ LIMACHI                  | SUPERVISOR | EDICION |
|         | 4385501                        | JULIO CARLOS GUERRA VILLARROEL                | SUPERVISOR | EDICION |
|         | 4385501                        | JULIO CARLOS GUERRA VILLARROEL                | APROBADOR  | EDICION |
|         | 3792170                        | LETICIA MIRANDA VARGAS                        | FORMULADOR | EDICION |
|         |                                | SIN IDENTIFICAR                               | FORMULADOR | EDICION |
|         | 6725360                        | EVELYN ROSARIO ESCOBAR TAPIA                  | FORMULADOR | EDICION |
|         | 3403668                        | ANA MARIA BRIGGITTE DEL CARMEN ARRAZOLA DURAN | FORMULADOR | EDICION |
|         | 4813387                        | MERY GOMEZ CONDORI                            | FORMULADOR | EDICION |
|         | 2284347                        | MARTHA BEATRIZ ALIAGA SALINAS                 | FORMULADOR | EDICION |
|         | 6074227                        | JOSE LUIS LAURA APAZA                         | FORMULADOR | EDICION |
- Para OLGA EDITH SUAREZ JIMENEZ 2389409

| GDB  | 44  | x   | GDB-GAD  | 79  | x   |
| ---- | --- | --- | -------- | --- | --- |
|      |     |     | GDB-GAM  | 46  | x   |
| GDC  | 17  | x   | GDC-GAD  | 18  | x   |
| GDH  | 26  | x   | GDH-GAD  | 28  | x   |
| GDN  | 41  | x   | GDN-GAD  | 43  | x   |
| GDO  | 47  | x   | GDO-GAD  | 49  | x   |
| GDP  | 31  | x   | GDP      | 31  | x   |
|      |     |     | GDP-GAD  | 33  | x   |
| GDS  | 21  | x   | GDS-GAD  | 23  | x   |
| GDT  | 36  | x   | GDT-GAD1 | 38  | x   |
|      |     |     | GDT-GAD2 | 40  | x   |
| GPA2 | 13  | x   | GPA2     | 13  | x   |
|      |     |     | GPA2-GAD | 63  | x   |
| SCGD | 4   | x   | SCGD     | 4   | x   |
|      |     |     |          |     |     |
## Query
```
SELECT 	*
FROM 	estructura_poa.poas_objetivos po 
WHERE 	TRUE
		AND po.poa_codigo IN (3)
		AND po.pobj_nombre LIKE 'Emitir 6 informes analíticos de los Planes Anuales de Auditoría elaborados por las UAI de Entidades Públicas del Nivel Departamental en la Gerencia Departamental del Beni en la gestión 2024.'
;


SELECT 	*
FROM 	estructura_poa.area_unidad_responsables aur 
WHERE 	TRUE
		AND aur.per_codigo IN (79)
;
--
          SELECT
                au.aun_codigo AS aun_codigo_ejecutora, au.aun_nombre, au.aun_sigla--,
                --CONCAT(au.aun_nombre, ' - ', au.aun_sigla) AS nom_ejecutora
          FROM  estructura_poa.area_unidad_responsables aur
                LEFT JOIN estructura_organizacional.areas_unidades au ON aur.aun_codigo_ejecutora = au.aun_codigo
          WHERE aur.aur_estado != 0 -- ESTADO ROL-RESPONSABLE
                AND au.aun_estado IN (2,8) -- ESTADO AREA-UNIDAD (CONSOLIDADO, APROBADO)
                AND aur.rol_codigo IN (1,2,3,4,8) -- ROL SELECCIONADO
                AND aur.poa_codigo IN (3) -- POA SELECCIONADO
                AND aur.per_codigo = 79 -- PER_CODIGO SELECCIONADO
               -- AND au.aun_codigo IN (79,46)
          GROUP BY au.aun_codigo, au.aun_nombre, au.aun_sigla, au.cau_codigo, au.aun_numero, au.aun_reporte_habilitado
          ORDER BY au.aun_sigla ASC, au.aun_nombre ASC
          ;
--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
SELECT 	au.aun_codigo ,au.aun_sigla, au.aun_estado 
FROM 	estructura_organizacional.areas_unidades au 
WHERE 	TRUE
		AND au.aun_codigo IN (4,13,17,21,26,31,36,41,44,47)--padre
		--AND au.aun_codigo IN (4,13,63,18,23,28,31,33,38,40,43,46,79,49)--hijos
;
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
WITH agrupado AS (
    SELECT
        -- Extraemos la parte de la sigla antes del guion (o toda la cadena si no hay guion)
        COALESCE(NULLIF(SPLIT_PART(au.aun_sigla, '-', 1), ''), au.aun_sigla) AS sigla_base,
        STRING_AGG(DISTINCT au.aun_codigo::TEXT, ',') AS aun_codigo_agrupado -- Eliminamos duplicados
    FROM estructura_poa.area_unidad_responsables aur
         LEFT JOIN estructura_organizacional.areas_unidades au 
         ON aur.aun_codigo_ejecutora = au.aun_codigo
    WHERE aur.aur_estado != 0 -- ESTADO ROL-RESPONSABLE
          AND au.aun_estado IN (2, 8) -- ESTADO AREA-UNIDAD (CONSOLIDADO, APROBADO)
          AND aur.rol_codigo IN (1, 2, 3, 4, 8) -- ROL SELECCIONADO
          AND aur.poa_codigo IN (3) -- POA SELECCIONADO
          AND aur.per_codigo = 79 -- PER_CODIGO SELECCIONADO
    GROUP BY COALESCE(NULLIF(SPLIT_PART(au.aun_sigla, '-', 1), ''), au.aun_sigla) -- Agrupamos por la unidad principal
)
SELECT 
    sigla_base AS aun_sigla,
    '(' || aun_codigo_agrupado || ')' AS aun_codigo
FROM agrupado
ORDER BY sigla_base;
--##################################################################################################3
SELECT 	
		aud.aun_codigo_padre, aud.aun_codigo_hijo ,
		au.aun_codigo, CONCAT('(', au.aun_numero, ') ', au.aun_nombre, ' - ', au.aun_sigla) AS aun_concatenado_invert
FROM 	estructura_organizacional.areas_unidades_dependencias aud
		LEFT JOIN estructura_organizacional.areas_unidades au ON aud.aun_codigo_padre = au.aun_codigo 
WHERE 	TRUE
		AND aud.aud_estado IN (1)
		AND aud.aun_codigo_padre IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12,13, 17, 21, 26, 31, 36, 41, 44, 47, 57,58, 68, 81)
;







```