#!/bin/bash

# Función para obtener el directorio de inicio del usuario
get_home_directory() {
    if [ -n "$HOME" ]; then
        echo "$HOME"
    elif [ -n "$USER" ]; then
        echo "/home/$USER"
    else
        echo "Error: No se puede determinar el directorio de inicio del usuario."
        exit 1
    fi
}

# Función para obtener el nombre del hostname
get_hostname() {
    hostname=$(hostname)
    echo "$hostname"
}

# Mostrar el nombre del hostname
echo "Nombre del hostname: $(get_hostname)"

# Detectar el entorno basado en el nombre de host
case "$(get_hostname)" in
    "OC-SGSIR-PC20L")
        echo "Detectado entorno de trabajo: Trabajo"
        directorio_origen="$(get_home_directory)/.local/share/DBeaverData/"
        directorio_destino="$(get_home_directory)/Documentos/richard/ayuda-memoria/6archivos/querys/DBeaverData"
        ;;
    "nombre-del-equipo-casa")
        echo "Detectado entorno de trabajo: Casa"
        directorio_origen="/home/xixay/snap/dbeaver-ce/288/.local/share/DBeaverData/"
        directorio_destino="/home/xixay/Documentos/Richard/ayuda-memoria/6archivos/querys/DBeaverData"

        ;;
    *)
        echo "Error: No se puede determinar el entorno de trabajo."
        exit 1
        ;;
esac

# Borrar contenido del directorio de destino si existe
echo "Borrando contenido del directorio de destino..."
rm -rf "$directorio_destino"/*

# Crear el directorio de destino si no existe
mkdir -p "$directorio_destino"

# Copiar los archivos de scripts desde la carpeta de DBeaver a la carpeta de destino
echo "Copiando archivos desde el directorio de origen al directorio de destino..."
cp -r "$directorio_origen"/* "$directorio_destino"

# Verificar si se copiaron los archivos exitosamente
if [ $? -eq 0 ]; then
    echo "Scripts de DBeaver copiados correctamente a: $directorio_destino"
    
    # Notificar que los scripts fueron copiados exitosamente
    notify-send "Copiado exitoso" "Los scripts de DBeaver fueron copiados correctamente a: $directorio_destino"
    
    # Entrar al directorio de destino
    cd "$directorio_destino" || exit
    
    # Realizar el commit
    git add .
    git commit -m "Actualizar scripts de DBeaver"
    
    # Realizar el push a la rama "main"
    git push origin main
    
    # Verificar si el push se realizó correctamente
    if [ $? -eq 0 ]; then
        echo "Commit y push realizados correctamente."
        
        # Notificar que el push fue exitoso
        notify-send "Push exitoso" "Se realizó el commit y push correctamente."
    else
        echo "Error al realizar el push."
        
        # Notificar que ocurrió un error al hacer push
        notify-send "Error en push" "Ocurrió un error al realizar el push."
    fi
else
    echo "Error al copiar los scripts de DBeaver."
    
    # Notificar que ocurrió un error al copiar los scripts
    notify-send "Error en copia" "Ocurrió un error al copiar los scripts de DBeaver."
fi
