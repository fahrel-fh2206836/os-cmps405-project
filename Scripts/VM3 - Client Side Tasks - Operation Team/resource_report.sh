#!/bin/bash

report="./resource_report_$(date "+%Y-%m-%d_%H-%M-%S").txt"
reportDir="/var/operations/report"
userVM1="admin"                       # Change to actual user
ipVM1="192.168.1.100"                 # Change to actual IP
remotePath="$userVM1@$ipVM1:$reportDir"

# 1. Create Report
{
    echo "======= Resource Report $(date "+%Y-%m-%d Time: %H-%M-%S") ======="
    echo
    echo "--Process Tree--"
    pstree

    echo
    echo "--Zombie Processes--"
    lines=$(ps aux | awk '$8=="Z"' | wc -l) 
    if [[ "$lines" -eq 0 ]]
    then
    	echo "No Zombie Processes"
    else
    	ps aux | awk '$8=="Z"'
    fi
    
    echo
    echo "--CPU and Memory Usage--"
    top -b -n 1 | grep -E "Tasks|Cpu|Mem|Swap"

    echo
    echo "--Top 5 Resource-Consuming Processes (%CPU AND %MEM)--"
    ps -eo pid,comm,%cpu,%mem | awk 'NR==1 {print $0, "TOTAL"; next} {total = $3 + $4; print $0, total}' | (head -n 1 && tail -n +2 | sort -k5 -nr | head -n 5)
} > "$report"

# 2. Securely copy the report to VM1
scp "$report" "$remotePath"

# 3. Delete local report
rm "$report"

## Automate hourly using crontab
## crontab -e

## On crontab Set 0 * * * * /resource_report.sh (Depending on where resource_report.sh is saved)