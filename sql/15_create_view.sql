CREATE OR ALTER VIEW dbo.vw_Student_Performance AS
SELECT
    m.NIM,
    m.Nama_Mahasiswa,
    p.Nama_Prodi,
    
    -- GANTI ANGKATAN JADI TAHUN AKADEMIK (Lebih Akurat)
    w.Tahun AS Tahun_Akademik, 
    w.Semester,
    
    -- Metrik
    COUNT(f.ID_Fakta_Akademik) AS Jumlah_Matkul_Diambil,
    SUM(f.Jumlah_SKS_Diambil) AS Total_SKS,
    AVG(f.Bobot_Nilai) AS IPS_Semester, -- Indeks Prestasi Semester (Bukan Kumulatif)
    
    -- Status Kelulusan
    CAST(
        SUM(CASE WHEN f.Status_Lulus = 'Lulus' THEN 1.0 ELSE 0.0 END) * 100.0 / COUNT(*) 
    AS DECIMAL(5,2)) AS Tingkat_Kelulusan_Matkul

FROM dbo.Fakta_Akademik f
INNER JOIN dbo.Dim_Mahasiswa m ON f.ID_Mahasiswa = m.ID_Mahasiswa
INNER JOIN dbo.Dim_Prodi p ON m.ID_Prodi = p.ID_Prodi
INNER JOIN dbo.Dim_Waktu w ON f.ID_Waktu = w.ID_Waktu
GROUP BY m.NIM, m.Nama_Mahasiswa, p.Nama_Prodi, w.Tahun, w.Semester;
GO

CREATE OR ALTER VIEW dbo.vw_Dosen_Productivity AS
SELECT
    d.NIP_Dosen,
    d.Nama_Dosen,
    d.Jabatan_Fungsional,
    w.Tahun AS Tahun_Publikasi,
    
    -- Metrik Utama
    COUNT(f.ID_Fakta_Publikasi) AS Jumlah_Judul_Paper,
    SUM(f.Jumlah_Publikasi) AS Total_Publikasi_Resmi, -- (Jika ada pembobotan)
    SUM(f.Jumlah_Sitasi) AS Total_Sitasi

FROM dbo.Fakta_Publikasi f
INNER JOIN dbo.Dim_Dosen d ON f.ID_Dosen = d.ID_Dosen
INNER JOIN dbo.Dim_Waktu w ON f.ID_Waktu = w.ID_Waktu
GROUP BY d.NIP_Dosen, d.Nama_Dosen, d.Jabatan_Fungsional, w.Tahun;
GO


CREATE OR ALTER VIEW dbo.vw_Course_Failure_Analysis AS
SELECT
    p.Nama_Prodi,
    mk.Kode_MK,
    mk.Nama_MK,
    w.Tahun AS Tahun_Ajaran,
    w.Semester,
    
    -- Total Mahasiswa yang ambil
    COUNT(f.ID_Fakta_Akademik) AS Total_Peserta,
    
    -- Jumlah yang Gagal (Status = 'Tidak Lulus')
    SUM(CASE WHEN f.Status_Lulus = 'Tidak Lulus' THEN 1 ELSE 0 END) AS Jumlah_Gagal,
    
    -- Persentase Kegagalan (Failure Rate)
    CAST(
        SUM(CASE WHEN f.Status_Lulus = 'Tidak Lulus' THEN 1.0 ELSE 0.0 END) * 100.0 
        / NULLIF(COUNT(f.ID_Fakta_Akademik), 0)
    AS DECIMAL(5,2)) AS Persentase_Gagal

FROM dbo.Fakta_Akademik f
INNER JOIN dbo.Dim_MataKuliah mk ON f.ID_MK = mk.ID_MK
INNER JOIN dbo.Dim_Prodi p ON mk.ID_Prodi = p.ID_Prodi -- Asumsi MK punya Prodi
INNER JOIN dbo.Dim_Waktu w ON f.ID_Waktu = w.ID_Waktu
GROUP BY p.Nama_Prodi, mk.Kode_MK, mk.Nama_MK, w.Tahun, w.Semester;
GO

CREATE OR ALTER VIEW dbo.vw_Cohort_Distribution AS
SELECT
    p.Nama_Prodi,
    
    -- [LOGIKA PERHITUNGAN ANGKATAN]
    -- Angkatan = 20 + digit ke-2 & ke-3 NIM (Contoh: 121... -> 2021)
    CAST(('20' + SUBSTRING(m.NIM, 2, 2)) AS INT) AS Angkatan_Masuk,
    
    -- Metrik
    COUNT(m.NIM) AS Jumlah_Mahasiswa_Aktif_Saat_Ini
FROM dbo.Dim_Mahasiswa m
INNER JOIN dbo.Dim_Prodi p ON m.ID_Prodi = p.ID_Prodi
-- Filter: Hanya hitung mahasiswa yang statusnya 'Aktif'
WHERE m.Status = 'Aktif' 
GROUP BY 
    p.Nama_Prodi, 
    CAST(('20' + SUBSTRING(m.NIM, 2, 2)) AS INT);
GO
SELECT * FROM dbo.vw_Cohort_Distribution;

CREATE OR ALTER VIEW dbo.vw_Accreditation_Student_Trend AS
SELECT
    p.Nama_Prodi,
    w.Tahun,
    -- PERBAIKAN: Gunakan COUNT(DISTINCT...) untuk menghitung MAHASISWA unik
    COUNT(DISTINCT CASE WHEN m.Status = 'Aktif' THEN m.NIM END) AS Total_Aktif,
    COUNT(DISTINCT CASE WHEN m.Status = 'Lulus' THEN m.NIM END) AS Total_Lulus,
    COUNT(DISTINCT CASE WHEN m.Status = 'Drop Out' THEN m.NIM END) AS Total_Drop_Out
FROM dbo.Dim_Mahasiswa m
INNER JOIN dbo.Dim_Prodi p ON m.ID_Prodi = p.ID_Prodi
INNER JOIN dbo.Dim_Waktu w
    ON w.Tanggal BETWEEN
        CAST(m.StartDate AS DATE) 
        AND ISNULL(CAST(m.EndDate AS DATE), '9999-12-31') 
WHERE w.Tahun >= 2021 
GROUP BY p.Nama_Prodi, w.Tahun;
GO
SELECT * FROM dbo.vw_Accreditation_Student_Trend;
SELECT TOP 5 StartDate, EndDate, Status
FROM dbo.Dim_Mahasiswa;