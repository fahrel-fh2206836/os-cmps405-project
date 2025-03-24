# Define log directory and timestamp
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
LOG_FILE="/var/operations/monitoring/metrics_$TIMESTAMP.log"

# Create Log File and Grant Permissions
sudo touch "$LOG_FILE"
sudo chmod 666 "$LOG_FILE"

# Capture system metrics
echo "System Metrics: $TIMESTAMP" > "$LOG_FILE"
echo "\nCPU Usage:" >> "$LOG_FILE"
top -bn1 | grep "Cpu(s)" >> "$LOG_FILE"

echo -e "\nMemory Usage:" >> "$LOG_FILE"
free -h | head -n 2 >> "$LOG_FILE"

echo -e "\nDisk I/O Stats:" >> "$LOG_FILE"
vmstat -d 1 3 >> "$LOG_FILE"

echo -e "\nTop 5 Resource-Heavy Processes:" >> "$LOG_FILE"
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -n 6 >> "$LOG_FILE"

# Check Service Status
echo -e "\nService Status" >> "$LOG_FILE"

for service in mysql ssh; do
    systemctl is-active --quiet "$service"
    
    if [ $? -ne 0 ]; then
        echo "$service is down." >> "$LOG_FILE"
        sudo systemctl restart "$service"
        echo "$service has been restarted." >> "$LOG_FILE"
    else
        echo "$service is running." >> "$LOG_FILE"
    fi
done

# For the script to run hourly
# sudo crontab -e
# 0 * * * * /path/to/system_monitor.sh

# Run the script on startup
#sudo nano /etc/systemd/system/system_monitor.service
#[Unit]
#Description=System Monitoring Service
#After=network.target

#[Service]
#ExecStart=/bin/bash path/to/system_monitor.sh
#Type=oneshot
#User=root

#[Install]
#WantedBy=multi-user.target

