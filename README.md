# Open Files Stats - CentOS
<img src="https://img.shields.io/badge/license-MIT-green.svg" />  <img src="https://img.shields.io/badge/version-1.0-red.svg" />  <img src=https://img.shields.io/badge/CentOS-6.10-blue.svg />

This project has been done by these contributors, be sure to **check them out!**:

- [Kevin David Rosales Santana](https://github.com/kevinrosalesdev)
- [Miguel Ángel Medina Ramírez](https://github.com/miguel-kjh)
- [Héctor Henríquez Cabrera](https://github.com/HectorHc2014)

***

The main purpose of this project is to write a Script that shows features about **Open Files in a *Linux System.***

## Requirements:

- Script should be executed in *CentOS* (Preferably in CentOS 6.10)

## How to run Script:

1. **Clone** the Repository.

2. Script should have *execution permission*. If the Script haven't got execution permission, be sure to add it writing in a bash located in the Repository Directory on your computer:

   ```bash
   chmod a+x ./open_files_stats.sh
   ```

3. There are **two ways** of using the Script.

   1. **Show ALL Open File Stats**: `./open_files_stats.sh`
   2. **Show Open File Stats from SPECIFIC USERS separated by commas without spaces**: `./open_files_stats.sh -u user1,user2,user3`

4. After a short loading, **Bash Output should be printed**.

## How does it Work?

Script follows this trace:

1. First, **it reads users** introduced by parameter (-u option) if it's needed and check if they exist.
2. Then, **it searches in /proc/$pid/fd file's descriptors**. By checking their permissions, Script studies if the file is being opened to be read or to be written. Script saves all this information (with file's owner too) in **an associative array** in order to go through /proc only once.
3. Finally, it prints the content of that array like it's shown in [**Output Results**](https://github.com/kevinrosalesdev/OpenFilesStats-CentOS#output-results)

## Output Results:

Output Results should be something like this if nothing goes wrong:

```bash
[Realizando recorrido del /proc...]		<= Script starting...
[Recorrido Finalizado]					<= Script ended
=========================[Fichero Número: 1]========================= 	<= File Number
Fichero=/root/.local/share/gvfs-metadata/home							<= File Name
NºLecturas=2	<= Number of times that file is being opened to be read by processes
NºEscrituras=0	<= Number of times that file is being opened to be written by processes
Usuario=root	<= File Owner's Name
=========================[Fichero Número: 2]=========================
Fichero=/var/log/wpa_supplicant.log
NºLecturas=0
NºEscrituras=1
Usuario=root
=========================[Fichero Número: 3]=========================
Fichero=/dev/cpu_dma_latency
NºLecturas=0
NºEscrituras=1
Usuario=root
[Etc]
```
