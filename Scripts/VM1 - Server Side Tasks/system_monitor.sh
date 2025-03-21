#!/bin/bash

# Define log directory and timestamp
LOG_DIR="/var/operations/monitoring"
mkdir -p "$LOG_DIR"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
LOG_FILE="$LOG_DIR/metrics_$TIMESTAMP.log"

# Capture system metrics
echo "===== System Metrics: $TIMESTAMP =====" > "$LOG_FILE"
echo "CPU Usage:" >> "$LOG_FILE"
top -bn1 | grep "Cpu(s)" >> "$LOG_FILE"

echo -e "\nMemory Usage:" >> "$LOG_FILE"
free -h >> "$LOG_FILE"

echo -e "\nDisk Usage:" >> "$LOG_FILE"
df -h >> "$LOG_FILE"

echo -e "\nDisk I/O Stats:" >> "$LOG_FILE"
iostat -x 1 3 >> "$LOG_FILE"

echo -e "\nTop 5 Resource-Heavy Processes:" >> "$LOG_FILE"
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -6 >> "$LOG_FILE"

# Check Service Status
echo -e "\n===== Service Status =====" >> "$LOG_FILE"

for service in mysql ssh; do
    systemctl is-active --quiet "$service"
    if [ $? -ne 0 ]; then
        echo "$service is DOWN! Restarting..." >> "$LOG_FILE"
        systemctl restart "$service"
        echo "$service restarted successfully." >> "$LOG_FILE"
    else
        echo "$service is running." >> "$LOG_FILE"
    fi
done

# Display log file location
echo "Metrics logged at: $LOG_FILE"
