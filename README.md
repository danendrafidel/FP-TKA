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
Kelompok kami memutuskan untuk memakai rancangan yang disama ratakan keseluruhan dari spesifikasi VM, alasannya adalah kami menginginkan rancangan cloud yang berspesifikasi medium saja dan tidak terlalu mahal harganya untuk itu kami ingin menganalisis apakah rancangan cloud kami dengan spesifikasi dibawah cukup efektif.

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
| 4  | VM3-Database      | Regular 1vCPU        | Database Server| $12         |
|    |                   | 2GB Memory           |                |             |
|    | **TOTAL**         |                      |                | **$48**     |

## B. Implementasi Rancangan Arsitektur Komputasi Awan
Uji coba pada rancangan cloud kami memerlukan beberapa setup yang perlu diinstal dalam vm yang dibutuhkan maka dari itu berikut beberapa pengimplementasiannya : 

## C. Hasil Pengujian Endpoint
Disini kami menggunakan software Postman untuk pengujian endpoint dari rancangan cloud diatas untuk menguji `POST` dan `GET`

## D. Hasil Pengujian Loadtesting
Disini kami menggunakan LOCUST untuk pengujiannya

## E. Kesimpulan dan Saran
