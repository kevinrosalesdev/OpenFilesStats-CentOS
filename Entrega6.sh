#!/bin/bash

# ESTO SE TRATA DE UNA VERSIÓN COMENTADA CON EL ALGORITMO A SEGUIR.
#
# Función die(){}
#
# Comprobación de Argumentos:
#
# Si los argumentos son iguales a 1 o > 2
# 	Se debe detener el programa (Existe el caso sin argumento o el caso con 2 argumentos, siendo el último separado por comas)
# Fin si
#
# Si los argumentos son 2
# 	Comprobar que el primer argumento es '-u'. Si no, die().
# 	Usuarios=,$2, (ESTO LO HAGO PARA IDENTIFICAR QUE TODOS LOS USUARIOS SE ENCUENTRAN ENTRE COMAS -> MUY IMPORTANTE PARA LA EFICIENCIA)
# 	Para cada usuario dentro de Usuarios
# 		Comprobar que existe en /etc/passwd. Si no, die().
# 	Fin para
# Fin si
#
# Cuerpo del Script:
#
# FYC=;
#
# Para cada proceso i vigente -> for pid in $(ls /proc | grep -E "[0-9]+" | sort -n)
# 	Para cada fichero f de cada proceso -> Ubicado en la carpeta /proc/$pid/fd
# 		Se busca si dicho fichero ya ha sido contado en la variable FYC (Ficheros Ya Comprobados) -> $(echo $FYC | grep ";$fichero;")
# 		Si dicho fichero había sido ya contado -> continue;
# 		Si dicho fichero no había sido contado ya
#			Usuario=X -> X sería el usuario del fichero. Fácil de averigüar con stat.
# 			Si los argumentos son 2 y Usuario no está en $Usuarios (echo $Usuarios | grep ";$Usuario;") -> Continue
# 			$FYC=$FYC$fichero;
#		        Lectura=0
#       		Escritura=0
# 			Para cada proceso j vigente -> for pid2 in $(ls /proc | grep -E "[0-9]+" | sort -n)
# 				Si el número del proceso nuevo es menor que i -> break; (EVIDENTEMENTE NO HAY QUE CONSIDERAR LOS PROCESOS YA RECORRIDOS -> EFICIENCIA)
# 				Para cada fichero f1 en cada proceso -> Ubicado en la carpeta /proc/$pid2/fd
#					Si f1 = f
# 						Si se está leyendo sobre él -> $Lectura = (( $Lectura+1 ))
# 						Si se está escribiendo sobre él -> $Escritura = (( $Escritura+1 ))
#					Fin si
#			Fin para
# 		Fin si
# 	echo "Fichero = $Fichero	NºLecturas = $Lectura	NºEscrituras = $Escritura	Propietario = $Usuario"
# 	Fin Para
# Fin Para
die()
{
	echo "$0:$1" 1>&2
	exit 1

}

#Comprobaciones
if(($# == 1 || $# > 2)); then 
	die "Fallo en el argumento"
fi
if(($# == 2)); then 
	[[ $1 == "-u" ]] || die "No se encontro la opción -u"
	for usuario in $(echo $2 | tr "," "\n"); do
		id $usuario >/dev/null 2>/dev/null
		if(( $? == 1)); then
			die "El usuario $usuario no existe"
		fi
	done	
fi

#Cuerpo del programa
usuarios=",$2,"
FYC=","
for pid in $(ls /proc | grep -E "[0-9]+" | sort -n);do
	echo "PID==$pid"
	#suele haber fallos en los últimos procesos porque no tiene el fd-->los fallos a la basura
	for fichero in $(ls /proc/$pid/fd 2> /dev/null); do
		#tendríamos que sacar del descriptor de ficheros el fichero en sí al que hace referencia
		echo $FYC | grep ",$fichero," >/dev/null 2>/dev/null
		if(( $? == 1 )); then
			usuario=$(stat -c "%U" "/proc/$pid/fd/$fichero" 2> /dev/null)
			echo $usuarios | grep "$usuario" >/dev/null 2>/dev/null			
			if(($? == 1 && $# == 2)); then
				continue
			fi
			$FYC=$FYC$fichero,
			Lectura=0
			Escritura=0
			//CONTINUAR AQUÍ
			//Parte de Héctor empieza aquí
			for pid2 in  $(ls /proc | grep -E "[0-9]+" | sort -n ); do
				if   (( $pid2 < $pid));then
					break;
				fi
				for f1 in $(ls /proc/$pid2/fd);do
					if [ $f1=$fichero ] ; then
						if [ -t  /proc/$pid2/fd/$f1 ]; then
							Lectura= $(( $Lecutra + 1 ))
						fi
						if [ -h /proc/$pid2/fd/$f1 ];then
							Escritura= $(( $Escritura + 1 ))
						fi
					fi
				done
			done
			//Parte de Héctor  termina aquí
		else 
			continue
		fi
		echo "Resultado ="
	done
done
exit 0
