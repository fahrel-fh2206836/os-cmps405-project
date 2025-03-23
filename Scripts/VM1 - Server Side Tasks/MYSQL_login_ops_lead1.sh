## Before Script: MySQL Setup

# Installation of MySQL
# sudo apt update;
# sudo apt install mysql-server;
# sudo systemctl start mysql;
# sudo mysql_secure_installation;

#sudo mysql -u root
#In MySQL:
#ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'root_pass_123'; Can change 'root_pass_123' to any password
#FLUSH PRIVILEGES;

#sudo systemctl restartmysql;

## MySQL Firewall Configuration
# sudo ufw allow 3306/tcp;
# sudo ufw reload;

## Configure MySQL to Accept Remote Connections
# Modify MySQL configuration to allow remote connections by setting bind-address to 0.0.0.0
# sudo sed -i 's/^bind-address\s*=.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf;
# sudo systemctl restart mysql;

## Enable General Query Log for Monitoring
# sudo touch "/var/log/mysql/general.log";
# sudo chmod 666 "/var/log/mysql/general.log";
# sudo touch "/var/log/mysql/mysql_monitor.log";
# sudo chmod 666 "/var/log/mysql/mysql_monitor.log";

# sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
#[mysqld]
#general_log = 1
#general_log_file = /var/log/mysql/general.log

# Restart MySQL to apply logging configuration
# sudo systemctl restart mysql;

##Creating systemd service for automation
# sudo nano /etc/systemd/system/mysql_log_ops_lead1.service
# [Unit]
# Description=MySQL Log Monitoring Service
# After=network.target

# [Service]
# ExecStart=/bin/bash /path/to/your/script/MySQL_login_ops_lead1.sh
# Restart=always
# User=root

# [Install]
# WantedBy=multi-user.target
# 

##Reload Systemd for new service
# sudo systemctl daemon-reload;

#Enable and Start Service on Boot;
# sudo systemctl enable mysql_log.service;
# sudo systemctl start mysql_log.service;

##Obtain IP address of Server
SERVER_IP=$(hostname -I | awk '{print $1}')

##Creation of Users and Databases
##Assigning Privileges
sudo mysql -u root -p<<EOF

CREATE USER IF NOT EXISTS 'ops_lead1'@'%' IDENTIFIED BY 'ops123';

CREATE DATABASE IF NOT EXISTS operations_db;

GRANT ALL PRIVILEGES ON operations.* TO 'ops_lead1'@'%';

FLUSH PRIVILEGES;
EOF

#Verify User Creation
mysql -u root -p -e "SELECT User FROM mysql.user;"

## ops_lead1 Authentication and Verification | Database and Table Exploration
sudo mysql -u ops_lead1 -p -h $SERVER_IP <<EOF
SELECT USER(), CURRENT_USER();
SHOW SESSION STATUS;
SHOW DATABASES;

-- Loop through each accessible database and show tables
SHOW TABLES IN operations_db;
EOF

#Logging
tail -f "/var/log/mysql/general.log" | while read line; do
	#Logins
    if [[ "$line" == *"Connect"* && "$line" == *"ops_lead1"* ]]; then
        echo "$(date) LOGIN: $line" >> "/var/log/mysql/mysql_monitor.log"
    fi

   	#Queries
    if [[ "$line" == *"Query"* ]]; then
        echo "$(date) QUERY: $line" >> "/var/log/mysql/mysql_monitor.log"
    fi
done	