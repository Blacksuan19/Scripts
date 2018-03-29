#! /bin/sh
# dark shell grave. 
ARCH=$(uname -m)
OS=$(hostnamectl | awk '{$1=$3="";sub(/^[ \t]+/, "")}NR==7')
HOST=$(hostnamectl | awk '{$1=$2="";sub(/^[ \t]+/, "")}NR==1')
DISTRO=$(lsb_release -sirc | awk '{print $3 " " $2}')
KERNEL=$(hostnamectl | awk -F- '/Kernel/{ OFS="-";NF--; print }'|awk '{print $3}')
UPTIME=$(awk '{printf("%dd %02dh %02dm",($1/60/60/24),($1/60/60%24),($1/60%60))}' /proc/uptime)
MODEL=$(cat /sys/devices/virtual/dmi/id/board_{name,vendor} | awk '!(NR%2){print$1,p}{p=$0}')
DE=$(plasmashell --version | awk '{print $2}') # i use kde plasma, feel free to change this according to your DE/WM.
CPU=$(awk < /proc/cpuinfo '/model name/{print $5}' | head -1)
TEMP=$(cat /sys/class/hwmon/hwmon0/temp1_input | awk '{print $1 / 1000}')
GPU=$(lspci | awk '/VGA/{print $11,$12,$13}' | tr -d '[]')
MEMORY=$(cat /proc/meminfo | grep MemAvailable | awk '$2 { print substr($2/1000/1000,1,4)}')
SHELL=$(zsh --version | awk '{sub(".", substr(toupper($i),1,1) , $i); print $1" "$2}') # i use zsh if you use another shell change this accordingly.
BIRTH=$(ls -alct --full-time /etc | tail | sed '$!d' | awk '{print $6}')
Packages=$(pacman -Q | awk 'END {print NR}') # if you dont use arch then what??
ICONS=$(cat ~/.kde4/share/config/kdeglobals | grep Theme | sed 's/Theme=//g')
COLORS=$(cat ~/.kde4/share/config/kdeglobals | grep ColorScheme | sed 's/ColorScheme=//g')
# get currently playing song (spotify and clementine only).
if pgrep -x "spotify" > /dev/null
then
	Playing=$(dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 \
            org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' \
            string:'Metadata' |\
            awk -F 'string "' '/string|array/ {printf "%s",$2; next}{print ""}' |\
            awk -F '"' '/artist/ {a=$2} /title/ {t=$2} END{print a " - " t}')
	m_ICON=$(echo )
else if pgrep -x "clementine" > /dev/null
then
	Playing=$(dbus-send --print-reply --dest=org.mpris.MediaPlayer2.clementine /org/mpris/MediaPlayer2 \
            org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' \
            string:'Metadata' |\
            awk -F 'string "' '/string|array/ {printf "%s",$2; next}{print ""}' |\
            awk -F '"' '/artist/ {a=$2} /title/ {t=$2} END{print a " - " t}')
	m_ICON=$(echo )
else 
	Playing=$(echo "No Supported Player Is Running")
	m_ICON=$(echo )
fi
fi

clear # clear the screen first before processing output.
 echo  ""
 echo -e "\\e[91m   --------------------"
 echo "   SYSTEM INFORMATION"
 echo "   --------------------"
 echo  ""
 echo -e "\\e[94m     \\e[39m$MODEL"
 echo -e "\\e[94m     \\e[39m$DISTRO"
 echo -e "\\e[94m     \\e[39m$OS$ARCH"
 echo -e "\\e[94m     \\e[39m$KERNEL"
 echo -e "\\e[94m     \\e[39m$UPTIME"
 echo -e "\\e[94m     \\e[39m$SHELL"
 echo -e "\\e[94m     \\e[39m$CPU [$TEMP.0°C]"
 echo -e "\\e[94m     \\e[39m$GPU" 
 echo -e "\\e[94m     \\e[39m"$MEMORY"G Free" 
 echo -e "\\e[94m   --------------------"
 echo -e "\\e[94m     \\e[39mPlasma $DE"
 echo -e "\\e[94m     \\e[39m$ICONS "
 echo -e "\\e[94m     \\e[39m$COLORS "Scheme""
 echo -e "\\e[94m     \\e[39m$BIRTH"
 echo -e "\\e[94m   --------------------"
 echo -e "\\e[94m     \\e[39m$Packages"
 echo -e "\\e[94m   $m_ICON  \\e[39m$Playing"
 echo  ""
 