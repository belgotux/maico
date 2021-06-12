#!/bin/bash

# Auteur : Belgotux
# Site : www.monlinux.net
# Adresse : belgotux@monlinux.net

#url maico
ip_maico=X.X.X.X
#url jeedom
jeedom_ip=127.0.0.1
jeedom_apikey=
#http://${jeedom_ip}/core/api/jeeApi.php?plugin=virtual&apikey=${jeedom_api}&type=virtual&id=${jeedom_id}&value=${value}

#Nom,Unité,ligne,jeedom_id
list_details="Niveau,,1,854
Débit d’air,m³/h,3,855
Vitesse air entrant,rpm,4,856
Vitesse air sortant,rpm,5,857
Remplacement fitre interne,J,6,858
Remplacement filtre externe,J,8,859
T° référence pièce,°c,12,860
T° entrée ext,°c,14,861
T° air entrant,°c,15,862
T° air sortant,°c,16,863
T° sortie ext,°c,17,864
Humidité,%,18,865
Etat Ventilateur d'air entrant,Bool,25,866
Etat Ventilateur d'air sortant,Bool,26,867
Bypass,Bool,27,868
Registre de chauffe,Bool ,28,869
Contact sec,Bool,29,870"
list_index="Mode,,1,896
Saison,,9,900
Alarme,,14,1181"

#dependances
if [ ! -f /usr/bin/curl ] ; then        echo "Error : curl not present, install curl" ; exit 1 ; fi
if [ ! -f /usr/bin/iconv ] ; then       echo "Error : curl not present, install libc-bin" ; exit 1 ; fi
if [ ! -f /usr/bin/xmllint ] ; then     echo "Error : curl not present, install libxml2-utils" ; exit 1 ; fi

xml_details=$(curl -s --basic --user admin: http://$ip_maico/details.cgx | iconv -f ISO-8859-1 -t utf8 | sed -e 's/marche/1/g' -e 's/arrêt/0/g' -e 's/fermé/0/g' -e 's/ouvert/1/g')
xml_index=$(curl -s --basic --user admin: http://$ip_maico/index.cgx | iconv -f ISO-8859-1 -t utf8 )
#traitement des données de details.cgx
while read line ; do
        #seulement si id jeedom defini
        id_maico=$(echo $line | awk -F, '{print $3}')
        name=$(echo $line | awk -F, '{print $1}')
        value=$(echo "$xml_details" | xmllint --xpath "string(//form/text[$id_maico]/value)" - | awk '{print $1}')
        jeedom_id=$(echo $line | awk -F, '{print $4}')
        #debug
        #echo $line | awk -F, '{print $1}'
        #echo "$xml_details" | xmllint --xpath "string(//form/text[$id_maico]/value)" - | awk '{print $1}'
        #echo $line | awk -F, '{print $3}'

        #exécution uniquement pour les command crée sur le virtuel
        if [ "$jeedom_id" != "" ] ; then
                curl -s "http://${jeedom_ip}/core/api/jeeApi.php?plugin=virtual&apikey=${jeedom_apikey}&type=virtual&id=${jeedom_id}&value=${value}"
        fi
done < <(echo "$list_details")

#traitement du mode dispo sur index.cgx seulement
while read line ; do
        #seulement si id jeedom defini
        id_maico=$(echo $line | awk -F, '{print $3}')
        #name=$(echo $line | awk -F, '{print $1}')
        value=$(echo "$xml_index" | xmllint --xpath "string(//form/text[$id_maico]/value)" - | sed -e 's/ /%20/g')
        jeedom_id=$(echo $line | awk -F, '{print $4}')
        #echo $line | awk -F, '{print $1}'
        #echo "$xml_index" | xmllint --xpath "string(//form/text[$id_maico]/value)" - | awk '{print $1}'
        #echo $line | awk -F, '{print $3}'

        #exécution uniquement pour les command crée sur le virtuel
        if [ "$jeedom_id" != "" ] ; then
                curl -s "http://${jeedom_ip}/core/api/jeeApi.php?plugin=virtual&apikey=${jeedom_apikey}&type=virtual&id=${jeedom_id}&value=${value}"
        fi
done < <(echo "$list_index")

exit 0