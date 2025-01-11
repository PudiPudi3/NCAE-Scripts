#!/bin/bash

# Variables
FTP_FILE="/srv/ftp/iloveftp.txt"
FTP_CONTENT="iloveftp"

# Check if vsftpd is installed
if ! command -v vsftpd &>/dev/null; then
  echo "vsftpd is not installed. Installing vsftpd..."
  apt update && apt install -y vsftpd
fi

# Configure vsftpd for anonymous access
VSFTPD_CONF="/etc/vsftpd.conf"

if [ ! -f "$VSFTPD_CONF.bak" ]; then
  echo "Backing up original vsftpd configuration..."
  cp "$VSFTPD_CONF" "$VSFTPD_CONF.bak"
fi

cat <<EOF >$VSFTPD_CONF
anonymous_enable=YES
local_enable=NO
write_enable=NO
anon_upload_enable=NO
anon_mkdir_write_enable=NO
dirmessage_enable=YES
use_localtime=YES
listen=YES
listen_ipv6=NO
anon_root=/srv/ftp
no_anon_password=YES
EOF

# Ensure FTP root directory exists
if [ ! -d "/srv/ftp" ]; then
  echo "Creating FTP root directory..."
  mkdir -p /srv/ftp
fi

# Create the file with the expected content
if [ ! -f "$FTP_FILE" ]; then
  echo "Creating iloveftp.txt with the required content..."
  echo "$FTP_CONTENT" > "$FTP_FILE"
  chmod 644 "$FTP_FILE"
fi

# Restart vsftpd service
echo "Restarting vsftpd service..."
systemctl restart vsftpd

# Verify the setup
if curl -s ftp://localhost/iloveftp.txt | grep -q "$FTP_CONTENT"; then
  echo "FTP setup successfully! Anonymous access to iloveftp.txt is working."
else
  echo "FTP setup failed. Please check the configuration."
fi
