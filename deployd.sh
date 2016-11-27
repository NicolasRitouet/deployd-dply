#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive;
DEPLOYD_PATH=/var/www/deployd

# Wait for dpkg to be available and install packages silently
install() {
  i=0
  tput sc
  while fuser /var/lib/dpkg/lock >/dev/null 2>&1 ; do
      case $(($i % 4)) in
          0 ) j="-" ;;
          1 ) j="\\" ;;
          2 ) j="|" ;;
          3 ) j="/" ;;
      esac
      tput rc
      echo -en "\r[$j] Waiting for other software managers to finish..." 
      sleep 0.5
      ((i=i+1))
  done
  /usr/bin/apt-get install -y "$1"
}

# Install utilities
install ufw

# Install nginx
install nginx

# Setup nginx
ufw allow 'Nginx HTTP'
cat <<EOF
server {
    listen 80;

    server_name example.com;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_cache_bypass $http_upgrade;

    location / {
        access_log /var/log/nginx/access.log;
        add_header Access-Control-Allow-Origin *;
        proxy_pass http://localhost:3000;
        proxy_redirect off;
    }
    location ~ ^/(dashboard) {
        access_log /var/log/nginx/dashboard_access.log;
        add_header Access-Control-Allow-Origin *;
        proxy_pass http://localhost:3000;
        proxy_redirect off;
    }
}
EOF
) >  /etc/nginx//sites-available/default
service nginx restart

# Install Nodejs
curl -sL https://deb.nodesource.com/setup_6.x | bash -
install nodejs

# Install MongoDB
apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10
echo "deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen" | tee -a /etc/apt/sources.list.d/10gen.list
apt-get -y update
install mongodb-10gen

# Install Deployd app
install git
git clone https://github.com/NicolasRitouet/deployd-dply.git ${DEPLOYD_PATH}

# Start the app
cd ${DEPLOYD_PATH}
npm install
NODE_ENV=dev npm start
