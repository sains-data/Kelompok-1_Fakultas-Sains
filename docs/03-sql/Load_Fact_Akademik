-- =========================================================
-- 1. RESET TOTAL
-- =========================================================
TRUNCATE TABLE stg.Fakta_Akademik;
TRUNCATE TABLE dbo.Fakta_Akademik;

-- =========================================================
-- 2. GENERATE DATA =========================================================
INSERT INTO stg.Fakta_Akademik (
    ID_Mahasiswa,   
    ID_MK,          
    ID_Dosen,       
    ID_Waktu, 
    Jumlah_SKS_Diambil, 
    Bobot_Nilai, 
    Status_Lulus
)
SELECT TOP 10000 
    m.ID_Mahasiswa, -- AMBIL ID DARI DIMENSI 
    mk.ID_MK,       -- AMBIL ID DARI DIMENSI 
    d.ID_Dosen,     -- AMBIL ID DARI DIMENSI 
    
    -- GENERATE ID WAKTU (Pasti antara 2021-2024, pasti ada di Dimensi)
    CAST(CONCAT(
        (2021 + ABS(CHECKSUM(NEWID())) % 4), -- Tahun 2021, 2022, 2023, 2024
        RIGHT('0' + CAST((1 + ABS(CHECKSUM(NEWID())) % 12) AS VARCHAR(2)), 2), -- Bulan 01-12
        RIGHT('0' + CAST((1 + ABS(CHECKSUM(NEWID())) % 28) AS VARCHAR(2)), 2)  -- Tanggal 01-28
    ) AS INT),
    
    CAST(mk.SKS AS INT), -- AMBIL SKS DARI DIMENSI (Pasti Sama dengan ID_MK)

    -- GENERATE NILAI (0-4)
    Val.NilaiBulat,

    -- LOGIKA STATUS (Sinkron dengan Nilai)
    CASE WHEN Val.NilaiBulat >= 2 THEN 'Lulus' ELSE 'Tidak Lulus' END

FROM dbo.Dim_Mahasiswa m
CROSS JOIN dbo.Dim_MataKuliah mk 
CROSS JOIN dbo.Dim_Dosen d
CROSS APPLY (
    SELECT ABS(CHECKSUM(NEWID())) % 5 AS NilaiBulat -- Hasil: 0, 1, 2, 3, 4
) Val
ORDER BY NEWID(); -- Acak Baris

-- =========================================================
-- 3. JALANKAN LOAD
-- =========================================================
EXEC dbo.usp_Load_Fakta_Akademik;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Load_Fakta_Akademik
AS
BEGIN
    SET NOCOUNT ON;

    -- Langsung masukkan data karena ID di Staging sudah valid (hasil dari generator SQL)
    INSERT INTO dbo.Fakta_Akademik (
        ID_Mahasiswa, 
        ID_MK, 
        ID_Dosen, 
        ID_Waktu, 
        Jumlah_SKS_Diambil, 
        Bobot_Nilai, 
        Status_Lulus
    )
    SELECT 
        s.ID_Mahasiswa, -- Sudah berupa ID (Angka)
        s.ID_MK,        -- Sudah berupa ID (Angka)
        s.ID_Dosen,     -- Sudah berupa ID (Angka)
        s.ID_Waktu,     -- Sudah berupa ID (YYYYMMDD)
        s.Jumlah_SKS_Diambil,
        s.Bobot_Nilai,
        s.Status_Lulus
    FROM stg.Fakta_Akademik s;
    
    PRINT 'Load Fakta Akademik Selesai (10.000 Baris).';
END;
GO
