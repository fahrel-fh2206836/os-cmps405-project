#!/bin/bash

#Creating the directory if it doesnt exist
mkdir -p PingDirectory


ping_client() {

	local client_name=$1

	#Every timestamps
	timeStamp=$(date "+%Y-%M-%d_%H:%M:%S")

	outputFile="PingDirectory/TimeStamp_$timeStamp.txt"

	#Create the timestamp file
	touch "$outputFile"

	#Modify permissions to read and write for owner only
	chmod 600 "$outputFile"

	#Replace google.com with target VM IP address
	ping "$client_name" -s 500 -c 10 >> "$outputFile"

}

while true
do
	#ClientVM1
	ping_client "google.com"

	#ClientVM2
	ping_client "bing.com"

	#Every 10 seconds interval
	sleep 10 
done


#Note: This should run in a seperate dedicated terminal. To stop it, Press Ctrl + Z





