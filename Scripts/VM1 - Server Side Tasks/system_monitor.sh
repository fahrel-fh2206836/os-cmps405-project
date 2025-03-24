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

##For the script to run every hour
#sudo crontab -e
#0 * * * * /path/to/system_monitor.sh

##Create service for script to run on startup
#sudo nano /etc/systemd/system/system_monitor.service
#[Unit]
#Description=System Monitoring Script
#After=network.target

#[Service]
#ExecStart=/path/to/system_monitor.sh
#Restart=always
#User=root

#[Install]
#WantedBy=multi-user.target

#sudo systemctl daemon-reload
#sudo systemctl enable system_monitor.service
#sudo systemctl start system_monitor.service
