##Installation of MySQL
sudo apt update;
sudo apt install mysql-server;
sudo systemctl start myql;
sudo mysql_secure_installation;

##Obtain IP address of Server
SERVER_IP=$(ip -4 addr show | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | grep -v '127.0.0.1' | head -n 1);

##Creation of Users and Databases
##Assigning Privileges
sudo mysql -u root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'root_pass_123';
FLUSH PRIVILEGES;

CREATE USER IF NOT EXISTS 'dev_lead1'@'%' IDENTIFIED BY 'dev123';
CREATE USER IF NOT EXISTS 'ops_lead1'@'%' IDENTIFIED BY 'ops123';

CREATE DATABASE IF NOT EXISTS development_db;
CREATE DATABASE IF NOT EXISTS operations_db;

GRANT SELECT, INSERT, UPDATE, DELETE, CREATE VIEW, SHOW VIEW ON development_db TO 'dev_lead1'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE VIEW, SHOW VIEW ON operations_db TO 'ops_lead1'@'%';

FLUSH PRIVILEGES;
EOF

#Verify User Creation
mysql -u root -p 'root_pass_123' -e "SELECT User FROM mysql.user;"

## dev_lead1 Authentication and Verification | Database and Table Exploration
sudo mysql -u dev_lead1 -p'dev123' -h $SERVER_IP <<EOF
SELECT USER(), CURRENT_USER();
SHOW SESSION STATUS;
SHOW DATABASES;

-- Loop through each accessible database and show tables
SHOW TABLES IN development_db;
SHOW TABLES IN operations_db;
EOF

## dev_lead1 Authentication and Verification | Database and Table Exploration
sudo mysql -u ops_lead1 -p'ops123' -h $SERVER_IP <<EOF
SELECT USER(), CURRENT_USER();
SHOW SESSION STATUS;
SHOW DATABASES;

-- Loop through each accessible database and show tables
SHOW TABLES IN development_db;
SHOW TABLES IN operations_db;
EOF


## dev_lead1 Database and Table Exploration
sudo mysql -u dev_lead1 -p 'dev123' -h '$SERVER_IP' -e "SHOW DATABASES;"

#Show databases of each user
sudo mysql -u dev_lead1 -p 'dev123' -h '$SERVER_IP' -e "SHOW DATABASES;"
sudo mysql -u ops_lead1 -p 'ops123' -h '$SERVER_IP' -e "SHOW DATABASES;"

#Show databases of each user
sudo mysql -u dev_lead1 -p 'dev123' -h '$SERVER_IP' -e "SHOW DATABASES;"
sudo mysql -u ops_lead1 -p 'ops123' -h '$SERVER_IP' -e "SHOW DATABASES;"

#Logging
sudo sed -i '/\[mysqld\]/a general_log = 1\ngeneral_log_file = /var/log/mysql/general.log' "$MYSQL_CONFIG"
sudo systemctl restart mysql;

tail -f "/var/log/mysql/general.log" | while read line; do
	#Logins
    if [[ "$line" == *"Connect"* ]]; then
        echo "$(date) - LOGIN: $line" >> "/var/log/mysql/mysql_monitor.log"
    fi

   	#Queries
    if [[ "$line" == *"Query:"* ]]; then
        echo "$(date) - QUERY: $line" >> "/var/log/mysql/mysql_monitor.log"
    fi
done

# sudo bash -c "cat > /etc/systemd/system/mysql_log.service" << EOF
# [Unit]
# Description=MySQL Log Monitoring Service
# After=network.target

# [Service]
# ExecStart=/bin/bash /path/to/your/script/MySQL_login_user_name.sh
# Restart=always
# User=root

# [Install]
# WantedBy=multi-user.target
# EOF

# sudo systemctl daemon-reload;

# sudo systemctl enable mysql_log.service;
# sudo systemctl start mysql_log.service;
