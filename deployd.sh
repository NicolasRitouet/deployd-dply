#!/usr/bin/env bash
# Script to install and setup Deployd. Copyright (c) 2016, Nicolas Ritouet

#
# Path to our deployd app
#
DEPLOYD_PATH=/var/www/deployd

#
# Nginx Config file for Deployd
#
NGINX_CONFIG=$(cat <<EOF 
server {

    listen 80;
    server_name example.com;

    # Needed to securely proxy Websocket requests
    # ==================================================

    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_cache_bypass \$http_upgrade;
    proxy_http_version 1.1;

    # Handle API EndPoints
    # ==================================================

    location / {
        access_log /var/log/nginx/access.log;
        add_header Access-Control-Allow-Origin *;
        proxy_pass http://localhost:3000;
        proxy_redirect off;
    }

    # Handle the Dashboard
    # ==================================================

    location ~ ^/(dashboard) {
        access_log /var/log/nginx/dashboard_access.log;
        add_header Access-Control-Allow-Origin *;
        proxy_pass http://localhost:3000;
        proxy_redirect off;
    }
}
EOF
)

#
# Systemd unit file for MongoDB
#
MONGO_UNIT=$(cat <<EOF
[Unit]
Description=High-performance, schema-free document-oriented database
After=network.target

[Service]
User=mongodb
ExecStart=/usr/bin/mongod --quiet --config /etc/mongod.conf

[Install]
WantedBy=multi-user.target
EOF
)

#
# Systemd unit file for our deployd app
#
DEPLOYD_UNIT=$(cat <<EOF
[Unit]
Description=My Nodejs Deployd app
After=network.target
Wants=mongodb.service

[Service]
ExecStartPre=/usr/bin/npm install
ExecStart=/usr/bin/node index
WorkingDirectory=/var/www/deployd
Restart=always
User=root
Environment=NODE_ENV=dev

[Install]
WantedBy=multi-user.target
EOF
)

#############################
#
# Start the setup
#
#############################
#
# Install utilities
#
apt-get install -y ufw

#
# Install nginx
#
apt-get install -y nginx

#
# Setup nginx
#
ufw allow 'Nginx HTTP'
echo "${NGINX_CONFIG}" > /etc/nginx/sites-available/default
service nginx restart

#
# Install Nodejs
#
curl -sL https://deb.nodesource.com/setup_6.x | bash -
apt-get install -y nodejs

#
# Install MongoDB
#
apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10
echo "deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen" | tee -a /etc/apt/sources.list.d/10gen.list
apt-get -y update
apt-get install -y mongodb-org

#
# Setup MongoDB Unit File
#
echo "${MONGO_UNIT}" > /etc/systemd/system/mongodb.service
systemctl enable mongodb

#
# Install Deployd app
#
apt-get install -y git
git clone https://github.com/NicolasRitouet/deployd-dply.git ${DEPLOYD_PATH}

#
# Setup Deployd Unit File
#
echo "${DEPLOYD_UNIT}" > /etc/systemd/system/deployd.service
systemctl daemon-reload
systemctl enable deployd
systemctl start deployd

#
# Add some data
#
# Wait for server to respond
wget --retry-connrefused --no-check-certificate -T 60  http://localhost:3000 -O /dev/null
curl -H "Content-Type: application/json" -X POST -d '{"lastname":"Lindbergh","firstname":"Charles"}' http://localhost:3000/contacts
