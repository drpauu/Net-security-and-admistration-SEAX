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
echo " |  ---------------------------------------------------------------  "
echo " |   Anàlisi de connectivitat a l'equip $target_ip en el port $port/$protocol.  "
echo " |  ---------------------------------------------------------------  "
# Informació de l'equip
hostname=$(hostname)
ip=$(hostname -I | awk '{print $1}')
echo " |  Equip:                  $hostname [$ip]                         "
# Informació de l'usuari
user_info=$(id)
echo " |  Usuari:                 $user_info    "
# Informació del sistema operatiu
if command -v lsb_release &> /dev/null; then
    os_info=$(lsb_release -d | cut -f 2)
else
    os_info=$(grep PRETTY_NAME /etc/os-release | cut -d '=' -f 2 | tr -d '"')
fi
echo " |  Sistema operatiu:       $os_info         "
# Versions dels scripts
echo " |  Versió:                 $script_name $script_version ($script_date_version)     "
echo " |                          info_funcions.sh $functions_script_version ($functions_script_date)    "
# Data d'inici
start_date=$(date '+%Y-%m-%d a les %H:%M:%S')
echo " |  Data d'inici:           $start_date                "
# Data de finalització i durada
end_time=$(date +%s)
duration=$((end_time - start_time))
end_date=$(date '+%Y-%m-%d a les %H:%M:%S')
echo " |  Data de finalització:   $end_date                "
echo " |  Durada de les tasques:  ${duration}s                                       "
echo "  ---------------------------------------------------------------  "
#FINAL INFO INICIAL ------------------------------------------------------------------------------

#SCRIPT "1"-----------------------------------------------------------------------
echo "  ---------------------------------------------------------------  "
echo " │  Estat dels recursos per defecte."            
echo "  ---------------------------------------------------------------  "
# Troba la interfície de xarxa per defecte
default_iface=$(ip route show default | awk '/default/ {print $5}')
resultat=""
morts=""
if [ -n "$default_iface" ]; then
    morts="ok"
    resultat=$default_iface
else
    morts="ko"
    resultat="<<no hi ha ruta predeterminada>>"
fi
echo " |  Intefície per defefcte definida:           [$morts]    $resultat"

# Troba l'adreça MAC de la interfície
resultat=""
morts=""
mac_address=$(ip link show $default_iface | awk '/ether/ {print $2}')
if [ -n "$mac_address" ]; then
    resultat=$mac_address
    morts="ok"
else
    resultat="<<interfície sense adreça MAC>>"
    morts="ko"
fi
echo " |  Intefície per defefcte adreça MAC:         [$morts]    $resultat"

# Troba l'estat de la interfície
resultat=""
morts=""
iface_status=$(ip link show $default_iface | awk '/state/ {print $9}')
if [ -n "$iface_status" ]; then
    resultat=$iface_status
    morts="ok"
else
    resultat="<<interfície desactivada o inexistent>>"
    morts="ko"
fi
echo " |  Intefície per defefcte estat:              [$morts]    $resultat"

# Troba l'adreça IP de la interfície
resultat=""
morts=""
ip_address=$(ip addr show $default_iface | awk '/inet / {print $2}' | cut -d/ -f1)
if [ -n "$ip_address" ]; then
    resultat=$ip_address
    morts="ok"
else
    resultat="<<sense adreça IP assignada>>"
    morts="ko"
fi
echo " |  Intefície per defefcte adreça IP:          [$morts]    $resultat"

# Comprova si l'adreça IP respon
resultat=""
morts=""
# Executa el ping i extreu el temps de resposta
ping_response=$(ping -c 1 $ip_address | grep 'time=')
if [[ $ping_response =~ time=([0-9.]+) ]]; then
    resultat="rtt ${BASH_REMATCH[1]} ms"
    morts="ok"
else
    resultat="<<xarxa inactiva o aïllada>>"
    morts="ko"
fi
echo " |  Intefície per defefcte adreça IP respon:   [$morts]    $resultat"

# Determina l'adreça de xarxa
resultat=""
morts=""
network_addresses=$(ip route | grep $default_iface | grep -v default | awk '{print $1}')
readarray -t address_array <<<"$network_addresses"

if [ "${#address_array[@]}" -ge 2 ]; then
    # Selecciona específicament la segona adreça si n'hi ha més d'una
    resultat="${address_array[1]}"
    morts="ok"
elif [ "${#address_array[@]}" -eq 1 ]; then
    # Si només hi ha una adreça, utilitza-la
    resultat="${address_array[0]}"
    morts="ok"
else
    # Cap adreça trobada
    resultat="<<configuració de xarxa absent>>"
    morts="ko"
fi

echo " |  Intefície per defecte adreça de xarxa:     [$morts]    $resultat"



echo "  "
resultat=""
morts=""
# Troba la gateway per defecte
default_gateway=$(ip route show default | awk '/default/ {print $3}')
if [ -n "$default_gateway" ]; then
    resultat="$default_gateway"
    morts="ok"
else
    morts="ko"
fi
echo " |  Router per defecte definit:                [$morts]    $resultat"

resultat=""
morts=""
# Comprova si la gateway per defecte respon a pings
ping_response=$(ping -c 1 $default_gateway | grep 'time=')
if [[ $ping_response =~ time=([0-9.]+) ]]; then
    resultat="rtt ${BASH_REMATCH[1]} ms"
    morts="ok"
else
    morts="ko"
fi
echo " |  Router per defecte respon:                 [$morts]    $resultat"

resultat=""
morts=""
# Comprova si la gateway per defecte té accés a Internet 
ping_response_internet=$(ping -c 1 1.1.1.1 | grep 'time=')
if [[ $ping_response_internet =~ time=([0-9.]+) ]]; then
    resultat="rtt ${BASH_REMATCH[1]} ms (a 1.1.1.1)"
    morts="ok"
else
    resultat="<<sense accés>>"
    morts="ko"
fi
echo " |  Router per defecte té accés a Internet:    [$morts]    $resultat"

echo "  "
resultat=""
morts=""
# Extreu els servidors DNS configurats del sistema
dns_servers=$(grep "nameserver" /etc/resolv.conf | awk '{print $2}')
if [ -n "$dns_servers" ]; then
    resultat=$dns_servers
    morts="ok"
else
    morts="ko"
fi
echo " |  Servidor DNS per defecte definit:          [$morts]    $resultat"

resultat=""
morts=""
# Intenta fer ping al primer servidor DNS per comprovar la seva disponibilitat
read -ra dns_array <<< "$dns_servers"  # Converteix la cadena en un array
ping_response=$(ping -c 1 ${dns_array[0]} | grep 'time=')
if [[ $ping_response =~ time=([0-9.]+) ]]; then
    resultat="${dns_array[0]}"
    morts="ok"
else
    morts="ko"
fi
echo " |  Servidor DNS per defecte respon:           [$morts]    $resultat"
echo "  ---------------------------------------------------------------  "

#---------------------------------------------------------------------------------

#SCRIPT "2"-----------------------------------------------------------------------
echo "  ---------------------------------------------------------------  "
echo " │  Estat dels recursos dedicats.       " 
echo "  ---------------------------------------------------------------  "
resultat=""
morts=""
echo " |  Interfície de sortida cap al destí:        [$morts]    $resultat"
resultat=""
morts=""
echo " |  Interfície de sortida adreça MAC:          [$morts]    $resultat"
resultat=""
morts=""
echo " |  Interfície de sortida estat:               [$morts]    $resultat"
resultat=""
morts=""
echo " |  Interfície de sortida adreça IP:           [$morts]    $resultat"
resultat=""
morts=""
echo " |  Interfície de sortida adreça IP respon:    [$morts]    $resultat"
resultat=""
morts=""
echo " |  Interfície de sortida adreça de xarxa:     [$morts]    $resultat"
echo "  "
resultat=""
morts=""
echo " |  Router de sortida cap al destí:            [$morts]    $resultat"
resultat=""
morts=""
echo " |  Router de sortida cap al destí respon:     [$morts]    $resultat"
resultat=""
morts=""
echo " |  Router de sortida té accés a Internet:     [$morts]    $resultat"
echo "  ---------------------------------------------------------------  "
#---------------------------------------------------------------------------------

#SCRIPT "3"-----------------------------------------------------------------------
echo "  ---------------------------------------------------------------  "
echo " │  Estat de l'equip destí.       " 
echo "  ---------------------------------------------------------------  "
resultat=""
morts=""
echo " |  Destí nom DNS:                             [$morts]    $resultat"
resultat=""
morts=""
echo " |  Destí adreça IP:                           [$morts]    $resultat"
resultat=""
morts=""
echo " |  Destí port servei:                         [$morts]    $resultat"
echo "  "
resultat=""
morts=""
echo " |  Destí abastable:                           [$morts]    $resultat"
resultat=""
morts=""
echo " |  Destí respon al servei:                    [$morts]    $resultat"
resultat=""
morts=""
echo " |  Destí versió del servei:                   [$morts]    $resultat"
resultat=""
morts=""
echo "  ---------------------------------------------------------------  "
#---------------------------------------------------------------------------------


#FINAL -------------------------------------------------------------------------------------------------
# Captura la data i hora de finalització i la durada
end_time=$(date +%s)
duration=$((end_time - start_time))
end_date=$(date '+%Y-%m-%d a les %H:%M:%S')
echo " |  Data de finalització:   $end_date                "
echo " |  Durada de les tasques:  ${duration}s                                       "
echo "  ---------------------------------------------------------------  "
# Substitueix la quarta línia del fitxer
#awk -v n=4 -v s="$FINISH_LINE1" 'NR == n {print s; next} {print}' "$LOG_FILE" > temp && mv temp "$LOG_FILE"
#awk -v n=5 -v s="$FINISH_LINE2" 'NR == n {print s; next} {print}' "$LOG_FILE" > temp && mv temp "$LOG_FILE"
