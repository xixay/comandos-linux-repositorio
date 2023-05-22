# Metodo para obtener la lista por aun_codigo_supervisor
## Dbeaver ejm1
- En DBEAVER el codigo del metodo findAll(), es equivalente hacer:
```sql
SELECT 
	t.afu_codigo, 
	t.aun_codigo_supervisado, 
	t.aun_codigo_supervisor, 
	t.afu_descripcion, 
	t.afu_estado, 
	e.est_color, 
	e.est_nombre AS afu_estado_descripcion 
FROM estructura_organizacional.autoridades_funcionales t
LEFT JOIN parametricas.estados e ON e.est_codigo = t.afu_estado
WHERE t.aun_codigo_supervisado=64 ;
```

|afu_codigo|aun_codigo_supervisado|aun_codigo_supervisor|afu_descripcion|afu_estado|est_color|afu_estado_descripcion|
|----------|----------------------|---------------------|---------------|----------|---------|----------------------|
|222|64|60|El area/unidad: GDEP - GERENCIA DEPORTIVA, esta supervisado funcionalmente por: DC - DESPACHO DEL CONTROLADOR|1|#54bebe|EDICIÓN|
|221|64|61|El area/unidad: GDEP - GERENCIA DEPORTIVA, esta supervisado funcionalmente por: GNRH - GERENCIA NACIONAL DE RECURSOS HUMANOS|1|#54bebe|EDICIÓN|
|220|64|62|El area/unidad: GDEP - GERENCIA DEPORTIVA, esta supervisado funcionalmente por: GNAF - GERENCIA NACIONAL ADMINISTRATIVA FINANCIERA|1|#54bebe|EDICIÓN|
|219|64|63|El area/unidad: GDEP - GERENCIA DEPORTIVA, esta supervisado funcionalmente por: GE - GERENCIA EJECUTIVA|1|#54bebe|EDICIÓN|

- Otra manera mas pesada(se obtiene la misma tabla)
```sql
SELECT 
	t.afu_codigo, 
	t.aun_codigo_supervisado, 
	t.aun_codigo_supervisor, 
	t.afu_descripcion, 
	t.afu_estado, 
	e.est_color, 
	e.est_nombre AS afu_estado_descripcion 
FROM estructura_organizacional.autoridades_funcionales t,parametricas.estados e
WHERE e.est_codigo = t.afu_estado and t.aun_codigo_supervisado=64 ;
```

|afu_codigo|aun_codigo_supervisado|aun_codigo_supervisor|afu_descripcion|afu_estado|est_color|afu_estado_descripcion|
|----------|----------------------|---------------------|---------------|----------|---------|----------------------|
|222|64|60|El area/unidad: GDEP - GERENCIA DEPORTIVA, esta supervisado funcionalmente por: DC - DESPACHO DEL CONTROLADOR|1|#54bebe|EDICIÓN|
|221|64|61|El area/unidad: GDEP - GERENCIA DEPORTIVA, esta supervisado funcionalmente por: GNRH - GERENCIA NACIONAL DE RECURSOS HUMANOS|1|#54bebe|EDICIÓN|
|220|64|62|El area/unidad: GDEP - GERENCIA DEPORTIVA, esta supervisado funcionalmente por: GNAF - GERENCIA NACIONAL ADMINISTRATIVA FINANCIERA|1|#54bebe|EDICIÓN|
|219|64|63|El area/unidad: GDEP - GERENCIA DEPORTIVA, esta supervisado funcionalmente por: GE - GERENCIA EJECUTIVA|1|#54bebe|EDICIÓN|

## Backend ejm1
- El método
```ts
  @LoggerMethod
  async findAll(query: GetAllAutoridadesFuncionalesDto, manager: EntityManager) {
    //query esta el dto entrante, ahi esta el aun_codigo_supervisor
    try {
      let sql = `
      SELECT 
        t.afu_codigo, 
        t.aun_codigo_supervisado, 
        t.aun_codigo_supervisor, 
        t.afu_descripcion, 
        t.afu_estado, 
        e.est_color, 
        e.est_nombre AS afu_estado_descripcion 
      FROM estructura_organizacional.autoridades_funcionales t
      LEFT JOIN parametricas.estados e ON e.est_codigo = t.afu_estado//Autoridades funcionales aqui hace un leftjoin con estados
      WHERE TRUE
      ${query.aun_codigo_supervisor ? `AND t.aun_codigo_supervisor IN ${query.aun_codigo_supervisor}` : ''}//aquí
      ${query.afu_estado ? `AND t.afu_estado IN ${query.afu_estado}` : ''};`;

      const resultQuery = await manager.query(sql);
      return CustomService.verifyingDataResult(resultQuery, this.message_custom);
    } catch (error) {
      throwError(400, error.message);
    }
  }
```
- Url que envia el get por aun_codigo_supervisado=64
```txt
http://localhost:7000/autoridades-funcionales?aun_codigo_supervisado=(64)
```
- La respuesta que se obtiene en el backend
```json
{
  "codigo": 0,
  "error_existente": 0,
  "error_mensaje": "SE OBTUVIERON DATOS DE FORMA CORRECTA.",
  "error_codigo": 2001,
  "trace_id": "c028fb39-7f08-42e0-bc2d-4bc1a8a1f525",
  "datos": [
    {
      "afu_codigo": 219,
      "aun_codigo_supervisado": 64,
      "aun_codigo_supervisor": 63,
      "afu_descripcion": "El area/unidad: GDEP - GERENCIA DEPORTIVA, esta supervisado funcionalmente por: GE - GERENCIA EJECUTIVA",
      "aun_sigla": "GE",
      "afu_estado": 1,
      "est_color": "#54bebe",
      "afu_estado_descripcion": "EDICIÓN"
    },
    {
      "afu_codigo": 220,
      "aun_codigo_supervisado": 64,
      "aun_codigo_supervisor": 62,
      "afu_descripcion": "El area/unidad: GDEP - GERENCIA DEPORTIVA, esta supervisado funcionalmente por: GNAF - GERENCIA NACIONAL ADMINISTRATIVA FINANCIERA",
      "aun_sigla": "GNAF",
      "afu_estado": 1,
      "est_color": "#54bebe",
      "afu_estado_descripcion": "EDICIÓN"
    },
    {
      "afu_codigo": 221,
      "aun_codigo_supervisado": 64,
      "aun_codigo_supervisor": 61,
      "afu_descripcion": "El area/unidad: GDEP - GERENCIA DEPORTIVA, esta supervisado funcionalmente por: GNRH - GERENCIA NACIONAL DE RECURSOS HUMANOS",
      "aun_sigla": "GNRH",
      "afu_estado": 1,
      "est_color": "#54bebe",
      "afu_estado_descripcion": "EDICIÓN"
    },
    {
      "afu_codigo": 222,
      "aun_codigo_supervisado": 64,
      "aun_codigo_supervisor": 60,
      "afu_descripcion": "El area/unidad: GDEP - GERENCIA DEPORTIVA, esta supervisado funcionalmente por: DC - DESPACHO DEL CONTROLADOR",
      "aun_sigla": "DC",
      "afu_estado": 1,
      "est_color": "#54bebe",
      "afu_estado_descripcion": "EDICIÓN"
    }
  ]
}
```
# Validar que los items no se repitan al momento de editar
## Dbeaver ejm2
- Encontrar las areas unidades, pertenecientes a ese organigrama
```sql
select * 
from estructura_organizacional.areas_unidades au 
where au.org_codigo = 42;
```
|aun_codigo|aun_nombre|aun_sigla|nau_codigo|aau_codigo|cau_codigo|aun_estado|usuario_registro|usuario_modificacion|usuario_baja|fecha_registro|fecha_modificacion|fecha_baja|org_codigo|aun_numero|
|----------|----------|---------|----------|----------|----------|----------|----------------|--------------------|------------|--------------|------------------|----------|----------|----------|
|181|PRINCIPAL|P1|1|1|2|1|1791|1791|0|2023-04-21 17:51:56.806|2023-04-23 16:51:33.162|1900-01-01 00:00:00.000|42|345|
|182|PRINCIPAL2|P2|2|2|1|1|1791|1791|0|2023-04-21 17:53:26.227|2023-04-23 16:51:49.441|1900-01-01 00:00:00.000|42|1234|
- Obtener todos los cargos-item, que estan en esas 2 areas unidades, que estan dentro de un organigrama(el item no debe repetirse)
```sql
select * 
from estructura_organizacional.cargos_items ci 
where ci.aun_codigo IN (181,182);
```
|cit_codigo|cit_descripcion|car_codigo|ite_codigo|cit_estado|usuario_registro|usuario_modificacion|usuario_baja|fecha_registro|fecha_modificacion|fecha_baja|aun_codigo|
|----------|---------------|----------|----------|----------|----------------|--------------------|------------|--------------|------------------|----------|----------|
|186|El cargo: SECRETARIA GENERAL DE ALIMENTOS, pertenece al área/unidad: PRINCIPAL, con el item: 0345.|68|134|1|1791|0|0|2023-04-24 09:20:08.205|1900-01-01 00:00:00.000|1900-01-01 00:00:00.000|181|
|188|El cargo: SECRETARIA GENERAL DE ALIMENTOS, pertenece al área/unidad: PRINCIPAL, con el item: 1001.|68|136|1|1791|0|0|2023-04-24 09:37:29.877|1900-01-01 00:00:00.000|1900-01-01 00:00:00.000|181|
|189|El cargo: SECRETARIA GENERAL DE ALIMENTOS, pertenece al área/unidad: PRINCIPAL, con el item: 0347.|68|140|1|1791|0|0|2023-04-24 09:43:19.433|1900-01-01 00:00:00.000|1900-01-01 00:00:00.000|181|
|187|Modificación para el cargo: SECRETARIA GENERAL DE ALIMENTOS, pertenece al área/unidad: PRINCIPAL, con el item: 0349.|68|142|1|1791|1791|0|2023-04-24 09:36:45.220|2023-04-25 09:29:12.771|1900-01-01 00:00:00.000|181|
- Para modificar el item en el cargo-item, el ite_codigo debe estar presente solamente una vez en la tabla anterior, para ello buscar en la anterior consulta y con todos los estados
```sql
select * 
from estructura_organizacional.cargos_items ci 
where ci.ite_codigo IN (134) AND ci.aun_codigo IN (181,182) and ci.cit_estado in (1,2,3,4,5);
``` 
|cit_codigo|cit_descripcion|car_codigo|ite_codigo|cit_estado|usuario_registro|usuario_modificacion|usuario_baja|fecha_registro|fecha_modificacion|fecha_baja|aun_codigo|
|----------|---------------|----------|----------|----------|----------------|--------------------|------------|--------------|------------------|----------|----------|
|186|El cargo: SECRETARIA GENERAL DE ALIMENTOS, pertenece al área/unidad: PRINCIPAL, con el item: 0345.|68|134|1|1791|0|0|2023-04-24 09:20:08.205|1900-01-01 00:00:00.000|1900-01-01 00:00:00.000|181|
## Backend ejm2
- Metodo que verifica que el item, no se repita al modificarse, al momento de actualizarse
```ts
  @LoggerMethod
  async update(updateCargosItemsDto: UpdateCargosItemsDto, manager: EntityManager) {
    try {
      const cargosItems: CargosItems = await this.validations(Operation.UPDATE, manager, updateCargosItemsDto);

      const resultQuery = await manager.update(CargosItems, cargosItems.cit_codigo, cargosItems);
      //buscar areas con ese organigrama
      let resultCargosItem = []
      try {
        const getAllAreasUnidadesDto = new GetAllAreasUnidadesDto//obt todos
        getAllAreasUnidadesDto.org_codigo = `(${this.orgCodigo})`// Debe existir este org_codigo=42 se trae de otro lado
        const resultAreas = await this.areasUnidadesService.findAll(getAllAreasUnidadesDto, manager)//obtiene todas las areas unidades en ese organigrama
        const getAllCargosItemsDtoU = new GetAllCargosItemsDto()
        getAllCargosItemsDtoU.aun_codigo = `(${resultAreas.map(m => m.aun_codigo)})`;asigna a aun_codigo con [181,182]
        getAllCargosItemsDtoU.ite_codigo = `(${updateCargosItemsDto.ite_codigo})`//busca tb por ite_codigo=135
        getAllCargosItemsDtoU.cit_estado = `(1,2,3,4,5)`;//busca tb con todos los estados
        resultCargosItem = await this.findAll(getAllCargosItemsDtoU, manager)
      } catch (error) { }
      //encuentra 1 con el cit_codigo=186
      if (resultCargosItem.length>1) throwError(400, 'NO SE PUEDE MODIFICAR PORQUE EL ITEM ESTA REPITIENDOSE EN EL ORGANIGRAMA ');
      return CustomService.verifyingDataResult(resultQuery, this.message_custom);
    } catch (error) {
      this.logger.debug(error);
      throwError(400, error.message);
    }
  }
```
- Url que envia el put para modificar el item
```txt
http://localhost:7000/cargos-items
```
- Con el body
```json
{
  "aun_codigo": 186,
  "car_codigo": 68,
  "cit_codigo": 201,
  "ite_codigo": 135
}
```
- La respuesta que se obtiene en el backend
```json
{
  "codigo": 0,
  "error_existente": 1,
  "error_mensaje": "NO SE PUEDE MODIFICAR PORQUE ESE ITEM YA ESTA REPITIENDOSE EN EL ORGANIGRAMA ",
  "error_codigo": 4001,
  "datos": [],
  "trace_id": "7813cb25-1c54-4997-9d92-4cfa6b4bb1e1"
}
```
- Como existe el item, no lo modifica

|cit_codigo|cit_descripcion|car_codigo|ite_codigo|cit_estado|usuario_registro|usuario_modificacion|usuario_baja|fecha_registro|fecha_modificacion|fecha_baja|aun_codigo|
|----------|---------------|----------|----------|----------|----------------|--------------------|------------|--------------|------------------|----------|----------|
|186|El cargo: SECRETARIA GENERAL DE ALIMENTOS, pertenece al área/unidad: PRINCIPAL, con el item: 0345.|68|134|1|1791|0|0|2023-04-24 09:20:08.205|1900-01-01 00:00:00.000|1900-01-01 00:00:00.000|181|
# Consultas
## OBTENER CARGOS ITE solo de 1 y 2
```sql
select 
ci.cit_codigo,
cid.cid_codigo
from estructura_organizacional.cargos_items ci  
left join estructura_organizacional.cargos_item_dependencias cid on cid.cit_codigo_hijo =ci.cit_codigo 
where cit_codigo in (1,2);
```
## OBTENER LOS CARGOS ITEMS DE ESOS CODIGOS
```sql
select *
from estructura_organizacional.cargos_items ci 
where ci.cit_codigo in (48,49,50,52)
```
|cit_codigo|cit_descripcion|car_codigo|ite_codigo|cit_estado|usuario_registro|usuario_modificacion|usuario_baja|fecha_registro|fecha_modificacion|fecha_baja|aun_codigo|
|----------|---------------|----------|----------|----------|----------------|--------------------|------------|--------------|------------------|----------|----------|
|48|El cargo: SECRETARIA COMERCIAL, pertenece al área/unidad: DESPACHO DEL CONTROLADOR, con el item: 0001.|57|47|1|1791|1791|0|2023-04-05 11:10:06.509|2023-04-05 11:18:34.266|1900-01-01 00:00:00.000|61|
|50|El cargo: AYUDANTE SECRETARIA, pertenece al área/unidad: DESPACHO DEL CONTROLADOR, con el item: 0003.|59|49|1|1791|1791|0|2023-04-05 11:14:54.418|2023-04-05 11:22:05.975|1900-01-01 00:00:00.000|60|
|52|El cargo: LIMPIEZA, pertenece al área/unidad: DESPACHO DEL CONTROLADOR, con el item: 0034.|62|52|1|1791|0|0|2023-04-06 15:34:27.239|1900-01-01 00:00:00.000|1900-01-01 00:00:00.000|60|
|49|El cargo: COMUNICACION, pertenece al área/unidad: DESPACHO DEL CONTROLADOR, con el item: 0002.|58|48|1|1791|1791|0|2023-04-05 11:12:33.909|2023-04-05 11:22:05.908|1900-01-01 00:00:00.000|60|
## OBTENER NIVELES AREAS UNIDADES
```sql
select *
from parametricas.niveles_areas_unidades nau
order by nau.nau_codigo 
asc;
```
|nau_codigo|nau_nombre|nau_descripcion|nau_estado|usuario_registro|usuario_modificacion|usuario_baja|fecha_registro|fecha_modificacion|fecha_baja|nau_nivel|
|----------|----------|---------------|----------|----------------|--------------------|------------|--------------|------------------|----------|---------|
|1|DIRECTIVO|Definición para áreas Directivas|1|0|0|0|2023-03-16 16:13:33.930|1900-01-01 00:00:00.000|1900-01-01 00:00:00.000|1|
|2|EJECUTIVO|Definición para Áreas/Unidades Ejecutivas|1|0|0|0|2023-03-16 16:13:33.930|1900-01-01 00:00:00.000|1900-01-01 00:00:00.000|2|
|3|OPERATIVO|Definición para Áreas/Unidades Operativas|1|0|0|0|2023-03-16 16:13:33.930|1900-01-01 00:00:00.000|1900-01-01 00:00:00.000|3|
## OBTENER AREAS UNIDADES CON SU RESPECTIVA DIRECTIVA usando WHERE(mas pesado menos recomendado)
```sql
select 
au.aun_codigo,
au.aun_nombre,
au.nau_codigo,
nau.nau_nombre
from estructura_organizacional.areas_unidades au, parametricas.niveles_areas_unidades nau  
where au.nau_codigo =nau.nau_codigo
order by au.aun_codigo;
```
|aun_codigo|aun_nombre|nau_codigo|nau_nombre|
|----------|----------|----------|----------|
|1|Despacho Contralor|2|EJECUTIVO|
|2|Gerencia Recursos Humanos|2|EJECUTIVO|
|3|Gerencia Nacional Administrativa financiera|2|EJECUTIVO|
|7|Subcontraloria General|2|EJECUTIVO|
|8|Unidad  de Planificacion|3|OPERATIVO|
|16|BBBB|2|EJECUTIVO|
|21|PRUEBA11|2|EJECUTIVO|
|22|PRUEBA12|2|EJECUTIVO|
|34|PRUEBA25|2|EJECUTIVO|
|37|PRUEBA28|2|EJECUTIVO|
|41|PRUEBA30|2|EJECUTIVO|
|44|PRUEBA33|2|EJECUTIVO|
|48|Area Unidad Descripcion|2|EJECUTIVO|
|59|ffffffffffffffffffffff|2|EJECUTIVO|
|60|DESPACHO DEL CONTROLADOR|1|DIRECTIVO|
|61|GERENCIA NACIONAL DE RECURSOS HUMANOS|2|EJECUTIVO|
|62|GERENCIA NACIONAL ADMINISTRATIVA FINANCIERA|2|EJECUTIVO|
## OBTENER AREAS UNIDADES CON SU RESPECTIVA DIRECTIVA usando LEFT JOIN
```sql
select 
au.aun_codigo,
au.aun_nombre,
au.nau_codigo,
nau.nau_nombre 
from estructura_organizacional.areas_unidades au  
left join parametricas.niveles_areas_unidades nau on au.nau_codigo  =nau.nau_codigo
order by au.aun_codigo;
```
|aun_codigo|aun_nombre|nau_codigo|nau_nombre|
|----------|----------|----------|----------|
|1|Despacho Contralor|2|EJECUTIVO|
|2|Gerencia Recursos Humanos|2|EJECUTIVO|
|3|Gerencia Nacional Administrativa financiera|2|EJECUTIVO|
|7|Subcontraloria General|2|EJECUTIVO|
|8|Unidad  de Planificacion|3|OPERATIVO|
|16|BBBB|2|EJECUTIVO|
|21|PRUEBA11|2|EJECUTIVO|
|22|PRUEBA12|2|EJECUTIVO|
|34|PRUEBA25|2|EJECUTIVO|
|37|PRUEBA28|2|EJECUTIVO|
|41|PRUEBA30|2|EJECUTIVO|
|44|PRUEBA33|2|EJECUTIVO|
|48|Area Unidad Descripcion|2|EJECUTIVO|
|59|ffffffffffffffffffffff|2|EJECUTIVO|
|60|DESPACHO DEL CONTROLADOR|1|DIRECTIVO|
|61|GERENCIA NACIONAL DE RECURSOS HUMANOS|2|EJECUTIVO|
|62|GERENCIA NACIONAL ADMINISTRATIVA FINANCIERA|2|EJECUTIVO|