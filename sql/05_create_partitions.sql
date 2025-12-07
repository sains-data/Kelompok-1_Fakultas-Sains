USE DM_FakultasSains_DW;
GO

-- ==================================================
-- 1. BERSIHKAN PENGHALANG (DROP INDEX DULU)
-- ==================================================
-- Kita hapus Columnstore Index agar tabel bisa di-partisi
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'NCCIX_Fakta_Akademik')
    DROP INDEX NCCIX_Fakta_Akademik ON dbo.Fakta_Akademik;

IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'NCCIX_Fakta_Publikasi')
    DROP INDEX NCCIX_Fakta_Publikasi ON dbo.Fakta_Publikasi;

-- Kita hapus index partisi lama jika ada
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'CIX_Fakta_Akademik_Partitioned')
    DROP INDEX CIX_Fakta_Akademik_Partitioned ON dbo.Fakta_Akademik;
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'CIX_Fakta_Publikasi_Partitioned')
    DROP INDEX CIX_Fakta_Publikasi_Partitioned ON dbo.Fakta_Publikasi;

-- Kita reset Skema Partisi
IF EXISTS (SELECT * FROM sys.partition_schemes WHERE name = 'PS_Tahun')
    DROP PARTITION SCHEME PS_Tahun;
IF EXISTS (SELECT * FROM sys.partition_functions WHERE name = 'PF_Tahun')
    DROP PARTITION FUNCTION PF_Tahun;
GO

-- ==================================================
-- 2. BUAT ULANG PARTISI (PF & PS)
-- ==================================================
CREATE PARTITION FUNCTION PF_Tahun (INT)
AS RANGE RIGHT FOR VALUES 
(
    20210101, 
    20220101, 
    20230101, 
    20240101, 
    20250101
);
GO

CREATE PARTITION SCHEME PS_Tahun
AS PARTITION PF_Tahun
ALL TO ([PRIMARY]);
GO

-- ==================================================
-- 3. TERAPKAN PARTISI KE TABEL FAKTA
-- ==================================================

-- A. FAKTA AKADEMIK
--------------------
-- Lepas PK lama
DECLARE @PKName1 VARCHAR(255);
SELECT @PKName1 = name FROM sys.key_constraints WHERE parent_object_id = OBJECT_ID('dbo.Fakta_Akademik');
IF @PKName1 IS NOT NULL
    EXEC('ALTER TABLE dbo.Fakta_Akademik DROP CONSTRAINT ' + @PKName1);
GO

-- Terapkan Partisi
CREATE CLUSTERED INDEX CIX_Fakta_Akademik_Partitioned
ON dbo.Fakta_Akademik (ID_Waktu, ID_Fakta_Akademik)
ON PS_Tahun (ID_Waktu); 
GO

-- Pasang PK Lagi (Non-Clustered)
ALTER TABLE dbo.Fakta_Akademik
ADD CONSTRAINT PK_Fakta_Akademik_New PRIMARY KEY NONCLUSTERED (ID_Fakta_Akademik);
GO

-- B. FAKTA PUBLIKASI
---------------------
-- Lepas PK lama
DECLARE @PKName2 VARCHAR(255);
SELECT @PKName2 = name FROM sys.key_constraints WHERE parent_object_id = OBJECT_ID('dbo.Fakta_Publikasi');
IF @PKName2 IS NOT NULL
    EXEC('ALTER TABLE dbo.Fakta_Publikasi DROP CONSTRAINT ' + @PKName2);
GO

-- Terapkan Partisi
CREATE CLUSTERED INDEX CIX_Fakta_Publikasi_Partitioned
ON dbo.Fakta_Publikasi (ID_Waktu, ID_Fakta_Publikasi)
ON PS_Tahun (ID_Waktu); 
GO

-- Pasang PK Lagi (Non-Clustered)
ALTER TABLE dbo.Fakta_Publikasi
ADD CONSTRAINT PK_Fakta_Publikasi_New PRIMARY KEY NONCLUSTERED (ID_Fakta_Publikasi);
GO

-- ==================================================
-- 4. PASANG KEMBALI COLUMNSTORE INDEX (ALIGNED)
-- ==================================================
-- Sekarang kita pasang lagi karpetnya, tapi disesuaikan dengan partisi (ON PS_Tahun)

CREATE NONCLUSTERED COLUMNSTORE INDEX NCCIX_Fakta_Akademik
ON dbo.Fakta_Akademik (ID_Mahasiswa, ID_MK, ID_Dosen, ID_Waktu, Jumlah_SKS_Diambil, Bobot_Nilai)
ON PS_Tahun (ID_Waktu); -- <-- Penting! Harus ikut partisi
GO

CREATE NONCLUSTERED COLUMNSTORE INDEX NCCIX_Fakta_Publikasi
ON dbo.Fakta_Publikasi (ID_Dosen, ID_Jurnal, ID_Waktu, Jumlah_Sitasi, Jumlah_Publikasi)
ON PS_Tahun (ID_Waktu); -- <-- Penting! Harus ikut partisi
GO

USE DM_FakultasSains_DW;
GO

-- ==================================================
-- PERBAIKAN PRIMARY KEY AGAR SESUAI PARTISI
-- ==================================================

-- A. FAKTA AKADEMIK
--------------------
-- Pastikan tidak ada sisa constraint error
IF EXISTS (SELECT * FROM sys.key_constraints WHERE name = 'PK_Fakta_Akademik_New')
    ALTER TABLE dbo.Fakta_Akademik DROP CONSTRAINT PK_Fakta_Akademik_New;

-- Buat PK Gabungan (ID_Fakta + ID_Waktu) agar lolos aturan partisi
ALTER TABLE dbo.Fakta_Akademik
ADD CONSTRAINT PK_Fakta_Akademik_New 
PRIMARY KEY NONCLUSTERED (ID_Fakta_Akademik, ID_Waktu) 
ON PS_Tahun (ID_Waktu);
GO


-- B. FAKTA PUBLIKASI
---------------------
-- Pastikan tidak ada sisa constraint error
IF EXISTS (SELECT * FROM sys.key_constraints WHERE name = 'PK_Fakta_Publikasi_New')
    ALTER TABLE dbo.Fakta_Publikasi DROP CONSTRAINT PK_Fakta_Publikasi_New;

-- Buat PK Gabungan
ALTER TABLE dbo.Fakta_Publikasi
ADD CONSTRAINT PK_Fakta_Publikasi_New 
PRIMARY KEY NONCLUSTERED (ID_Fakta_Publikasi, ID_Waktu) 
ON PS_Tahun (ID_Waktu);
GO

-- ==================================================
-- C. PASANG COLUMNSTORE INDEX TERAKHIR
-- ==================================================
-- Hapus dulu kalau ada sisa error
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'NCCIX_Fakta_Akademik')
    DROP INDEX NCCIX_Fakta_Akademik ON dbo.Fakta_Akademik;
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'NCCIX_Fakta_Publikasi')
    DROP INDEX NCCIX_Fakta_Publikasi ON dbo.Fakta_Publikasi;

-- Pasang Columnstore
CREATE NONCLUSTERED COLUMNSTORE INDEX NCCIX_Fakta_Akademik
ON dbo.Fakta_Akademik (ID_Mahasiswa, ID_MK, ID_Dosen, ID_Waktu, Jumlah_SKS_Diambil, Bobot_Nilai)
ON PS_Tahun (ID_Waktu);

CREATE NONCLUSTERED COLUMNSTORE INDEX NCCIX_Fakta_Publikasi
ON dbo.Fakta_Publikasi (ID_Dosen, ID_Jurnal, ID_Waktu, Jumlah_Sitasi, Jumlah_Publikasi)
ON PS_Tahun (ID_Waktu);
GO
