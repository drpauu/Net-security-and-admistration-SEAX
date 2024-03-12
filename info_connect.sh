#!/bin/bash

# Verificar si l'usuari es root (sudo)
if [ "$EUID" -ne 0 ]; then
		echo "Siusplau, executa el script com a root."
		exit 1
else
	LOG_FILE="log_connect.log"
	#INFO INICIAL ------------------------------------------------------------------
	# Assignació dels arguments a variables
	target_ip=$1
	port=$2
	protocol=$3

	#target_ip="10.1.1.1"
	#port=80
	#protocol="tcp"


	# Nom del fitxer de l'script
	script_name="info_connect.sh"
	script_version="v.0.123"
	script_date_version="28/04/2023"
	functions_script_version="v.0.123"
	functions_script_date="03/05/2023"

	# Inicia el temps
	start_time=$(date +%s)

	# Inicia l'anàlisi
	#target_ip="10.1.1.1"
	#port=80
	echo " |  ---------------------------------------------------------------  " > $LOG_FILE
	echo " |   Anàlisi de connectivitat a l'equip $target_ip en el port $port/$protocol.  " >> $LOG_FILE
	echo " |  ---------------------------------------------------------------  " >> $LOG_FILE
	# Informació de l'equip
	hostname=$(hostname)
	ip=$(hostname -I | awk '{print $1}')
	echo " |  Equip:                  $hostname [$ip]                         " >> $LOG_FILE
	# Informació de l'usuari
	user_info=$(id)
	echo " |  Usuari:                 $user_info    " >> $LOG_FILE
	# Informació del sistema operatiu
	if command -v lsb_release &> /dev/null; then
		os_info=$(lsb_release -d | cut -f 2)
	else
		os_info=$(grep PRETTY_NAME /etc/os-release | cut -d '=' -f 2 | tr -d '"')
	fi
	echo " |  Sistema operatiu:       $os_info         " >> $LOG_FILE
	# Versions dels scripts
	echo " |  Versió:                 $script_name $script_version ($script_date_version)     " >> $LOG_FILE
	echo " |                          info_funcions.sh $functions_script_version ($functions_script_date)    " >> $LOG_FILE
	# Data d'inici
	start_date=$(date '+%Y-%m-%d a les %H:%M:%S')
	echo " |  Data d'inici:           $start_date                " >> $LOG_FILE
	# Data de finalització i durada
	end_time=$(date +%s)
	duration=$((end_time - start_time))
	end_date=$(date '+%Y-%m-%d a les %H:%M:%S')
	echo " |  Data de finalització:   $end_date                " >> $LOG_FILE
	echo " |  Durada de les tasques:  ${duration}s                                       " >> $LOG_FILE
	echo "  ---------------------------------------------------------------  " >> $LOG_FILE
	#FINAL INFO INICIAL ------------------------------------------------------------------------------

	#SCRIPT "1"-----------------------------------------------------------------------
	echo "  ---------------------------------------------------------------  " >> $LOG_FILE
	echo " │  Estat dels recursos per defecte."         >> $LOG_FILE    
	echo "  ---------------------------------------------------------------  " >> $LOG_FILE
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
	echo " |  Intefície per defefcte definida:           [$morts]    $resultat" >> $LOG_FILE

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
	echo " |  Intefície per defefcte adreça MAC:         [$morts]    $resultat" >> $LOG_FILE

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
	echo " |  Intefície per defefcte estat:              [$morts]    $resultat" >> $LOG_FILE

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
	echo " |  Intefície per defefcte adreça IP:          [$morts]    $resultat" >> $LOG_FILE

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
	echo " |  Intefície per defefcte adreça IP respon:   [$morts]    $resultat" >> $LOG_FILE

	# Determina l'adreça de xarxa
	resultat=""
	morts=""
    network_address=$(ip route | grep $default_iface | grep -v default | awk '{print $1}')

    if [ -n "$network_address" ]; then
        # Si només hi ha una adreça, utilitza-la
        resultat=$network_address
        morts="ok"
    else
        # Cap adreça trobada
        resultat="<<configuració de xarxa absent>>"
        morts="ko"
    fi

	echo " |  Intefície per defecte adreça de xarxa:     [$morts]    $resultat" >> $LOG_FILE
 


	echo "  " >> $LOG_FILE
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
	echo " |  Router per defecte definit:                [$morts]    $resultat" >> $LOG_FILE
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
	echo " |  Router per defecte respon:                 [$morts]    $resultat" >> $LOG_FILE
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
	echo " |  Router per defecte té accés a Internet:    [$morts]    $resultat">> $LOG_FILE

	echo "  " >> $LOG_FILE
    resultat=""
	morts=""
    dns_servers=$(grep 'nameserver' /etc/resolv.conf | awk '{print $2}') #retornar llista de nameserver -dns
    if [ -z "$dns_servers" ]; then  # Si retorna una llista dns buida
        morts="ko"
        resultat="-"
    else 
        resultat=$dns_servers
        morts="ok"
    fi
	echo " |  Servidor DNS per defecte definit:          [$morts]    $resultat">> $LOG_FILE
	resultat=""
	morts=""
    dns_servers=$(grep 'nameserver' /etc/resolv.conf | awk '{print $2}'| head -n 1)
    if [ -z "$dns_servers" ]; then  # Si retorna un dns per defecte buit
        resultat="-"
        morts="ko"
    else 
        resultat=$dns_servers
        morts="ok"
    fi
	echo " |  Servidor DNS per defecte respon:           [$morts]    $resultat">> $LOG_FILE
	echo "  ---------------------------------------------------------------  ">> $LOG_FILE
	#---------------------------------------------------------------------------------

	#SCRIPT "2"-----------------------------------------------------------------------
	echo "  ---------------------------------------------------------------  ">> $LOG_FILE
	echo " │  Estat dels recursos dedicats.       " >> $LOG_FILE
	echo "  ---------------------------------------------------------------  ">> $LOG_FILE
	resultat=""
	morts=""
	interface=$(ip route show | awk '/default/ {print $5}')
	
	if [ -z $interface ]; then
		morts="ko"
	else
		morts="ok"
	fi
	resultat=$interface
	echo " |  Interfície de sortida cap al destí:        [$morts]    $resultat">> $LOG_FILE
	resultat=""
	morts=""
	mac=$(ip route | awk '/default/ {print $5}' | xargs ip link show | awk '/link\/ether/ {print $2}')
	
	if [ -z $mac ]; then
		morts="ko"
	else
		morts="ok"
	fi
	resultat=$mac
	echo " |  Interfície de sortida adreça MAC:          [$morts]    $resultat">> $LOG_FILE
	resultat=""
	morts=""
	interface_state=$(ip route | awk '/default/ {print $5}' | xargs ip link show | awk '/state/ {print $9}')
	
	if [ -z $interface_state ]; then
		morts="ko"
	else
		morts="ok"
	fi
	resultat=$interface_state
	echo " |  Interfície de sortida estat:               [$morts]    $resultat">> $LOG_FILE
	resultat=""
	morts=""
	interface_ip=$(ip route get 1.1.1.1 | grep -oP 'src \K\S+')
	
	if [ -z $interface_ip ]; then
		morts="ko"
	else
		morts="ok"
	fi
	resultat=$interface_ip
	echo " |  Interfície de sortida adreça IP:           [$morts]    $resultat">> $LOG_FILE
	resultat=""
	morts=""
	ip_address=$(ip route | awk '/default/ {print $3}')
	rtt=$(ping -c 4 $ip_address | tail -1 | awk -F'/' '{print $5}')
	if [ -z $rtt ]; then
		morts="ko"
	else
		morts="ok"
	fi
	resultat=$rtt
	echo " |  Interfície de sortida adreça IP respon:    [$morts]    rtt $resultat ms">> $LOG_FILE
	resultat=""
	morts=""
	interface=$(ip route | awk '/default/ {print $5}')
	ip_address=$(ip route | awk '/default/ {print $1}')
	network_address=$(ip -o -f inet addr show dev $interface | awk '/inet / {print $4}' | cut -d '/' -f 1)

	if [ -z $network_address ]; then
		morts="ko"
	else
		morts="ok"
	fi
	resultat=$network_address
	echo " |  Interfície de sortida adreça de xarxa:     [$morts]    $resultat">> $LOG_FILE
	echo "  ">> $LOG_FILE
	resultat=""
	morts=""
	echo " |  Router de sortida cap al destí:            [$morts]    $resultat">> $LOG_FILE
	resultat=""
	morts=""
	echo " |  Router de sortida cap al destí respon:     [$morts]    $resultat">> $LOG_FILE
	resultat=""
	morts=""
	echo " |  Router de sortida té accés a Internet:     [$morts]    $resultat">> $LOG_FILE
	echo "  ---------------------------------------------------------------  ">> $LOG_FILE
	#---------------------------------------------------------------------------------

	#SCRIPT "3"-----------------------------------------------------------------------
	echo "  ---------------------------------------------------------------  ">> $LOG_FILE
	echo " │  Estat de l'equip destí.       " >> $LOG_FILE
	echo "  ---------------------------------------------------------------  ">> $LOG_FILE
	resultat=""
	morts=""
	dns=$(dig -x $target_ip +short | tail -n 1)
	if [ -z $dns ]; then
		morts="ko"
	else
		morts="ok"
	fi
	resultat=$dns
	echo " |  Destí nom DNS:                             [$morts]    $resultat">> $LOG_FILE
	resultat=$target_ip
	morts=""
	if [ -z $resultat ]; then
		morts="ko"
	else
		morts="ok"
	fi
	echo " |  Destí adreça IP:                           [$morts]    $resultat">> $LOG_FILE
	resultat=""
	morts=""
	port_dest=$(nmap -p $port --open $target_ip | grep "open" | awk '{print $1 "/" $3}')
	if [ -z $port_dest ]; then
		morts="ko"
	else
		morts="ok"
	fi
	resultat=$port_dest
	echo " |  Destí port servei:                         [$morts]    $resultat">> $LOG_FILE
	echo "  ">> $LOG_FILE
	resultat=""
	morts=""
	latency=$(nmap -p $port $target_ip 2>&1 | grep "Host is up" | awk '{print $7}')
	latency=$((latency * 1000))
	if [ -z $latency ]; then
		morts="ko"
		resultat="<< L'equip no respon >>"
	else
		morts="ok"
		resultat=$latency" ms"
	fi
	echo " |  Destí abastable:                           [$morts]    $resultat">> $LOG_FILE
	resultat=""
	morts=""
	respon=""
	if [ -z $respon ]; then
		morts="ko"
		resultat="<< El port no respon >>"
	else
		morts="ok"
		resultat=$respon" ms"
	fi
	echo " |  Destí respon al servei:                    [$morts]    $resultat">> $LOG_FILE
	resultat=""
	morts=""
	version=""
	if [ -z $version ]; then
		morts="ko"
		resultat="<< Versió no identificada >>"
	else
		morts="ok"
		resultat=$version" ms"
	fi
	echo " |  Destí versió del servei:                   [$morts]    $resultat">> $LOG_FILE
	echo "  ---------------------------------------------------------------  ">> $LOG_FILE
	#---------------------------------------------------------------------------------


	#FINAL -------------------------------------------------------------------------------------------------
	# Captura la data i hora de finalització i la durada
	end_time=$(date +%s)
	duration=$((end_time - start_time))
	end_date=$(date '+%Y-%m-%d a les %H:%M:%S')
	echo " ║  Data de finalització:   $end_date                ">> $LOG_FILE
	echo " ║  Durada de les tasques:  ${duration}s                                       ">> $LOG_FILE
	echo "  ---------------------------------------------------------------  ">> $LOG_FILE
	# Substitueix la quarta línia del fitxer
	#awk -v n=4 -v s="$FINISH_LINE1" 'NR == n {print s; next} {print}' "$LOG_FILE" > temp && mv temp "$LOG_FILE"
	#awk -v n=5 -v s="$FINISH_LINE2" 'NR == n {print s; next} {print}' "$LOG_FILE" > temp && mv temp "$LOG_FILE"
fi

