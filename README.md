# FP-TKA-C-6

## Laporan Final Project Teknologi Komputasi Awan 2024 

### Anggota Kelompok :
 | Nama      | NRP         |
  |-----------|-------------|
  | Danendra Fidel Khansa   | 5027231063  |
  | Tio Axellino Irin  | 5027231065  |  
  | Abid Ubaidillah Adam  | 5027231089  |
  | Muhammad Nafi Firdaus | 5027231045  |  
  | Gallant Damas Hayuaji  | 5027231037  |
  
# PROBLEM
Anda adalah seorang lulusan Teknologi Informasi, sebagai ahli IT, salah satu kemampuan yang harus dimiliki adalah Keampuan merancang, membangun, mengelola aplikasi berbasis komputer menggunakan layanan awan untuk memenuhi kebutuhan organisasi.

Pada suatu saat anda mendapatkan project untuk mendeploy sebuah aplikasi [Sentiment Analysis](https://github.com/fuaddary/fp-tka/blob/main/Resources/BE/sentiment-analysis.py) dengan komponen Backend menggunakan python: sentiment-analysis.py dengan spesifikasi sebagai berikut

### Endpoints:
1. Analyze Text
   - Endpoint: `POST /analyze`
   - Description: This endpoint accepts a text input and returns the sentiment score of the text.
   - Request:
```
{
   "text": "Your text here"
}
```
2. Retrieve History
   - Endpoint: `GET /history`
   - Description: This endpoint retrieves the history of previously analyzed texts along with their sentiment scores.
   - Response:
```
{
 {
   "text": "Your previous text here",
   "sentiment": <sentiment_score>
 },
 ...
}
```
Kemudian juga disediakan sebuah Frontend sederhana menggunakan [index.html](https://github.com/fuaddary/fp-tka/blob/main/Resources/FE/index.html) dan [styles.css](https://github.com/fuaddary/fp-tka/blob/main/Resources/FE/styles.css) dengan tampilan antarmuka sebagai berikut

![image](https://github.com/danendrafidel/FP-TKA/assets/150430084/0941d66e-71af-48b9-a10a-1c7fedb2a546)

Kemudian anda diminta untuk mendesain arsitektur cloud yang sesuai dengan kebutuhan aplikasi tersebut. Apabila dana maksimal yang diberikan adalah 1 juta rupiah per bulan (65 US$) konfigurasi cloud terbaik seperti apa yang bisa dibuat?


## A. Rancangan Arsitektur Komputasi Awan
Kelompok kami memutuskan untuk memakai rancangan yang disama ratakan keseluruhan dari spesifikasi VM, alasannya adalah kami menginginkan rancangan cloud yang berspesifikasi medium saja dan tidak terlalu mahal selain itu untuk karena cakupan Final Project ini hanya boleh menggunakan dana dengan maksimal total $60 harganya untuk itu kami ingin menganalisis apakah rancangan cloud kami dengan spesifikasi dibawah cukup efektif.
![Cloud drawio](https://github.com/danendrafidel/FP-TKA/assets/150430084/b110221e-1ec8-4af2-a6d1-2f514f59a844)

Spesifikasi yang digunakan adalah sebagai berikut :

| No | Nama              | Spesifikasi          | Fungsi         | Harga/Bulan |
|----|-------------------|----------------------|----------------|-------------|
| 1  | VM3-LoadBalancer  | Regular 1vCPU        | Load Balancer  | $12         |
|    |                   | 2GB Memory           |                |             |
| 2  | VM2-Worker        | Regular 1vCPU        | App Worker 1   | $12         |
|    |                   | 2GB Memory           |                |             |
| 3  | VM2-Worker1       | Regular 1vCPU        | App Worker 2   | $12         |
|    |                   | 2GB Memory           |                |             |
| 4  | VM3-Database      | Regular 1vCPU        | Database Server| $0          |
|    |                   | 2GB Memory           |                |             |
|    | **TOTAL**         |                      |                | **$48**     |

Disini kami memakai 2 provider untuk membuat rancangan cloud ini yaitu `Digital Ocean dan Proxmox`, alasannya karena terdapat limitasi dalam pembuatan droplet pada digital ocean sebanyak 3 droplet saja yang sudah terpakai untuk load balancer dan 2 worker pada [digital ocean](https://www.digitalocean.com/), lalu untuk droplet database kami letakkan di provider [proxmox](https://www.proxmox.com/en/).

## B. Implementasi Rancangan Arsitektur Komputasi Awan
Uji coba pada rancangan cloud kami memerlukan beberapa setup yang perlu diinstal dalam vm yang dibutuhkan maka dari itu berikut beberapa pengimplementasiannya : 
1. Setup Database
```sh
#!/bin/bash

echo "Installing docker..."
sudo apt update
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
sudo apt install docker-ce -y
# sudo systemctl status docker
echo "Installing docker done!!"

echo "version: '3'

services:
  mongodb:
    image: mongo
    command: mongod --bind_ip_all
    ports:
      - \"27017:27017\"
    environment:
      - MONGO_INITDB_ROOT_USERNAME=admin
      - MONGO_INITDB_ROOT_PASSWORD=admin
    volumes:
      - mongodb_data:/data/db
  mongo-express:
    image: mongo-express
    ports:
      - \"8082:8081\"
    environment:
      - ME_CONFIG_MONGODB_ADMINUSERNAME=admin
      - ME_CONFIG_MONGODB_ADMINPASSWORD=admin
      - ME_CONFIG_MONGODB_SERVER=mongodb
      - ME_CONFIG_MONGODB_ENABLE_ADMIN=true
      - ME_CONFIG_BASICAUTH_USERNAME=admin
      - ME_CONFIG_BASICAUTH_PASSWORD=admin
    depends_on:
      - mongodb
volumes:
  mongodb_data:
    driver: local" >docker-compose.yml

sudo docker compose up -d
sudo docker ps -a
```
2. Setup Worker
```sh
#!/bin/bash

echo "Installing docker..."
sudo apt update
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
sudo apt install docker-ce -y
# sudo systemctl status docker
echo "Installing docker done!!"

echo "Installing python..."
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt update
sudo apt install python3.8 -y
echo "Installing python done!!"

echo "Installing pip..."
sudo apt install python3-pip -y
pip3 install fastapi==0.78.0 uvicorn==0.18.2 pymongo pydantic uuid Flask Flask-PyMongo

echo "fastapi==0.78.0
uvicorn==0.18.2
pymongo
pydantic
uuid
Flask
Flask-PyMongo
gunicorn" >requirements.txt

echo "Configure docker file..."
echo "FROM python:3.9-slim" >Dockerfile
echo "WORKDIR /app" >>Dockerfile
echo "COPY . /app" >>Dockerfile
echo "RUN pip install -r requirements.txt" >>Dockerfile
echo 'CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:8000", "main:app"]' >>Dockerfile

echo "GO GO GO!!!!"
sudo docker build -t fp-app -f Dockerfile .
sudo docker run -p 8000:8000 -d fp-app
```
3. Setup Load Balancer
```sh
#!/bin/bash

sudo apt update

echo "Installing nginx..."
sudo apt install nginx

sudo mkdir /var/cache/nginx
sudo mkdir /var/cache/nginx2
sudo chown www-data:www-data /var/cache/nginx
sudo chown www-data:www-data /var/cache/nginx2

# Konten konfigurasi Nginx
echo "proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=cache1:10m inactive=60m;

upstream app {
    server 172.208.23.151:8000;
    server 172.208.82.223:8000;
}

server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://app;
        proxy_cache cache1;
        proxy_cache_valid any 10m;
    }
}
" | sudo tee /etc/nginx/sites-available/my_proxy

echo "proxy_cache_path /var/cache/nginx2 levels=1:2 keys_zone=cache2:10m inactive=60m;

upstream app2 {
    server 172.171.251.101:8000;
    server 172.171.253.255:8000;
    server 40.76.121.74:8000;
}

server {
    listen 8000;
    server_name _;

    location / {
        proxy_pass http://app2;
        proxy_cache cache2;
        proxy_cache_valid any 10m;
    }
}
" | sudo tee /etc/nginx/sites-available/my_proxy_2

# Membuat tautan simbolik ke sites-enabled
sudo ln -s /etc/nginx/sites-available/my_proxy "/etc/nginx/sites-enabled/"
sudo ln -s /etc/nginx/sites-available/my_proxy_2 "/etc/nginx/sites-enabled/"

sudo rm /etc/nginx/sites-enabled/default

# Melakukan uji sintaks konfigurasi Nginx
sudo nginx -t

# Merestart Nginx untuk menerapkan konfigurasi baru
sudo systemctl restart nginx

sudo ufw status
sudo ufw enable
sudo ufw allow 80
sudo ufw allow 8000
```

## C. Hasil Pengujian Endpoint
Disini kami menggunakan software Postman untuk pengujian endpoint dari rancangan cloud diatas untuk menguji `POST` dan `GET`


## D. Hasil Pengujian Loadtesting
Disini kami menggunakan LOCUST untuk pengujiannya

## E. Kesimpulan dan Saran
