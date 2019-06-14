#!/bin/bash

#Función que se encarga de salir del Script notificando un error.
die()
{
	echo "$0:$1" 1>&2
	exit 1

}

#Comprobaciones del número de argumentos.
if(($# == 1 || $# > 2)); then 
	die "Fallo en el argumento"
fi

#Comprobaciones en el caso de introducir usuarios propietarios.
if(($# == 2)); then 
	[[ $1 == "-u" ]] || die "No se encontró la opción -u"
	for usuario in $(echo $2 | tr "," "\n"); do
		id ${usuario} >/dev/null 2>/dev/null
		if(( $? == 1)); then
			die "El usuario ${usuario} no existe"
		fi
	done	
fi

#Cuerpo del programa.
#Se encierran los usuarios en dos ',' para facilitar su búsqueda a lo largo del programa.
usuarios=",$2,"

#Se declara el array asociativo ficheros. Dicho array contendrá como clave el fichero y como valor 'NºLecturas NºEscrituras Propietario'
unset ficheros
declare -A ficheros

#Se realiza el recorrido por los fd del /proc
echo "[Realizando recorrido del /proc...]"
for pid in $(ls /proc | grep -E "[0-9]+"); do
	for identificador in $(ls /proc/$pid/fd 2>/dev/null); do
		#Se controla el error que ocurre cuando se intenta acceder a un proceso que ha acabado entre ambos for.
		if (( $? == 1 )); then
                        continue
                fi

		#Se extrae el fichero y su propietario correspondiente del descriptor de fichero.
		fichero=$(stat -c "%N" /proc/${pid}/fd/${identificador} | cut -f3 -d"«" | tr "»" "\0")
		usuario=$(stat -c "%U" "${fichero}" 2>/dev/null)

		#Se controla la existencia de Pipes, Sockets y ficheros que no existen realmente.
		if (( $? == 1 )); then
                        continue
                fi

		#En caso de que se requiera que su propietario esté en la lista pasada por argumento, se comprueba. Si concuerda con lo requerido y no está en el array, se introduce.
                if (( $# == 2 && $(echo ${usuarios} | grep ",${usuario}," | wc -m) == 0 )); then
                        continue
                elif (( $(echo "${ficheros[${fichero}]}" | wc -m) == 1 )); then
			ficheros[${fichero}]="0 0 ${usuario}"
		fi

		#Se extraen sus permisos y se suman a su número de lecturas y escrituras de los procesos.
		perm=$(stat -c "%a" /proc/${pid}/fd/${identificador})
		if(((0x${perm} & 0x400) != 0)); then
			lecturaActual=$(echo "${ficheros[${fichero}]}" | cut -f1 -d" ")
			escrituraActual=$(echo "${ficheros[${fichero}]}" | cut -f2 -d" ")
			ficheros[${fichero}]="$(( ${lecturaActual} + 1 )) ${escrituraActual} ${usuario}"
		fi
		if(((0x${perm} & 0x200) != 0)); then
			lecturaActual=$(echo "${ficheros[${fichero}]}" | cut -f1 -d" ")
			escrituraActual=$(echo "${ficheros[${fichero}]}" | cut -f2 -d" ")
                        ficheros[${fichero}]="${lecturaActual} $(( ${escrituraActual} + 1 )) ${usuario}"
		fi
	done
done
echo "[Recorrido Finalizado]"
numFicheros=1

#Se imprime lo pedido en el enunciado a través del contenido del array asociativo.
for resultado in "${!ficheros[@]}"; do
	echo "=========================[Fichero Número: ${numFicheros}]========================="
	echo "Fichero=${resultado}"
	echo "NºLecturas=$(echo "${ficheros[${resultado}]}" | cut -f1 -d" ")"
	echo "NºEscrituras=$(echo "${ficheros[${resultado}]}" | cut -f2 -d" ")"
	echo "Usuario=$(echo "${ficheros[${resultado}]}" | cut -f3 -d" ")"
	numFicheros=$(( ${numFicheros} + 1 ))
done
echo "[Script Finalizado con Éxito]"

exit 0
