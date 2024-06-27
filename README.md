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

Disini kami memakai provider untuk membuat rancangan cloud ini yaitu `Digital Ocean`, karena terdapat limitasi dalam pembuatan droplet pada digital ocean sebanyak 3 droplet saja yang sudah terpakai untuk load balancer dan 2 worker pada [digital ocean](https://www.digitalocean.com/), lalu untuk database MongoDB kami instal didalam vm worker 1 dan 2 untuk memaksimalkan dana spesifikasi vm worker dan load balancer sehingga untuk harga database itu sendiri menjadi gratis.

Lalu mengapa harga premium intel bisa $21 bukan $24 karena kami disini awalnya memakai basic cpu terlebih dahulu untuk membuat ketiga dropletnya terlebih dahulu setelah itu pada fitur upgrade kami melakukan upgrade ke spesifikasi premium intel untuk mendapatkan harga $21/vm yang menyebabkan harganya lebih murah $3.

## B. Implementasi Rancangan Arsitektur Komputasi Awan
Uji coba pada rancangan cloud kami memerlukan beberapa setup yang perlu diinstal dalam vm yang dibutuhkan maka dari itu berikut beberapa pengimplementasiannya : 

### **0. Dashboard Final Project pada Digital Ocean**

![Cuplikan layar 2024-06-27 220108](https://github.com/danendrafidel/FP-TKA-C6/assets/150430084/47d45ef7-6a8f-4e0d-989d-a47f3816252f)

Pada dashboard ini menampilkan 3 droplets vm yang kami install dan gunakan.

### **1. Setup Worker**

![Cuplikan layar 2024-06-27 220731](https://github.com/danendrafidel/FP-TKA-C6/assets/150430084/89234ccf-e323-433f-901f-789a05a64a49)

![Cuplikan layar 2024-06-27 220754](https://github.com/danendrafidel/FP-TKA-C6/assets/150430084/1dad1a5d-f23b-43bc-9523-8dfcf95dd9d9)

### **2. Setup Load Balancer**

![Cuplikan layar 2024-06-27 220816](https://github.com/danendrafidel/FP-TKA-C6/assets/150430084/c2d440eb-cb94-4633-8973-a68eef892b56)

### **3. Setup Database**

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

RPS yang didapatkan dengan spawn rate 500 adalah 299.6 RPS dengan rata-rata RPS 44.94 poin

Untuk image lain mengenai loadtesting dapat dilihat di images/loadtesting.

## E. Kesimpulan dan Saran

Berdasarkan uji coba yang telah dilakukan, didapatkan beberapa hasil yaitu :

1. Jumlah Request per seconds (RPS) maksimum yang dapat ditangani oleh server dengan durasi waktu load testing selama 60 detik adalah sebesar 490.4 RPS dengan 0% failure.
2. Jumlah peak concurrency maksimum maksimum yang dapat ditangani oleh server dengan spawn rate 50 dan durasi waktu load testing selama 60 detik adalah sebanyak 341.4 RPS dengan 0% failure.
3. Jumlah peak concurrency maksimum maksimum yang dapat ditangani oleh server dengan spawn rate 100 dan durasi waktu load testing selama 60 detik adalah sebanyak 328.7 RPS dengan 0% failure.
4. Jumlah peak concurrency maksimum maksimum yang dapat ditangani oleh server dengan spawn rate 200 dan durasi waktu load testing selama 60 detik adalah sebanyak 329.8 RPS dengan 0% failure.
5. Jumlah peak concurrency maksimum maksimum yang dapat ditangani oleh server dengan spawn rate 500 dan durasi waktu load testing selama 60 detik adalah sebanyak 299.6 RPS dengan 0% failure.

Analisis :

Kelebihan Arsitektur 2 Worker:
1. Kinerja yang Stabil: Arsitektur 2 worker memberikan kinerja yang stabil dengan jumlah RPS yang tinggi tanpa failure.
2. Manajemen Sumber Daya: Dengan dua worker, menjadi lebih mudah untuk mengelola sumber daya server tanpa membebani sistem secara berlebihan dibanding worker lebih dari 2 dan juga 2 worker bisa dibilang lebih efisien dibanding nanti membuat worker lebih dari 2

Berdasarkan data uji coba tersebut, dapat ditarik kesimpulan bahwa 2 Worker lebih stabil dibandingkan worker lebih dari 2. Hal ini disebabkan karena beberapa faktor, seperti :
1. Pada 2 worker (premium intel 2cpu, 2gb) dari segi ukuran cukup masif. Jika ingin menambah jumlah worker harus dengan ukuran spesifikasi yang lebih kecil karena keterbatasan dana untuk pengetesan, selain itu hal ini belum kami terapkan karena keterbatasan resource dari digital ocean sendiri untuk membuat droplet lebih dari 3 sehingga kami ingin memanfaatkan hanya dengan worker yang lebih sedikit namun dengan spesifikasi yang lebih masif.
2. Pada saat pertama kali dilakukan uji coba, kami tidak pernah menghapus data pada database sehingga hal ini membuat database penuh, sehingga hal ini dapat teratasi setelah kami menghapus datanya.
