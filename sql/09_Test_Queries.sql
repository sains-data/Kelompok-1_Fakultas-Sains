-- ======================================================= -- PERFORMANCE TEST SCRIPT -- ======================================================= 
SET STATISTICS TIME ON;  -- Untuk melihat CPU & Elapsed Time 
SET STATISTICS IO ON;    -- Untuk melihat jumlah halaman yang dibaca 
 -- ------------------------------------------------------- -- TEST 1: Complex Join & Aggregation  
 
-- Skenario: "Total performa mahasiswa per Prodi" -- Target: < 3 Detik -- ------------------------------------------------------- 
PRINT '>>> MULAI TEST 1: Analisis Per Prodi'; 
 
SELECT  
    d.Tahun AS Tahun_Akademik, 
    p.Nama_Prodi, 
    COUNT(DISTINCT f.ID_Mahasiswa) AS Total_Mahasiswa, 
    AVG(f.Bobot_Nilai) AS Rata_Rata_IPK, 
    SUM(f.Jumlah_SKS_Diambil) AS Total_SKS 
FROM dbo.Fakta_Akademik f -- Melakukan JOIN ke 3 Tabel Dimensi sekaligus 
INNER JOIN dbo.Dim_Waktu d ON f.ID_Waktu = d.ID_Waktu 
INNER JOIN dbo.Dim_Mahasiswa m ON f.ID_Mahasiswa = m.ID_Mahasiswa 
INNER JOIN dbo.Dim_Prodi p ON m.ID_Prodi = p.ID_Prodi 
GROUP BY d.Tahun, p.Nama_Prodi 
ORDER BY d.Tahun DESC, Rata_Rata_IPK DESC; 
 -- ------------------------------------------------------- -- TEST 2: Time Series Analysis [cite: 1215] -- Skenario: "Tren data per Bulan/Semester" -- Target: < 1 Detik -- ------------------------------------------------------- 
PRINT '>>> MULAI TEST 2: Tren Waktu'; 
 
SELECT  
    d.Tahun, 
    d.Semester, -- atau d.Bulan jika ada 
    COUNT(f.ID_Fakta_Akademik) AS Total_Enrollment, 
    AVG(f.Bobot_Nilai) AS Rata_Rata_Nilai 
FROM dbo.Fakta_Akademik f 
INNER JOIN dbo.Dim_Waktu d ON f.ID_Waktu = d.ID_Waktu 
GROUP BY d.Tahun, d.Semester 
ORDER BY d.Tahun, d.Semester; 
 
SET STATISTICS TIME OFF; 
SET STATISTICS IO OFF; 
