#!/bin/bash

# Update package list and install nginx, git, and python3-venv
sudo apt update
sudo apt install -y nginx git python3-venv

# Set ulimit
ulimit -n 100000

# Clone the repository
git clone https://github.com/fuaddary/fp-tka.git

# Remove the default nginx configuration
sudo unlink /etc/nginx/sites-available/default

# Create a new nginx configuration file for the application
cat <<EOL | sudo tee /etc/nginx/sites-available/app
upstream backend_servers {
    # VM1
    server 68.183.231.98:5000;
    # VM2
    server 165.22.241.204:5000;
}

server {
    listen 80;
    server_name 159.223.64.29;  # Ganti dengan IP LB

    location / {
        # Aktifkan penggunaan cache
        proxy_cache my_cache;
        proxy_cache_valid 200 302 10m;
        proxy_cache_valid 404 1m;

        # Konfigurasi caching tambahan
        proxy_cache_use_stale error timeout updating http_500 http_502 http_503 http_504;
        proxy_cache_lock on;
        proxy_cache_lock_timeout 5s;

        # Pengaturan proxy_pass dan header lainnya
        proxy_pass http://backend_servers;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;

        # Header tambahan untuk mengidentifikasi status cache
        add_header X-Cached \$upstream_cache_status;
    }
}
EOL

# Enable the new configuration
sudo ln -s /etc/nginx/sites-available/app /etc/nginx/sites-enabled

# Modify the nginx.conf file
cat <<EOL | sudo tee /etc/nginx/nginx.conf
user www-data;
worker_processes 2;
error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;
worker_rlimit_nofile 100000;

events {
    worker_connections 4096;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    log_format main '\$remote_addr - \$remote_user [\$time_local] '
                    '"\$request" \$status \$body_bytes_sent '
                    '"\$http_referer" "\$http_user_agent" '
                    '"\$http_x_forwarded_for"';

    access_log /var/log/nginx/access.log main;

    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;

    # Konfigurasi cache
    proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=my_cache:10m max_size=10g inactive=60m;
    proxy_temp_path /var/cache/nginx/temp;
    proxy_cache_use_stale error timeout updating http_500 http_502 http_503 http_504;
    proxy_cache_lock on;
    proxy_cache_lock_timeout 5s;

    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-enabled/*;
}
EOL

# Restart nginx to apply changes
sudo systemctl restart nginx

# Change directory to the test folder
cd fp-tka/Resources/Test

# Run locustfile.py with locust using python virtual environment
python3 -m venv venv
source venv/bin/activate
pip install locust
locust -f locustfile.py
