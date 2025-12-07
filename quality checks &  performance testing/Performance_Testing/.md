# Performance Testing & Query Optimization

Dokumen ini berisi hasil pengujian performa query pada Data Mart untuk memastikan efisiensi *Logical Reads* dan waktu eksekusi (Elapsed Time).

## 1. Benchmark Result

### Skenario A: Analisis Akademik
Pengujian dilakukan pada tabel `Fakta_Akademik` dengan join ke 4 tabel dimensi (Mahasiswa, Prodi, Waktu, Matakuliah).

| Test ID | Skenario | Target Waktu | Waktu Aktual | I/O Efficiency | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **TC-01** | Analisis Per Prodi (Complex Join & Aggregation) | < 3000 ms | **203 ms** | 106 Pages | ✅ PASS |
| **TC-02** | Tren Waktu (Time Series Grouping) | < 2000 ms | **219 ms** | 106 Pages | ✅ PASS |

### Skenario B: Analisis Publikasi
Pengujian dilakukan pada tabel `Fakta_Publikasi` dengan join ke 3 tabel dimensi.

| Test ID | Skenario | Target Waktu | Waktu Aktual | I/O Efficiency | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **TC-03** | Produktivitas Dosen (Complex Join) | < 3000 ms | **219 ms** | 43 Pages | ✅ PASS |
| **TC-04** | Tren Publikasi Kampus (Time Series Aggregation) | < 1000 ms | **253 ms** | 43 Pages | ✅ PASS |

---

## 2. Output Verification
Berikut adalah sampel data yang dihasilkan dari query di atas untuk memvalidasi kebenaran data.

### 2.1 Sample Output: Performa Program Studi (TC-01)
*Menampilkan Rata-rata IPK dan Total SKS per Angkatan 2024.*

| Tahun | Nama Prodi | Total Mhs | Rata-rata IPK | Total SKS |
| :--- | :--- | :--- | :--- | :--- |
| 2024 | Sains Data | 36 | 1.91 | 730 |
| 2024 | Fisika | 56 | 2.09 | 776 |
| 2024 | Biologi | 55 | 2.10 | 744 |
| 2024 | Sains Atmosfer | 55 | 2.08 | 802 |
| 2024 | Matematika | 55 | 1.99 | 837 |

### 2.2 Sample Output: Tren Akademik (TC-02)
*Rekapitulasi Enrollment dan Nilai per Semester.*

| Tahun | Bulan | Total Enrollment | Rata-rata Nilai |
| :--- | :--- | :--- | :--- |
| 2023 | Ganjil | 1258 | 1.98 |
| 2023 | Genap | 1252 | 2.01 |
| 2024 | Ganjil | 1238 | 2.01 |
| 2024 | Genap | 1195 | 1.93 |

### 2.3 Sample Output: Produktivitas Dosen (TC-03)
*Top Author berdasarkan jumlah paper dan publikasi tercatat.*

| Tahun | Nama Dosen | Jabatan | Total Paper | Total Publikasi |
| :--- | :--- | :--- | :--- | :--- |
| 2023 | Nanda Nugroho | Asisten Ahli | 40 | 123 |
| 2023 | Novi Saputra | Lektor | 30 | 89 |
| 2024 | Dewi Herlambang | Asisten Ahli | 32 | 74 |
| 2024 | Putri Santoso | Asisten Ahli | 24 | 70 |

### 2.4 Sample Output: Tren Sitasi (TC-04)
*Total Sitasi dan Publikasi Tahunan Fakultas Sains.*

| Tahun | Total Sitasi | Total Publikasi |
| :--- | :--- | :--- |
| 2024 | 121,993 | 7,231 |
| 2023 | 124,382 | 7,456 |
| 2022 | 125,576 | 7,531 |
| 2021 | 124,299 | 7,660 |
