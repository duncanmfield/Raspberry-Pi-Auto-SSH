#!/bin/sh

device_name="Raspberry Pi"	# Name of the Raspberry Pi to search for
mask_inc=32					# How many IPs nmap should scan at a time
base_ip="192.168.0."		# IPs to scan over (0 to 255 will be appended to the end)

pi_scan () {
	mask_low=$1
	mask_high=$2
	
	ip_regex="((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)"
	
	echo "Searching for '$device_name' in IP range $base_ip$mask_low-$mask_high"
	ip=$(nmap -sn -n $base_ip$mask_low-$mask_high | grep -B 2 "$device_name" | grep -oE $ip_regex)
	if test -z $ip
	then
		if (($mask_high == 255))
		then
			echo "Could not find '$device_name' on local network."
			read -p "Press any key to exit.."
			exit 1
		else	
			mask_low=$(($mask_high + 1))
			mask_high=$(($mask_high + $mask_inc))
			if (($mask_high > 255))
			then
				mask_high=255
			fi
			pi_scan $mask_low $mask_high
			
		fi
	else
		echo "Discovered $device_name at $ip"
		echo "Connecting via SSH.."
		echo ""
		ssh $ip -l pi
	fi
}
pi_scan 0 $mask_inc