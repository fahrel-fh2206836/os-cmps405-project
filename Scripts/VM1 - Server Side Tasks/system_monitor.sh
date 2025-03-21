# Define log directory and timestamp
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
LOG_FILE="/var/operations/monitoring/metrics_$TIMESTAMP.log"

# Capture system metrics
echo "System Metrics: $TIMESTAMP" > "$LOG_FILE"
echo "\nCPU Usage:" >> "$LOG_FILE"
top -bn1 | grep "Cpu(s)" >> "$LOG_FILE"

echo -e "\nMemory Usage:" >> "$LOG_FILE"
free -h | head -n 2 >> "$LOG_FILE"

echo -e "\nDisk I/O Stats:" >> "$LOG_FILE"
vmstat -d 1 >> "$LOG_FILE"

echo -e "\nTop 5 Resource-Heavy Processes:" >> "$LOG_FILE"
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -n 6 >> "$LOG_FILE"

# Check Service Status
echo -e "\nService Status" >> "$LOG_FILE"

for service in mysql ssh; do
    systemctl is-active --quiet "$service"
    if [ $? -ne 0 ]; then
        echo "$service is down." >> "$LOG_FILE"
    else
        echo "$service is running." >> "$LOG_FILE"
    fi
done
