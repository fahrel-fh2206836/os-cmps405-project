#!/bin/bash

#Note: This should run in a seperate dedicated terminal. To stop it, Press Ctrl + Z

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

	echo -e "\n\033[1;34mPinging $client_name at $(date +"%Y-%m-%d %H:%M:%S")...\033[0m"

	#Replace google.com with target VM IP address
	ping "$client_name" -s 500 -c 10 >> "$outputFile"

	echo -e "\033[1;32mPing results for $client_name saved to $outputFile\033[0m"

}

while true
do
	#ClientVM2
	ping_client "google.com"

	#ClientVM3 
	ping_client "bing.com"

	#Every 10 seconds interval
	echo -e "\n\033[1;33mWaiting for 10 seconds before the next ping cycle...\033[0m"
	sleep 10 
done

