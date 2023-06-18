# Vue(Js)

## Inicio
- Instalar
```console
npm install -g @vue/cli
```
- crear un proyecto
```console
vue create my-app
❯ Manually select features
>Router(space)
❯2.x
Use history mode for router? (Requires proper server setup for index fallback in production) (Y/n) y
❯ ESLint with error prevention only
❯Lint on save
❯ In dedicated config files
 Save this as a preset for future projects? (y/N) Y
  Save preset as: xx
```
- Ingresar en la carpeta
```console
cd my-app
```
- Iniciar
```console
npm run serve
```
## Preparativos
### Aplicacion principal App.vue
# Vuetify
## Inicio
- Instalar en un proyecto vue inicial
```console
vue add vuetify
> Still proceed? (y/N) Y
❯ Default (recommended)
```
- Instalar libreira axios para leer los servicios APi rest
```console
npm install -D axios
```
## Preparativos
### Aplicacion principal Articulo.vue
```vue
<template>
  <Articulo />
</template>

<script>
  import Articulo from '../components/Articulo'

  export default {
    name: 'Home',

    components: {
      Articulo,
    },
  }
</script>
```
### Componente
```vue
<template>
  <v-container pa-0>
    <v-card class="mt-15" max-width="100%">//fondo
      <v-data-table :headers="columnas" :items="articulos"
        class="elevation-19">
      </v-data-table>
    </v-card>
  </v-container>
</template>
<script>
import axios from "axios"
export default {
  name: "Articulo",//Nombre de la exportación
  data() {//aqui estan todas las variables
    return {
url: "http://localhost:3000/articulos/",//ENDPOINT
columnas: [
{ text: 'ID', value: 'id', class: 'primary  white--text'},
{ text: 'DESC', value: 'desc', class: 'primary  white--text' },
{ text: 'PRECI', value: 'preci', class: 'primary  white--text' },
{ text: 'STOC', value: 'stoc', class: 'primary  white--text' }],
articulos: [],//el array que viene del metodo GET
}},
  mounted() {this.obtenerArticulos()},//Lo 1ro monta
  methods:{
    obtenerArticulos(){//realiza un GET
       axios.get(this.url)
      .then((response) => {
        this.articulos = response.data //Guardando datos
      })
      .catch((e) => {
        console.log(e)//Errores
      })},
  }
}
</script>
<style></style>
```
### Select
- En template
```vue
<v-col cols="12" sm="12" md="6" xs="6">
  <v-select 
    :readonly="banderaDirectivo && !formReadonly" 
    label="Nivel*" 
    :items="datosNau"//array de objetos
    item-text="nau_nombre" //objeto.nombre
    item-value="nau_codigo"//objeto.codigo
    :rules="[$rules.obligatoria()]" 
    :value="registro.nau_codigo" 
    @change="(v) => (registro.nau_codigo = v)"// hace el cambio
    outlined>
  </v-select>
</v-col>
```
- En script, instanciando
```vue
data() {
  return {
    ...
    datosNau: [],
    ...
  }
},
```
- Funcion que trae el array de objetos
```vue
getAllNivelesAreasUnidadesConOSinDirectiva() {
  this.$service.get('SISPOA',`areas-unidades/areas-con-sin-directiva?org_codigo=(${this.orgCodigo})`).then(response =>{
    if (response) {
      this.datosNau = response
    }
  }).catch(error => {
    // this.$toast.info(error.error_mensaje)
    this.items = []
  })
},
```
### Usando dentro de estilos variables
```vue
    <v-row v-if="compruebaEstadoOrg" class="mt-2" style="text-align: center;">
      <v-col>
        <b class="text-h6" :style="{color:(compruebaEstadoOrg.org_estado==2 || compruebaEstadoOrg.org_estado==8?'#078f20':compruebaEstadoOrg.org_estado==5?'red':'')}">{{ compruebaEstadoOrg.org_estado==2 || compruebaEstadoOrg.org_estado==8? 'Áreas unidades y cargos ya estan verificadas ' : compruebaEstadoOrg.org_estado==5?'Las áreas/unidades y cargos corresponden a información historica, no se pueden realizar cambios':'' }}</b>
      </v-col>
    </v-row>
```
#### cambiando el color de text
```vue
<td>
 <span :class="`${(item.aun_estado==0)?'red--text':''}`">{{ item.aun_sigla }} - {{ item.aun_nombre }}</span>
</td>
```
### TextField
```vue
 <v-col v-if="banderaMuestraFormMover" cols="12" sm="12" md="12" xs="12">
   <v-text-field 
     outlined rows="2" 
     :value="registro.aun_nombre" 
     @change="(v) => (registro.aun_nombre = v)"
     :rules="[$rules.obligatoria()]" 
     label="Nombre*">
   </v-text-field>
 </v-col>
```
### Checkbox
- En template
```vue
 <v-col v-if="banderaMuestraFormMover" cols="12" sm="4" md="4" xs="4">
   <div v-if="banderaMuestraFormMover">
     <v-checkbox
       v-model="banderaOrganizacional"//esta es la variable que cambiara de true a false
       label="¿Es área organizacional?">
     </v-checkbox>
   </div>
 </v-col>
```
- En el script
```vue
data() {
  return {
    ...
    banderaOrganizacional:false,
    ...
  }
},
```
### emit y on
- Con on, este recibe la información, pero debe estar en el mountend(), no en created
```vue
<script>
  mounted() {
    //recibe un objeto item
    this.$nuxt.$on('clickedSeleccionGestion', (item) => {
      this.getAllGestionesOrganigramas(item)
    })
    this.getAllGestionesOrganigramas(null)
  },
  created() {
  },
  methods: {
    getAllGestionesOrganigramas(item) {
      const gestionStorage = this.$storage.get('gestionSeleccion')//es una variable que guuarda afuera  
      this.defaultSelectedGest = item ? item : gestionStorage
      this.listaOrganigramaGestion(this.defaultSelectedGest.ges_anio)//aqui entra el objeto item
    },
    listaOrganigramaGestion(gesAnio){
      this.$service.get('SISPOA', `gestiones-organigramas?ges_anio=(${gesAnio})&gor_estado=(2,3,8)`).then(response => {
          if (response) {
            this.datos = response
          }
        }).catch(error => {
          // this.$toast.info(error.error_mensaje)
          this.datos = []
        })
    },
  }
</script>
```
- con emit envia la información
```vue
<script>
    sendCode(item) {
      this.$nuxt.$emit('clickedSeleccionGestion', item)//item es un objeto
    },
</script>
```
# Instalar Nuxt y Vuetify
## Crear proyecto
- Terminal
```console
npx create-nuxt-app ejemplo-nuxt
```
- Condiciones
```txt
✨  Generating Nuxt.js project in ejemplo-nuxt
? Project name: ejemplo-nuxt
? Programming language: JavaScript
? Package manager: Npm
? UI framework: Vuetify.js
? Template engine: HTML
? Nuxt.js modules: Axios - Promise based HTTP client
? Linting tools: Prettier
? Testing framework: None
? Rendering mode: Universal (SSR / SSG)
? Deployment target: Static (Static/Jamstack hosting)
? Development tools: jsconfig.json (Recommended for VS Code if you're not using typescript)
? Continuous integration: GitHub Actions (GitHub only)
? What is your GitHub username? richard teran
? Version control system: Git
```
## Iniciar el proyecto en modo desarrollo
- Ingresar al proyecto
```console
cd ejemplo-nuxt
```
- Ejecutar
```console
npm run dev
```
- Ejecutar en el navegador
```txt
http://localhost:3000/
```
## Instalar extensiones
```txt
vetur,Material icon theme, htmltagwrap
vue3 supoort all in one
```
## Referencia
- Ir a [Crear Proyecto web con Nuxt y Vuetify](https://www.youtube.com/watch?v=Vh5wT0j9Czo)