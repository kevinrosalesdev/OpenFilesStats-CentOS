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
# 	Usuarios=,$3, (ESTO LO HAGO PARA IDENTIFICAR QUE TODOS LOS USUARIOS SE ENCUENTRAN ENTRE COMAS -> MUY IMPORTANTE PARA LA EFICIENCIA)
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
#       Lectura=0
#       Escritura=0
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
