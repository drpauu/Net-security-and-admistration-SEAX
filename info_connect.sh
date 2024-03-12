#!/bin/bash


#INFO INICIAL ------------------------------------------------------------------
# Assignació dels arguments a variables
target_ip=$1
port=$2
protocol=$3

target_ip="10.1.1.1"
port=80
protocol="tcp"


# Nom del fitxer de l'script
script_name="info_connect.sh"
script_version="v.0.123"
script_date_version="28/04/2023"
functions_script_version="v.0.123"
functions_script_date="03/05/2023"

# Inicia el temps
start_time=$(date +%s)

# Inicia l'anàlisi
target_ip="10.1.1.1"
port=80
echo " ║  ---------------------------------------------------------------  "
echo " ║   Anàlisi de connectivitat a l'equip $target_ip en el port $port/$protocol.  "
echo " ║  ---------------------------------------------------------------  "
# Informació de l'equip
hostname=$(hostname)
ip=$(hostname -I | awk '{print $1}')
echo " ║  Equip:                  $hostname [$ip]                         "
# Informació de l'usuari
user_info=$(id)
echo " ║  Usuari:                 $user_info    "
# Informació del sistema operatiu
if command -v lsb_release &> /dev/null; then
    os_info=$(lsb_release -d | cut -f 2)
else
    os_info=$(grep PRETTY_NAME /etc/os-release | cut -d '=' -f 2 | tr -d '"')
fi
echo " ║  Sistema operatiu:       $os_info         "
# Versions dels scripts
echo " ║  Versió:                 $script_name $script_version ($script_date_version)     "
echo " ║                          info_funcions.sh $functions_script_version ($functions_script_date)    "
# Data d'inici
start_date=$(date '+%Y-%m-%d a les %H:%M:%S')
echo " ║  Data d'inici:           $start_date                "
# Espera (simulació de tasques)
sleep 9
# Data de finalització i durada
end_time=$(date +%s)
duration=$((end_time - start_time))
end_date=$(date '+%Y-%m-%d a les %H:%M:%S')
echo " ║  Data de finalització:   $end_date                "
echo " ║  Durada de les tasques:  ${duration}s                                       "
echo "  ---------------------------------------------------------------  "
#FINAL INFO INICIAL ------------------------------------------------------------------------------

#SCRIPT "1"-----------------------------------------------------------------------

#---------------------------------------------------------------------------------

#SCRIPT "2"-----------------------------------------------------------------------

#---------------------------------------------------------------------------------

#SCRIPT "3"-----------------------------------------------------------------------

#---------------------------------------------------------------------------------


#FINAL -------------------------------------------------------------------------------------------------
# Captura la data i hora de finalització i la durada
end_time=$(date +%s)
duration=$((end_time - start_time))
end_date=$(date '+%Y-%m-%d a les %H:%M:%S')
echo " ║  Data de finalització:   $end_date                "
echo " ║  Durada de les tasques:  ${duration}s                                       "
echo "  ---------------------------------------------------------------  "
# Substitueix la quarta línia del fitxer
#awk -v n=4 -v s="$FINISH_LINE1" 'NR == n {print s; next} {print}' "$LOG_FILE" > temp && mv temp "$LOG_FILE"
#awk -v n=5 -v s="$FINISH_LINE2" 'NR == n {print s; next} {print}' "$LOG_FILE" > temp && mv temp "$LOG_FILE"
