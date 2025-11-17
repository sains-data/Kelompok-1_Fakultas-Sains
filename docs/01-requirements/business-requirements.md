# Business Requirements

Dokumen ini berisi analisis kebutuhan bisnis dan identifikasi sumber data untuk perancangan Data Warehouse Fakultas Sains.

## 1. Business Requirements Analysis

### 1.1 Tujuan
* Menyediakan platform analitik terstruktur serta terpusat untuk mendukung pengambilan keputusan yang tepat.
* Membangun sistem operasional berbasis data bagi seluruh stakeholder di lingkungan Fakultas Sains.
* Mengubah data operasional menjadi informasi bisnis yang siap dianalisis guna meningkatkan kualitas layanan akademik.

### 1.2 Identifikasi Stakeholders
Berikut adalah pemetaan stakeholders yang terlibat dalam pengambilan keputusan:

| Stakeholders | Tipe | Tujuan Bisnis |
| :--- | :--- | :--- |
| **Dekan, Wakil Dekan** | Decision Maker | Memonitor IKU fakultas, evaluasi efisiensi operasional Prodi, perencanaan anggaran & sumber daya. |
| **Kepala Program Studi** | Decision Maker | Memonitor standar mutu akademik internal, akses data historis untuk akreditasi. |
| **Staff Tata Usaha** | Pengguna Utama | Menyediakan data mahasiswa, menyusun laporan statistik, validasi data. |
| **Koordinator Penjaminan Mutu** | Decision Maker | Akses data valid untuk akreditasi, monitor standar mutu, melacak efektivitas perbaikan mutu. |
| **Tim Akreditasi** | Decision Maker | Memperoleh metrik data untuk Laporan Evaluasi dan Laporan Kinerja Program Studi. |

### 1.3 Analisis Proses Bisnis
Proses bisnis utama yang menjadi fokus data warehouse:

| Proses Bisnis Utama | KPI Utama | Metrik Data |
| :--- | :--- | :--- |
| **Pengelolaan Akademik & Perkuliahan** | Rata-rata IPK per semester/fakultas, tingkat keberhasilan mata kuliah | Jumlah mahasiswa aktif per prodi, rata-rata IPK per angkatan, Persentase mata kuliah gagal, Jumlah SKS diambil. |
| **Penelitian & Publikasi Dosen** | Jumlah penelitian aktif & publikasi per tahun, kualitas publikasi, rasio dosen:mahasiswa | Jumlah Penelitian lolos pendanaan, jumlah publikasi terindeks, Jumlah sitasi (per Dosen). |

### 1.4 Kebutuhan Analitik (Analytic Needs)

#### A. Pengelolaan Akademik
**Pertanyaan Bisnis Utama:**
* Bagaimana tren rata-rata IPK per angkatan di setiap program studi selama 5 tahun terakhir?
* Mata kuliah apa saja yang memiliki persentase kegagalan (nilai D/E) tertinggi di setiap prodi?
* Bagaimana sebaran jumlah mahasiswa aktif per program studi dan per angkatan saat ini?
* Bagaimana tren jumlah mahasiswa masuk, lulus, dan drop-out selama 7 tahun terakhir?

**Dashboard yang Dibutuhkan:**
1.  **Dashboard Eksekutif Akademik:** Ringkasan KPI utama (total mahasiswa, IPK, kelulusan).
2.  **Laporan Performa Program Studi:** Drill-down IPK prodi ke angkatan hingga mata kuliah.
3.  **Laporan Statistik Akreditasi:** Data historis tren mahasiswa untuk borang akreditasi.

#### B. Penelitian dan Publikasi Dosen
**Pertanyaan Bisnis Utama:**
* Siapa 10 dosen dengan jumlah sitasi dan publikasi terindeks tertinggi?
* Berapa rasio penelitian lolos pendanaan terhadap proposal yang diajukan?
* Berapa rasio dosen tetap terhadap jumlah mahasiswa di setiap prodi?

**Dashboard yang Dibutuhkan:**
1.  **Dashboard Kinerja Tri Dharma:** Monitor produktivitas dosen (publikasi, sitasi).
2.  **Laporan Profil Dosen:** Detail riwayat publikasi dan penelitian per dosen.
