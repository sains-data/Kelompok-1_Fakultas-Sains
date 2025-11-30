CREATE OR ALTER PROCEDURE dbo.usp_Generate_DQ_Report
AS
BEGIN
    SET NOCOUNT ON;
    
    -- 1. Bersihkan Log Lama
    -- (Agar laporan selalu fresh setiap kali dijalankan)
    IF OBJECT_ID('dbo.DataQuality_Log', 'U') IS NOT NULL
        TRUNCATE TABLE dbo.DataQuality_Log;
    ELSE
        -- Buat tabel jika belum ada (Safety net)
        CREATE TABLE dbo.DataQuality_Log (
            LogID INT IDENTITY(1,1), 
            CheckDate DATETIME DEFAULT GETDATE(),
            TableName VARCHAR(50), 
            MetricName VARCHAR(100), 
            ErrorCount INT, 
            Status VARCHAR(20)
        );

    --------------------------------------------------------
    -- A. CEK FAKTA AKADEMIK (Sesuai Modul Hal 24)
    --------------------------------------------------------
    
    -- CHECK 1: COMPLETENESS (Kelengkapan Data) 
    -- Memastikan tidak ada kolom kunci yang kosong (NULL)
    INSERT INTO dbo.DataQuality_Log (TableName, MetricName, ErrorCount, Status)
    SELECT 'Fakta_Akademik', 'Completeness: Null Mandatory Columns', 
        COUNT(*), 
        CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
    FROM dbo.Fakta_Akademik
    WHERE ID_Mahasiswa IS NULL OR ID_MK IS NULL OR ID_Dosen IS NULL OR ID_Waktu IS NULL;

    -- CHECK 2: CONSISTENCY / REFERENTIAL INTEGRITY 
    -- Memastikan semua ID di Fakta ada induknya di Dimensi (Join ID ke ID)
    
    -- Cek Mahasiswa
    INSERT INTO dbo.DataQuality_Log (TableName, MetricName, ErrorCount, Status)
    SELECT 'Fakta_Akademik', 'Integrity: Orphan Mahasiswa', 
        COUNT(*), CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
    FROM dbo.Fakta_Akademik f 
    LEFT JOIN dbo.Dim_Mahasiswa d ON f.ID_Mahasiswa = d.ID_Mahasiswa
    WHERE d.ID_Mahasiswa IS NULL;

    -- Cek Mata Kuliah
    INSERT INTO dbo.DataQuality_Log (TableName, MetricName, ErrorCount, Status)
    SELECT 'Fakta_Akademik', 'Integrity: Orphan Mata Kuliah', 
        COUNT(*), CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
    FROM dbo.Fakta_Akademik f 
    LEFT JOIN dbo.Dim_MataKuliah d ON f.ID_MK = d.ID_MK
    WHERE d.ID_MK IS NULL;

    -- Cek Waktu (Penting! Karena tadi sempat error di sini)
    INSERT INTO dbo.DataQuality_Log (TableName, MetricName, ErrorCount, Status)
    SELECT 'Fakta_Akademik', 'Integrity: Orphan Waktu', 
        COUNT(*), CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
    FROM dbo.Fakta_Akademik f 
    LEFT JOIN dbo.Dim_Waktu d ON f.ID_Waktu = d.ID_Waktu
    WHERE d.ID_Waktu IS NULL;

    -- CHECK 3: ACCURACY (Keakuratan Nilai) 
    -- Memastikan Bobot Nilai ada di range 0.00 - 4.00
    INSERT INTO dbo.DataQuality_Log (TableName, MetricName, ErrorCount, Status)
    SELECT 'Fakta_Akademik', 'Accuracy: Grade Range (0-4)', 
        COUNT(*), CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
    FROM dbo.Fakta_Akademik
    WHERE Bobot_Nilai < 0.00 OR Bobot_Nilai > 4.00;

    -- CHECK 4: BUSINESS LOGIC CONSISTENCY
    -- Memastikan SKS di Fakta sama dengan SKS di Dimensi
    INSERT INTO dbo.DataQuality_Log (TableName, MetricName, ErrorCount, Status)
    SELECT 'Fakta_Akademik', 'Consistency: SKS Match', 
        COUNT(*), CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
    FROM dbo.Fakta_Akademik f 
    JOIN dbo.Dim_MataKuliah mk ON f.ID_MK = mk.ID_MK 
    WHERE f.Jumlah_SKS_Diambil <> mk.SKS;

    --------------------------------------------------------
    -- B. CEK FAKTA PUBLIKASI
    --------------------------------------------------------

    -- Cek Integritas Dosen (Penulis)
    INSERT INTO dbo.DataQuality_Log (TableName, MetricName, ErrorCount, Status)
    SELECT 'Fakta_Publikasi', 'Integrity: Orphan Dosen', 
        COUNT(*), CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
    FROM dbo.Fakta_Publikasi f 
    LEFT JOIN dbo.Dim_Dosen d ON f.ID_Dosen = d.ID_Dosen
    WHERE d.ID_Dosen IS NULL;

    -- Cek Integritas Jurnal
    INSERT INTO dbo.DataQuality_Log (TableName, MetricName, ErrorCount, Status)
    SELECT 'Fakta_Publikasi', 'Integrity: Orphan Jurnal', 
        COUNT(*), CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
    FROM dbo.Fakta_Publikasi f 
    LEFT JOIN dbo.Dim_Jurnal j ON f.ID_Jurnal = j.ID_Jurnal
    WHERE j.ID_Jurnal IS NULL;

    -- Cek Akurasi (Sitasi tidak boleh negatif)
    INSERT INTO dbo.DataQuality_Log (TableName, MetricName, ErrorCount, Status)
    SELECT 'Fakta_Publikasi', 'Accuracy: Non-Negative Citation', 
        COUNT(*), CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
    FROM dbo.Fakta_Publikasi
    WHERE Jumlah_Sitasi < 0;

    -- TAMPILKAN HASIL AKHIR
    SELECT * FROM dbo.DataQuality_Log;
END;
GO
EXEC dbo.usp_Generate_DQ_Report;

SELECT 
    ID_Mahasiswa, ID_MK, ID_Waktu, 
    COUNT(*) AS Jumlah_Duplikat
FROM dbo.Fakta_Akademik
GROUP BY ID_Mahasiswa, ID_MK, ID_Waktu
HAVING COUNT(*) > 1;

SELECT 'Staging (Source)' AS Lokasi, COUNT(*) AS Jumlah FROM stg.Fakta_Akademik
UNION ALL
SELECT 'Fakta (Warehouse)', COUNT(*) FROM dbo.Fakta_Akademik;
SELECT 'Staging (Source)' AS Lokasi, COUNT(*) AS Jumlah FROM stg.Fakta_Publikasi
UNION ALL
SELECT 'Fakta (Warehouse)', COUNT(*) FROM dbo.Fakta_Publikasi;
