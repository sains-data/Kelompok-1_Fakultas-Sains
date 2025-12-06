## 2.2 Data Sources Overview

Berikut adalah rincian profil data dari setiap sumber yang digunakan dalam perancangan Data Warehouse ini:

| Data Source | Type | Volume | Growth Rate | Frekuensi Update |
| :--- | :--- | :--- | :--- | :--- |
| **Mahasiswa** | CSV (Synthetic) | 500 rows | **Moderate** (Bertambah setiap tahun ajaran baru) | **Semester** (Update status aktif/cuti/lulus) |
| **Prodi** | CSV (Synthetic) | 9 rows | **Stagnan** (Sangat jarang bertambah) | **Ad-hoc** (Hanya saat ada perubahan struktur organisasi) |
| **Dosen** | CSV (Synthetic) | 251 rows | **Low** (Bertambah saat rekrutmen baru) | **Semester** (Update jabatan fungsional/sertifikasi) |
| **Mata Kuliah** | CSV (Synthetic) | 300 rows | **Low** (Bertambah/berubah saat kurikulum baru) | **5 Tahun Sekali** (Mayor) / Semester (Minor) |
| **Jurnal** | CSV (Synthetic) | 200 rows | **Moderate** (Bertambah seiring variasi publikasi) | **Monthly/Ad-hoc** (Saat ada jurnal tujuan baru) |
| **Akademik** | CSV (Synthetic) | 10000 rows | **High** (Bertambah pesat tiap semester) | **Real-time** (Selama masa pengisian nilai) / Semester |
| **Publikasi Dosen** | CSV (Synthetic) | 10000 rows | **Moderate** (Sesuai target kinerja tahunan) | **Annual** (Biasanya direkap akhir tahun/semester) |
