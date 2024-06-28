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

# Endpoints:
1. Analyze Text
   - Endpoint: `POST /analyze`
   - Description: This endpoint accepts a text input and returns the sentiment score of the text.
   - Request:
```json
{
   "text": "Your text here"
}
```
2. Retrieve History
   - Endpoint: `GET /history`
   - Description: This endpoint retrieves the history of previously analyzed texts along with their sentiment scores.
   - Response:
```json
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
Kelompok kami memutuskan untuk memakai rancangan yang disama ratakan keseluruhan dari spesifikasi VM, alasannya adalah kami menginginkan rancangan cloud yang memanfaatkan secara maksimal dana untuk sumber daya cloud saja selain itu karena cakupan Final Project ini hanya boleh menggunakan dana dengan maksimal total $65 harganya untuk itu kami ingin menganalisis apakah rancangan cloud kami dengan spesifikasi dibawah cukup efektif.

![Cloud drawio (1)](https://github.com/danendrafidel/FP-TKA-C6/assets/150430084/0852ebf7-e87f-4516-a7d9-167e522d706c)

Spesifikasi yang digunakan adalah sebagai berikut :

| No | Nama              | Spesifikasi          | Fungsi         | Harga/Bulan |
|----|-------------------|----------------------|----------------|-------------|
| 1  | VM3-LoadBalancer  | Premium Intel 2vCPU  | Load Balancer  | $21         |
|    |                   | 2GB Memory           |                |             |
| 2  | VM2-Worker1       | Premium Intel 2vCPU  | App Worker 1   | $21         |
|    |                   | 2GB Memory           |                |             |
| 3  | VM2-Worker2       | Premium Intel 2vCPU  | App Worker 2   | $21         |
|    |                   | 2GB Memory           |                |             |
| 4  | VM3-Database 1&2  | Menyesuaikan VM      | Database Server| $0          |
|    |                   |                      |                |             |
|    | **TOTAL**         |                      |                | **$63**     |

Disini kami memakai provider untuk membuat rancangan cloud ini yaitu `Digital Ocean` dengan server singapore, karena terdapat limitasi dalam pembuatan droplet pada digital ocean sebanyak 3 droplet saja yang sudah terpakai untuk load balancer dan 2 worker pada [digital ocean](https://www.digitalocean.com/), lalu untuk database MongoDB kami instal didalam vm worker 1 dan 2 untuk memaksimalkan dana spesifikasi vm worker dan load balancer sehingga untuk harga database itu sendiri menjadi gratis.

Lalu mengapa harga premium intel bisa $21 bukan $24 karena kami disini awalnya memakai basic cpu (2cpu, 1gb) terlebih dahulu untuk membuat ketiga dropletnya terlebih dahulu setelah itu pada fitur upgrade kami melakukan upgrade ke spesifikasi premium intel untuk mendapatkan harga $21/vm yang menyebabkan harganya lebih murah $3.

## B. Implementasi Rancangan Arsitektur Komputasi Awan
Uji coba pada rancangan cloud kami memerlukan beberapa setup yang perlu diinstal dalam vm yang dibutuhkan maka dari itu berikut beberapa pengimplementasiannya : 

### **0. Dashboard Final Project pada Digital Ocean**

![Cuplikan layar 2024-06-27 220108](https://github.com/danendrafidel/FP-TKA-C6/assets/150430084/47d45ef7-6a8f-4e0d-989d-a47f3816252f)

Pada dashboard ini menampilkan 3 droplets vm yang kami install dan gunakan.

### **1. Setup Worker dan Database**

![Cuplikan layar 2024-06-27 220731](https://github.com/danendrafidel/FP-TKA-C6/assets/150430084/89234ccf-e323-433f-901f-789a05a64a49)

![Cuplikan layar 2024-06-27 220754](https://github.com/danendrafidel/FP-TKA-C6/assets/150430084/1dad1a5d-f23b-43bc-9523-8dfcf95dd9d9)

Langkah-langkah untuk mengatur VM menjadi worker sekaligus database:

1. Buat dan jalankan script `worker.sh`:

    a. Buat file `worker.sh` dengan isi berikut:

        #!/bin/bash

        # Clone repository
        git clone https://github.com/fuaddary/fp-tka.git

        # Change directory to BE folder
        cd fp-tka/Resources/BE

        # Setup MongoDB
        sudo apt update
        sudo apt install -y mongodb
        sudo systemctl start mongodb
        sudo systemctl enable mongodb

        # Verify MongoDB installation
        if mongosh --eval "db.runCommand({ connectionStatus: 1 })"; then
            echo "MongoDB setup successfully."
        else
            echo "MongoDB setup failed."
            exit 1
        fi

        # Setup Python environment and install dependencies
        sudo apt install -y python3-venv
        python3 -m venv venv
        source venv/bin/activate
        pip install flask flask-cors textblob pymongo

        # Rename the sentiment analysis file
        mv sentiment-analysis.py sentiment_analysis.py

        # Increase file descriptor limit
        ulimit -n 100000

    b. Jalankan script `worker.sh`:

        chmod +x worker.sh
        ./worker.sh

2. Edit file url BE yang ada di `fp-tka/Resources/FE/index.html`: worker1=`68.183.231.98:5000` dan worker2=`165.22.241.204:5000`.

3. Copy file [index.html](https://github.com/danendrafidel/FP-TKA-C6/blob/main/Resources/worker1/FE/index.html) dan [styles.css](https://github.com/danendrafidel/FP-TKA-C6/blob/main/Resources/worker1/FE/styles.css) ke `/var/www/html`:

        cp index.html /var/www/html
        cp styles.css /var/www/html

4. Buat dan jalankan script `run.sh` untuk menjalankan gunicorn:

    a. Buat file `run.sh` dengan isi berikut:

        #!/bin/bash

        source venv/bin/activate
        gunicorn -b 0.0.0.0:5000 -w 5 -k gevent --timeout 60 --graceful-timeout 60 sentiment_analysis:app

    b. Jalankan script `run.sh`:

        chmod +x run.sh
        ./run.sh

### **2. Setup Load Balancer**

![Cuplikan layar 2024-06-27 220816](https://github.com/danendrafidel/FP-TKA-C6/assets/150430084/c2d440eb-cb94-4633-8973-a68eef892b56)

Langkah-langkah untuk mengatur VM menjadi load balancer:

1. Buat dan jalankan script `lb.sh`:

    a. Buat file `lb.sh` dengan isi berikut:

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

    b. Jalankan script `lb.sh`:

        chmod +x lb.sh
        ./lb.sh

## C. Hasil Pengujian Endpoint
Disini kami menggunakan software Postman untuk pengujian endpoint dari rancangan cloud diatas untuk menguji `POST` dan `GET` pada backend.
### **1. GET**
  - Worker1

   ![get_worker1](https://github.com/danendrafidel/FP-TKA-C6/assets/150430084/8fb9b99a-746d-43c0-82b8-6ab292f2f2e0)

  - Worker2

   ![get_worker2](https://github.com/danendrafidel/FP-TKA-C6/assets/150430084/d2fe70fa-006b-4332-b34e-70b65c5ad32c)

### **2. POST**
  - Worker1

  ![post_0_worker1](https://github.com/danendrafidel/FP-TKA-C6/assets/150430084/54dc7c12-655b-4726-a605-555df79ea89e)

  - Worker2

  ![post_0_worker2](https://github.com/danendrafidel/FP-TKA-C6/assets/150430084/506aa895-02e3-48e4-8fee-1841b66257f3)

### **3. Hasil Frontend**

  - Worker1
    
  ![worker1](https://github.com/danendrafidel/FP-TKA-C6/assets/150430084/5006bc5e-4f2b-4843-819f-2477ad428e16)

  - Worker2
  
  ![worker2](https://github.com/danendrafidel/FP-TKA-C6/assets/150430084/e64e2a42-e565-4189-8fb4-ecad233db818)

Pengujian lainnya dapat dilihat di folder images/endpoint dan images/frontend.

## D. Hasil Pengujian Loadtesting
Disini kami menggunakan LOCUST untuk pengujiannya dan pengujian dilakukan pada vm load balancer dengan ip `159.223.64.29`

### **1. Berapakah jumlah Request per seconds (RPS) maksimum yang dapat ditangani oleh server dengan durasi waktu load testing 60 detik? (tingkat failure harus 0%)**

![50sr (3)](https://github.com/danendrafidel/FP-TKA-C6/assets/150430084/a0834d66-90f2-4541-a74a-e70f4cae3adf)

RPS tertinggi yang bisa didapat dari rancangan cloud kami adalah 490.4 RPS dengan rata-rata RPS 73.56 poin

### **2. Berapa jumlah peak concurrency maksimum yang dapat ditangani oleh server dengan spawn rate 50 dan durasi waktu load testing 60 detik? (tingkat failure harus 0%)**

![50sr (2)](https://github.com/danendrafidel/FP-TKA-C6/assets/150430084/6f537cc8-036c-47c4-9361-a76ffa8f9bae)

RPS yang didapatkan dengan spawn rate 50 adalah 341.4 RPS dengan rata-rata RPS 51.21 poin

### **3. Berapa jumlah peak concurrency maksimum yang dapat ditangani oleh server dengan spawn rate 100 dan durasi waktu load testing 60 detik? (tingkat failure harus 0%)**

![100sr (2)](https://github.com/danendrafidel/FP-TKA-C6/assets/150430084/cae7dd17-4401-427e-bd2c-c363a239cef9)

RPS yang didapatkan dengan spawn rate 100 adalah 328.7 RPS dengan rata-rata RPS 49.305 poin

### **4. Berapa jumlah peak concurrency maksimum yang dapat ditangani oleh server dengan spawn rate 200 dan durasi waktu load testing 60 detik? (tingkat failure harus 0%)**

![200sr (2)](https://github.com/danendrafidel/FP-TKA-C6/assets/150430084/b2e6ef9e-29a1-43af-b80a-3f313aea46b1)

RPS yang didapatkan dengan spawn rate 200 adalah 329.8 RPS dengan rata-rata RPS 49.47 poin

### **5. Berapa jumlah peak concurrency maksimum yang dapat ditangani oleh server dengan spawn rate 500 dan durasi waktu load testing 60 detik? (tingkat failure harus 0%)**

![500sr (2)](https://github.com/danendrafidel/FP-TKA-C6/assets/150430084/4c18ed83-8d41-4614-9a1a-256ed6013392)

rata-rata resource utilization dari 4 percobaan

![htop_lb](https://github.com/danendrafidel/FP-TKA-C6/assets/144349814/3e490c64-65c1-4bc6-a184-595538156577)

RPS yang didapatkan dengan spawn rate 500 adalah 299.6 RPS dengan rata-rata RPS 44.94 poin

Untuk image lain mengenai loadtesting dapat dilihat di images/loadtesting.

## E. Kesimpulan dan Saran

Berdasarkan uji coba yang telah dilakukan, didapatkan beberapa hasil yaitu :

1. Jumlah Request per seconds (RPS) maksimum yang dapat ditangani oleh server dengan durasi waktu load testing selama 60 detik adalah sebesar 490.4 RPS dengan 0% failure.
2. Jumlah peak concurrency maksimum maksimum yang dapat ditangani oleh server dengan spawn rate 50 dan durasi waktu load testing selama 60 detik adalah sebanyak 341.4 RPS dengan 0% failure.
3. Jumlah peak concurrency maksimum maksimum yang dapat ditangani oleh server dengan spawn rate 100 dan durasi waktu load testing selama 60 detik adalah sebanyak 328.7 RPS dengan 0% failure.
4. Jumlah peak concurrency maksimum maksimum yang dapat ditangani oleh server dengan spawn rate 200 dan durasi waktu load testing selama 60 detik adalah sebanyak 329.8 RPS dengan 0% failure.
5. Jumlah peak concurrency maksimum maksimum yang dapat ditangani oleh server dengan spawn rate 500 dan durasi waktu load testing selama 60 detik adalah sebanyak 299.6 RPS dengan 0% failure.

Analisis Kelebihan Arsitektur 2 Worker:

1. Kinerja yang Stabil: Arsitektur 2 worker memberikan kinerja yang stabil dengan jumlah RPS yang tinggi tanpa failure.
2. Manajemen Sumber Daya: Dengan dua worker, menjadi lebih mudah untuk mengelola sumber daya server tanpa membebani sistem secara berlebihan dibanding worker yang lebih banyak dan juga 2 worker bisa dibilang lebih efisien dibanding nanti membuat worker lebih dari 2

Berdasarkan data uji coba tersebut, dapat ditarik kesimpulan bahwa 2 Worker lebih stabil dibandingkan worker yang lebih banyak. Hal ini disebabkan karena beberapa faktor, seperti :

1. Pada 2 worker (premium intel 2cpu, 2gb) dari segi ukuran cukup masif. Jika ingin menambah jumlah worker harus dengan ukuran spesifikasi yang lebih kecil karena keterbatasan dana untuk pengetesan, selain itu hal ini belum kami terapkan karena keterbatasan resource dari digital ocean sendiri untuk membuat droplet lebih dari 3 sehingga kami ingin memanfaatkan hanya dengan worker yang lebih sedikit namun dengan spesifikasi yang lebih masif.
2. Pada saat pertama kali dilakukan uji coba, kami tidak pernah menghapus data pada database sehingga hal ini membuat database penuh, sehingga hal ini dapat teratasi setelah kami menghapus datanya.
3. Pada rancangan kami MongoDB diinstal pada setiap worker yang ada sehingga kami tidak perlu mengeluarkan biaya untuk membuat droplet untuk MongoDB sehingga ini menjadi poin plus untuk pemanfaatan resource yang ada dengan dana yang lebih minim, ini juga menjadi poin penting dalam melakukan load testing dimana database yang langsung terintegrasi/terpasang di worker membuat RPS yang diraih lebih tinggi dibanding MongoDB yang dibuat dengan droplet terpisah alasannya karena MongoDB menjadi lebih efisien dan cepat untuk diakses.
4. Pada saat dilakukan pengujian load balancing, kami memanfaatan caching sehingga tiap kali melakukan request kepada server load balancing akan terasa ringan.

Saran :

Dari rancangan arsitektur kami mungkin bisa menjadi lebih baik hasilnya apabila spesifikasi VM dapat ditingkatkan lagi jika ada dana lebih besar, kemudian untuk setup VM mungkin juga bisa diconfig kembali agar menjadi lebih maksimal sehingga dampaknya untuk pengujian loadtesting bisa mendapat RPS yang lebih tinggi.

## F. VIDEO REVISI

https://youtu.be/LGArzSqM3eM
