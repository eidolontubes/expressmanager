#!/bin/bash

HEIGHT=20
WIDTH=47

HEIGHT2=30
WIDTH2=120

CHOICE_HEIGHT=10
BACKTITLE="ExpressVPN Manager - (v1.1) - Summer 2019 by cameron.r.childs@gmail.com"
TITLE="ExpressVPN Manager"
MENU="Choose one of the following options:"

OPTIONS=(1 "ExpressVPN Status"
         2 "ExpressVPN Connect"
         3 "ExpressVPN Disconnect"
	 4 "Monitor ExpressVPN Status"
	 5 "List Recommended VPN Server Locations"
	 6 "List ALL VPN Server Locations"
	 7 "Set ExpresVPN Server"
	 8 "Run SpeedTest-CLI"
	 9 "Exit")

CONTPROG=1

if which dialog >/dev/null; then
	echo Dialog is installed on this system. 
else
	echo Dialog is not installed and is required for ExpressVPN Manager to run.
	echo It might be installable with a command like "sudo apt install dialog".	
	exit;
fi

while [ $CONTPROG -eq 1 ] 
do
	CHOICE=$(dialog --clear \
	                --backtitle "$BACKTITLE" \
	                --title "$TITLE" \
	                --menu "$MENU" \
	                $HEIGHT $WIDTH $CHOICE_HEIGHT \
	                "${OPTIONS[@]}" \
        	        2>&1 >/dev/tty)

	# If cancelled, drop the dialog
	if [ $? -ne 0 ]; then
		clear;
        	exit;
    	fi;

	clear
	case $CHOICE in
	        1)
		    expressvpn status > /tmp/a654312 2>&1
		    dialog --backtitle "$BACKTITLE" \
			   --keep-colors \
			   --no-collapse \
			   --title "$TITLE" \
			   --msgbox "$(cat /tmp/a654312 | sed -r "s/[[:cntrl:]]\[([0-9]{1,3};)*[0-9]{1,3}m//g")" $HEIGHT2 $WIDTH2
		    #read -n 1 -s -r -p "Press any key to continue"
	            ;;
	        2)
	            expressvpn connect
		    read -n 1 -s -r -p "Press any key to continue"
	            ;;
	        3)
	            expressvpn disconnect
		    read -n 1 -s -r -p "Press any key to continue"
	            ;;
	        4)
		    watch --color -n 10 "expressvpn status;echo "press CTRL-C to exit""
        	    ;;
	        5)
		    expressvpn list >/tmp/a654312
		    dialog --backtitle "$BACKTITLE" \
			   --keep-colors \
			   --no-collapse \
			   --title "$TITLE" \
			   --msgbox "$(cat /tmp/a654312 | sed -r "s/[[:cntrl:]]\[([0-9]{1,3};)*[0-9]{1,3}m//g")" $HEIGHT2 $WIDTH2
        	    ;;
	        6)
		    expressvpn list all >/tmp/a654312
		    dialog --backtitle "$BACKTITLE" \
			   --keep-colors \
			   --no-collapse \
			   --title "$TITLE - Press PAGE UP / PAGE DOWN to scroll" \
			   --msgbox "$(cat /tmp/a654312 | sed -r "s/[[:cntrl:]]\[([0-9]{1,3};)*[0-9]{1,3}m//g")" $HEIGHT2 $WIDTH2
        	    ;;
	        
	        7)
		    expressvpn list >/tmp/a654312
		    sed '/^$/d' /tmp/a654312 > /tmp/a654313
		    cat /tmp/a654313 | sed 's/Recommended Locations://g' >/tmp/a654314
		    cat /tmp/a654314 | sed 's/Type ‘expressvpn list all’ to see all locations.//g' >/tmp/a654315
		    echo "In the box below, enter the ALIAS for the VPN server to connect to." >>/tmp/a654315
		    echo "THIS WILL BRIEFLY DISCONNECT THIS SYSTEM FROM THE VPN." >>/tmp/a654315
		    dialog --backtitle "$BACKTITLE" \
			   --keep-colors \
			   --no-collapse \
			   --title "$TITLE" \
			   --inputbox "$(cat /tmp/a654315)" $HEIGHT2 $WIDTH2 smart 2> /tmp/a2312
		    clear
		    echo
			# If the User did not pres Cancel
		    if [[ -s /tmp/a2312 ]]; then
		  	    expressvpn disconnect
			    expressvpn connect $(cat /tmp/a2312)
			    expressvpn status >/tmp/a654312
			    dialog --backtitle "$BACKTITLE" \
				   --keep-colors \
				   --no-collapse \
				   --title "$TITLE" \
				   --msgbox "$(cat /tmp/a654312 | sed -r "s/[[:cntrl:]]\[([0-9]{1,3};)*[0-9]{1,3}m//g")" $HEIGHT2 $WIDTH2
		    
		    else 
			    dialog --backtitle "$BACKTITLE" \
			   	   --keep-colors \
				   --no-collapse \
				   --title "$TITLE" \
				   --msgbox "User Pressed Cancel." $HEIGHT2 $WIDTH2
		    fi

		    ;;
	        8)
		   if [ -f /usr/bin/speedtest-cli ]; then
		      /usr/bin/speedtest-cli
		   else
		      echo "This feature requires the speedtest-cli package."
		      echo "speedtest-cli might be able to be installed with a command like 'sudo apt install speedtest-cli'"
		   fi
		   read -n 1 -s -r -p "Press any key to continue"
        	    ;;
	        9)
		    CONTPROG=$(( $CONTPROG -1))
        	    ;;
	esac

done

