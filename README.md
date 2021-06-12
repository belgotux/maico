# maico
communicate with your VMC Maico for your home automation

## home automation supported

Currently, only **jeedom** is supported. But I'm open to add your modification for domoticz, home assistant or any other home automation software.

This is not a plugin, juste virtual and bash scripting, it does the job!
But, this is not friendly to setup, you need to know your home automation, this is the first version :)

After, I'm checking to do a "setup" command to configure the script in a second part.

I'm open to work with a dev on a plugin, I'm only a sysadmin :)

## Maico firmware

My maico 320KB is based on a firmware 1.1.0, maybe the xml on your Maico can change if you have another version and the script need adaptation. Please send me the difference if you have another firmware version.

## language

Maico do something bad with language. When you set the language, it change the value in the xml... Not the name, but only the value.
Here an exemple : 
```
<text>
<id>BypassZustand</id>
<value>fermé</value>
</text>
```

My script is based on French, it changes nothing for the numeric values : "18 Jours" or "18 days" is irrelevent because I take only the number.
But it's very bad for the binary values... Exemple with fan status ON/OFF, the xml value is "marche/fermé" in french and not work for your language.

I've put a conversion and need to be modified for your language! If I've received return, I can put this with choices in a config file ;)
```
xml_details=$(curl -s --basic --user admin: http://$ip_maico/details.cgx | iconv -f ISO-8859-1 -t utf8 | sed -e 's/marche/1/g' -e 's/arrêt/0/g' -e 's/fermé/0/g' -e 's/ouvert/1/g')
```


## requirement
Your need this packages : curl libc-bin libxml2-utils

## Help 
Read the wiki to create all the stuff on Jeedom.

I can give help on the [jeedom community](https://community.jeedom.com/t/vmc-maico-obtenir-les-infos-et-commandes/63164)
