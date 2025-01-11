#!/bin/bash

# Variables
WEB_ROOT="/var/www/html"
INDEX_FILE="$WEB_ROOT/index.html"
EXPECTED_CONTENT="Hello World!"

# Check if a web server is installed (nginx, apache2, or httpd)
if command -v nginx &>/dev/null; then
  WEB_SERVER="nginx"
elif command -v apache2 &>/dev/null; then
  WEB_SERVER="apache2"
elif command -v httpd &>/dev/null; then
  WEB_SERVER="httpd"
else
  echo "No web server found. Installing Apache2..."
  apt update && apt install -y apache2
  WEB_SERVER="apache2"
fi

# Start and enable the web server
if [ "$WEB_SERVER" = "nginx" ]; then
  systemctl start nginx
  systemctl enable nginx
elif [ "$WEB_SERVER" = "apache2" ]; then
  systemctl start apache2
  systemctl enable apache2
elif [ "$WEB_SERVER" = "httpd" ]; then
  systemctl start httpd
  systemctl enable httpd
fi

# Create the index page with the expected content
echo "Creating index page..."
echo "$EXPECTED_CONTENT" > "$INDEX_FILE"
chmod 644 "$INDEX_FILE"

# Restart the web server to ensure changes take effect
if [ "$WEB_SERVER" = "nginx" ]; then
  systemctl restart nginx
elif [ "$WEB_SERVER" = "apache2" ]; then
  systemctl restart apache2
elif [ "$WEB_SERVER" = "httpd" ]; then
  systemctl restart httpd
fi

