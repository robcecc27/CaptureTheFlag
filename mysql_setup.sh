#!/bin/bash

# Update packages
sudo yum update -y

# Install MySQL server
sudo amazon-linux-extras install -y mysql8.0

# Start MySQL service
sudo systemctl start mysqld

# Enable MySQL service on boot
sudo systemctl enable mysqld

# Set MySQL root password
MYSQL_ROOT_PASSWORD="RootP@ssWord"
sudo mysqladmin password $MYSQL_ROOT_PASSWORD

# Create a new admin user
MYSQL_ADMIN_USER="admin-user"
MYSQL_ADMIN_PASSWORD="P@ssWord"
mysql --user=root --password=$MYSQL_ROOT_PASSWORD --execute="CREATE USER '$MYSQL_ADMIN_USER'@'%' IDENTIFIED BY '$MYSQL_ADMIN_PASSWORD';"

# Grant admin privileges to the new user
mysql --user=root --password=$MYSQL_ROOT_PASSWORD --execute="GRANT ALL PRIVILEGES ON *.* TO '$MYSQL_ADMIN_USER'@'%' WITH GRANT OPTION;"

# Create a new database
MYSQL_DATABASE_NAME="CaptureTheFlag"
mysql --user=root --password=$MYSQL_ROOT_PASSWORD --execute="CREATE DATABASE $MYSQL_DATABASE_NAME;"

# Allow remote connections
sudo sed -i 's/bind-address = 127.0.0.1/bind-address = 0.0.0.0/' /etc/my.cnf
sudo systemctl restart mysqld
