# Data Dictionary - Data Mart Fakultas Sains

Dokumen ini berisi detail definisi tabel, tipe data, dan aturan bisnis untuk Data Warehouse Fakultas Sains.

## 1. Fact Tables

### 1.1 Fact_Akademik
Tabel ini menyimpan data transaksional akademik mahasiswa (KRS dan Nilai).

| Column | Data Type | Key | Description | Business Rule |
| :--- | :--- | :--- | :--- | :--- |
| **ID_Fakta_Akademik** | INT | PK | Surrogate key untuk setiap baris fakta akademik | Auto-increment, unik |
| **ID_Mahasiswa** | INT | FK | Merujuk ke Dim_Mahasiswa | Harus ada pada Dim_Mahasiswa |
| **ID_Dosen** | INT | FK | Merujuk ke Dim_Dosen | Harus ada pada Dim_Dosen |
| **ID_MK** | INT | FK | Merujuk ke Dim_MataKuliah | Harus ada pada Dim_MataKuliah |
| **ID_Waktu** | INT | FK | Merujuk ke Dim_Waktu | Harus ada pada Dim_Waktu |
| **Jumlah_SKS_Diambil** | INT | Measure | Jumlah SKS yang diambil | Sesuai beban MK |
| **Bobot_Nilai** | DECIMAL(3,2) | Measure | Nilai konversi (A=4, B=3, dst) untuk hitung IPK | Range: 0.00 - 4.00 |
| **Status_Lulus** | INT | Measure | Indikator kelulusan | 1 = Lulus, 0 = Tidak (E) |

### 1.2 Fact_Publikasi
Tabel ini menyimpan data produktivitas publikasi dan penelitian dosen.

| Column | Data Type | Key | Description | Business Rule |
| :--- | :--- | :--- | :--- | :--- |
| **ID_Fakta_Publikasi** | BIGINT | PK | Surrogate key untuk publikasi | Auto-increment, unik |
| **ID_Dosen** | INT | FK | Dosen yang mempublikasikan | Harus ada pada Dim_Dosen |
| **ID_Jurnal** | VARCHAR(15) | FK | Jurnal tempat publikasi | Harus ada pada Dim_Jurnal |
| **ID_Waktu** | INT | FK | Tahun publikasi | Harus ada pada Dim_Waktu |
| **Jumlah_Sitasi** | INT | Measure | Banyaknya sitasi yang diterima | >= 0 (Bisa 0 jika baru terbit) |
| **Jumlah_Publikasi** | INT | Measure | Counter jumlah publikasi | Selalu bernilai 1 |

---

## 2. Dimension Tables

### 2.1 Dim_Mahasiswa
Menyimpan profil mahasiswa dengan penerapan **SCD Type 2** untuk melacak perubahan status.

| Column | Data Type | Key | Description | Business Rule |
| :--- | :--- | :--- | :--- | :--- |
| **ID_Mahasiswa** | INT | PK | ID unik sistem (Surrogate Key) | Unik |
| **NIM** | VARCHAR(20) | Natural | Nomor Induk Mahasiswa | Wajib, Unik |
| **Nama_Mahasiswa** | VARCHAR(100) | - | Nama lengkap mahasiswa | Tidak boleh kosong |
| **Angkatan** | INT | - | Tahun masuk mahasiswa | Range: 2020-2024 |
| **Status** | VARCHAR(20) | - | Status keaktifan | Aktif, Cuti, DO, Lulus |
| **ID_Prodi** | INT | FK | Merujuk ke Dim_Prodi | Harus ada pada Dim_Prodi |
| **StartDate** | DATE | - | Tanggal mulai berlaku data | Format YYYY-MM-DD, Not Null |
| **EndDate** | DATE | - | Tanggal berakhir data | Format YYYY-MM-DD, Null jika aktif |
| **IsCurrent** | INT | - | Penanda data terbaru | 1 = Current, 0 = History |

### 2.2 Dim_Dosen
Menyimpan informasi tenaga pengajar.

| Column | Data Type | Key | Description | Business Rule |
| :--- | :--- | :--- | :--- | :--- |
| **ID_Dosen** | INT | PK | ID unik sistem (Surrogate Key) | Unik |
| **NIP_Dosen** | VARCHAR(20) | Natural | Nomor Induk Pegawai | Wajib |
| **Nama_Dosen** | VARCHAR(100) | - | Nama lengkap dosen | Tidak boleh kosong |
| **Jabatan_Fungsional** | VARCHAR(50) | - | Jabatan akademik | Asisten Ahli/Lektor/Guru Besar |
| **ID_Prodi** | INT | FK | Merujuk ke Dim_Prodi | Harus ada pada Dim_Prodi |

### 2.3 Dim_MataKuliah
Menyimpan daftar mata kuliah yang diselenggarakan.

| Column | Data Type | Key | Description | Business Rule |
| :--- | :--- | :--- | :--- | :--- |
| **ID_MK** | INT | PK | ID unik sistem (Surrogate Key) | Unik, Auto-increment |
| **Kode_MK** | VARCHAR(15) | Natural | Kode unik mata kuliah | Unik per prodi |
| **Nama_MK** | VARCHAR(100) | - | Nama mata kuliah | Tidak boleh kosong |
| **SKS** | INT | - | Beban studi | Range: 1-6 SKS |
| **Nama_Prodi** | VARCHAR(100) | - | Prodi penyelenggara | Valid sesuai Dim_Prodi |

### 2.4 Dim_Prodi
Menyimpan data referensi Program Studi.

| Column | Data Type | Key | Description | Business Rule |
| :--- | :--- | :--- | :--- | :--- |
| **ID_Prodi** | INT | PK | ID unik sistem (Surrogate Key) | Unik, Auto-increment |
| **Kode_Prodi** | VARCHAR(10) | Natural | Kode unik program studi | Wajib |
| **Nama_Prodi** | VARCHAR(100) | - | Nama program studi | Tidak boleh kosong |

### 2.5 Dim_Jurnal
Menyimpan referensi jurnal tempat publikasi dosen.

| Column | Data Type | Key | Description | Business Rule |
| :--- | :--- | :--- | :--- | :--- |
| **ID_Jurnal** | INT | PK | ID unik jurnal (Surrogate Key) | Unik |
| **Kode_Jurnal** | VARCHAR(15) | Natural | Kode jurnal | - |
| **Nama_Jurnal** | VARCHAR(100) | - | Nama lengkap jurnal | - |
| **Penerbit** | VARCHAR(100) | - | Nama institusi/penerbit | - |

### 2.6 Dim_Waktu
Dimensi waktu untuk analisis *Time Series*.

| Column | Data Type | Key | Description | Business Rule |
| :--- | :--- | :--- | :--- | :--- |
| **ID_Waktu** | INT | PK | Surrogate key dimensi waktu | Unik |
| **Tanggal** | VARCHAR(30) | - | Tanggal lengkap Masehi | Format YYYY-MM-DD |
| **Tahun** | INT | - | Angka tahun 4 digit | Range 2020-2024 |
| **Bulan_Angka** | INT | - | Representasi numerik bulan | Range 1-12 |
| **Nama_Bulan** | VARCHAR(15) | - | Nama bulan (Bahasa Indonesia) | Januari - Desember |
| **Tahun_Ajaran** | VARCHAR(15) | - | Periode akademik | Format YYYY/YYYY |
| **Semester** | VARCHAR(10) | - | Semester perkuliahan | Ganjil / Genap |
