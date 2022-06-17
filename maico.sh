#!/bin/bash

# Auteur : Belgotux
# Site : www.monlinux.net
# Adresse : belgotux@monlinux.net


MY_PATH="`dirname \"$0\"`"
confdir="$MY_PATH"

# configuration of your network
if [ ! -f $confdir/maico.conf ] ; then   echo "Error : please create config file maico.conf based on maico.conf.example first!" ; exit 1 ; fi
source $confdir/maico.conf

# configuration of the virtual in jeedom
if [ ! -f $confdir/mapping_virtual_jeedom.conf ] ; then   echo "Error : please add the mapping_virtual_jeedom.conf file in $confdir" ; exit 1 ; fi
source $confdir/mapping_virtual_jeedom.conf

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
                curl -s "http://${jeedom_ip}/core/api/jeeApi.php?plugin=virtual&type=event&apikey=${jeedom_apikey}&id=${jeedom_id}&value=${value}"
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