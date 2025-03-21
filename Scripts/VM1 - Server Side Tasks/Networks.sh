#!/bin/bash

#Creating the directory if it doesnt exist
mkdir -p PingDirectory

a=0

#should modify to an infinte loop when execution
while [ "$a" -le 3 ]
do
	#Every timestamps
	timeStamp=$(date "+%Y-%M-%d_%H:%M:%S")

	outputFile="PingDirectory/TimeStamp_$timeStamp.txt"

	#Create the timestamp file
	touch "$outputFile"

	#Modify permissions to read and write for owner only
	chmod 600 "$outputFile"

	#Replace google.com with target VM IP address
	ping google.com -s 500 -c 10 >> "$outputFile"

	a=$((a + 1))

	sleep 10
done

