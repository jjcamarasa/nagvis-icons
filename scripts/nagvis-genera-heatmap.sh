#!/bin/bash
# Genera un mapa de calor amb tots els hosts de nagios
# Cada host esta representat per una linea externa del color si esta up/down i un quadrat intern amb l'estat general
# 1.0	J.Camarasa	2021-06-22	Versio inicial
# 1.1	J.Camarasa	2021-07-15	Canvi de tamany del iconset, se eliminen els shapes que formaven la part de darrere de cada host	
# 1.2	J.Camarasa	2021-08-26	Canvi de forma de la icona a 160x124	

NAGDIR="/opt/nagvis"
OUTDIR=$NAGDIR"/etc/maps"
OUTMAP=$OUTDIR"/cpd-heatmap-hosts.cfg"
IMGOK="cube-extern-ok.png"
IMGCRIT="cube-extern-critical.png"
#echo "Generant mapes"
echo "define global {
alias=Mapa de calor
parent_map=cpd
object_id=0
#iconset=put-your-iconset-here
label_show=1
label_y=+17
label_background=transparent
label_border=transparent
label_style=color:#fff;font-size:2em;
label_maxlen=13
background_color=#0B0C0E
}

define textbox {
text=ESTADO GENERAL DE LOS SISTEMAS
x=10
y=0
w=1080
h=24
object_id=40b48a
border_color=transparent
background_color=transparent
style=color:#FFFFFF;font-size:3.5em;
}

" > $OUTMAP

# Obtindre llistat d'equips
HOSTLIST=$(printf "GET hosts\nColumns: name state\n" | unixcat /opt/nagios/var/rw/live)

# Control de pantalla
initx=10
inity=75
xhexa=0
yhexa=0
last_x=$initx
last_y=$inity
last_pos=0
last_id=110000
sep_x=205
sep_y=34
linea=1
max_x=$((17 * $sep_x))

# Generacio dels hosts amb els cubs de color
for item in ${HOSTLIST[@]};do
 this_name=${item%;*}
 STATE=${item#*;}
 this_img=$IMGOK
 this_x=$last_x
 this_y=$last_y
 this_id=$last_id

if [ $STATE -ne 0 ];then
 this_img=$IMGCRIT
fi

tee -a $OUTMAP << EOF
define host {
host_name=$this_name
x=$this_x
y=$this_y
object_id=$((this_id+1))
}

EOF

# Actualitza valors de x,y,id
last_x=$((last_x+205))
local_y=$last_y

if [ $yhexa -lt 1 ];then
 local_y=$((local_y - 34))
 yhexa=1
else
 local_y=$((local_y + 34))
 yhexa=0
fi

last_y=$local_y

if [ $last_x -gt $max_x ];then
 linea=$((linea + 1))
 last_y=$((last_y + 70))
 yhexa=0
 if [ $xhexa -lt 1 ];then
  xhexa=1
 else
  last_x=$initx
  xhexa=0
 fi
fi

 last_id=$((this_id+2))
done

# Permisos del fitxer
chown www-data:www-data $OUTMAP
chmod 660 $OUTMAP

echo "Generacio acabada"
exit 0

