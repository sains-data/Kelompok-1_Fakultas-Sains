# Kelompok-1_Fakultas-Sains
Tugas Besar Pergudangan Data - Kelompok 1

## Team Members
- Tanty Widiyastuti — 123450094  
- Feby Wulandari — 123450042  
- Siti Nur Aarifah — 122450006  
- Vania Claresta — 123450029 

## Project Description
Data mart ini dirancang untuk Fakultas Sains guna memonitor kinerja akademik dan publikasi dosen.

## Business Domain
Fokus pada kegiatan tridharma perguruan tinggi:
1. Pendidikan & Pengajaran (kinerja akademik mahasiswa)  
2. Publikasi Dosen

## Architecture
- Approach: Kimball
- Platform: SQL Server on Azure VM
- ETL: SSIS

## Key Features
- **Fact Tables**:  
  - `Fact_Akademik` — berisi data nilai mahasiswa, SKS, semester, dosen pengampu, dan mata kuliah.  
  - `Fact_Publikasi` — berisi data publikasi dosen seperti judul, jenis publikasi, tahun, dan level publikasi.  

- **Dimension Tables**:  
  - `Dim_Mahasiswa` — informasi mahasiswa (NIM, nama, angkatan, prodi).  
  - `Dim_MataKuliah` — informasi mata kuliah (kode MK, nama MK, SKS, prodi).  
  - `Dim_Dosen` — informasi dosen (NIP, nama, jabatan fungsional, prodi).  
  - `Dim_Prodi` — informasi program studi di Fakultas Sains.  
  - `Dim_Waktu` — kalender waktu (tahun, semester, bulan, tanggal).  

- **KPIs**:  
  - **IPK rata-rata per program studi**  
  - **Jumlah publikasi dosen per tahun**  
  - **Persentase mahasiswa lulus tepat waktu**  
  - **Rasio dosen terhadap mahasiswa**  
  - **Distribusi nilai per mata kuliah**  
  - **Tren publikasi berdasarkan jenis (jurnal, prosiding, konferensi)**  


## Documentation
- [Business Requirements](docs/01-requirements/)
- [Design Documents](docs/02-design/)

## Timeline
- Misi 1: 17-11-2025
- Misi 2: [Tanggal]
- Misi 3: [Tanggal]

