--Cek Kelengkapan Data (Completeness/NULLs)
-- Cek Fakta Akademik
SELECT 
    COUNT(*) AS Total_Baris,
    SUM(CASE WHEN ID_Mahasiswa IS NULL THEN 1 ELSE 0 END) AS Null_Mahasiswa_Key,
    SUM(CASE WHEN Bobot_Nilai IS NULL THEN 1 ELSE 0 END) AS Null_Bobot_Nilai
FROM dbo.Fakta_Akademik;


-- Cek Fakta Publikasi
SELECT 
    COUNT(*) AS Total_Baris,
    SUM(CASE WHEN ID_Dosen IS NULL THEN 1 ELSE 0 END) AS Null_Dosen_Key,
    SUM(CASE WHEN Jumlah_Sitasi IS NULL THEN 1 ELSE 0 END) AS Null_Sitasi
FROM dbo.Fakta_Publikasi;
-- Hasilnya harusnya 0 untuk kolom Null_...

--Cek Akurasi Data (Valid Range Check)
-- Cek apakah ada Nilai Akademik di luar batas (0.00 - 4.00)
SELECT COUNT(*) AS Invalid_Grades
FROM dbo.Fakta_Akademik
WHERE Bobot_Nilai > 4.00 OR Bobot_Nilai < 0.00;
-- Hasilnya harusnya 0, karena kita sudah pakai logika CAST/DECIMAL yang benar.

--Cek Integritas Referensial (Orphan Records)

-- Cek apakah ada Fakta Akademik yang Mahasiswanya tidak ditemukan di Dimensi
SELECT COUNT(*) AS Orphan_Records_Mhs
FROM dbo.Fakta_Akademik f
LEFT JOIN dbo.Dim_Mahasiswa d ON f.ID_Mahasiswa = d.ID_Mahasiswa
WHERE d.ID_Mahasiswa IS NULL;

-- Cek apakah ada Fakta Publikasi yang Jurnalnya tidak ditemukan di Dimensi
SELECT COUNT(*) AS Orphan_Records_Jurnal
FROM dbo.Fakta_Publikasi f
LEFT JOIN dbo.Dim_Jurnal j ON f.ID_Jurnal = j.ID_Jurnal
WHERE j.ID_Jurnal IS NULL;


