#!/bin/bash

# Variables
DB_USER="scoring-sql"
DB_PASSWORD="password"
DB_NAME="cyberforce"
TABLE_NAME="supersecret"
DATA_COLUMN="data"
EXPECTED_VALUE=7

# Check if MySQL/MariaDB is installed
if ! command -v mysql &>/dev/null; then
  echo "MySQL/MariaDB is not installed. Installing MariaDB..."
  apt update && apt install -y mariadb-server
fi

# Start and enable the MySQL service
systemctl start mariadb
systemctl enable mariadb

# Secure the installation (non-interactive)
echo "Securing MariaDB installation..."
mysql_secure_installation <<EOF

Y
password
password
Y
Y
Y
Y
EOF

# Configure the database and user
echo "Setting up database and user..."
mysql -u root -ppassword <<SQL
CREATE DATABASE IF NOT EXISTS $DB_NAME;
CREATE USER IF NOT EXISTS '$DB_USER'@'%' IDENTIFIED BY '$DB_PASSWORD';
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'%';
FLUSH PRIVILEGES;
USE $DB_NAME;
CREATE TABLE IF NOT EXISTS $TABLE_NAME (
    id INT AUTO_INCREMENT PRIMARY KEY,
    $DATA_COLUMN INT NOT NULL
);
INSERT INTO $TABLE_NAME ($DATA_COLUMN) VALUES ($EXPECTED_VALUE)
ON DUPLICATE KEY UPDATE $DATA_COLUMN=$EXPECTED_VALUE;
SQL

# Update MariaDB to allow external connections
echo "Configuring MariaDB for external connections..."
CONFIG_FILE="/etc/mysql/mariadb.conf.d/50-server.cnf"
sed -i 's/^bind-address.*/bind-address = 0.0.0.0/' $CONFIG_FILE

# Restart MariaDB to apply changes
echo "Restarting MariaDB service..."
systemctl restart mariadb

# Verify the setup
echo "Verifying database setup..."
RESULT=$(mysql -u $DB_USER -p$DB_PASSWORD -D $DB_NAME -se "SELECT $DATA_COLUMN FROM $TABLE_NAME LIMIT 1;")
if [ "$RESULT" -eq "$EXPECTED_VALUE" ]; then
  echo "MySQL/MariaDB setup successfully! The Scoring Engine should be able to retrieve the value $EXPECTED_VALUE."
else
  echo "MySQL/MariaDB setup failed. Please check the configuration."
fi