
USE DM_FakultasSains_DW;
GO

-- ==================================================
-- A. INDEX UNTUK TABEL DIMENSI (Optimasi ETL Lookup)
-- ==================================================
-- Mempercepat pencarian berdasarkan Kunci Bisnis (NIM, NIP, Kode) saat SSIS berjalan.

-- 1. Dim_Mahasiswa (Index pada NIM)
CREATE NONCLUSTERED INDEX IX_Dim_Mahasiswa_NIM 
ON dbo.Dim_Mahasiswa (NIM);
GO

-- 2. Dim_Dosen (Index pada NIP)
CREATE NONCLUSTERED INDEX IX_Dim_Dosen_NIP 
ON dbo.Dim_Dosen (NIP_Dosen);
GO

-- 3. Dim_MataKuliah (Index pada Kode_MK)
CREATE NONCLUSTERED INDEX IX_Dim_MataKuliah_Kode 
ON dbo.Dim_MataKuliah (Kode_MK);
GO

-- 4. Dim_Prodi (Index pada Kode_Prodi)
CREATE NONCLUSTERED INDEX IX_Dim_Prodi_Kode 
ON dbo.Dim_Prodi (Kode_Prodi);
GO

-- ==================================================
-- B. INDEX UNTUK TABEL FAKTA (Optimasi JOIN)
-- ==================================================
-- Mempercepat query saat menghubungkan Fakta ke Dimensi (Foreign Keys).

-- 1. Fakta_Akademik
CREATE NONCLUSTERED INDEX IX_FaktaAkademik_Mahasiswa 
ON dbo.Fakta_Akademik (ID_Mahasiswa);

CREATE NONCLUSTERED INDEX IX_FaktaAkademik_Dosen 
ON dbo.Fakta_Akademik (ID_Dosen);

CREATE NONCLUSTERED INDEX IX_FaktaAkademik_MK 
ON dbo.Fakta_Akademik (ID_MK);

CREATE NONCLUSTERED INDEX IX_FaktaAkademik_Waktu 
ON dbo.Fakta_Akademik (ID_Waktu);
GO

-- 2. Fakta_Publikasi
CREATE NONCLUSTERED INDEX IX_FaktaPublikasi_Dosen 
ON dbo.Fakta_Publikasi (ID_Dosen);

CREATE NONCLUSTERED INDEX IX_FaktaPublikasi_Jurnal 
ON dbo.Fakta_Publikasi (ID_Jurnal);

CREATE NONCLUSTERED INDEX IX_FaktaPublikasi_Waktu 
ON dbo.Fakta_Publikasi (ID_Waktu);
GO

-- ==================================================
-- C. COLUMNSTORE INDEX (Optimasi Analitik/Reporting)
-- ==================================================
-- Sangat disarankan untuk Tabel Fakta guna mempercepat perhitungan (SUM, AVG, COUNT).

-- 1. Columnstore untuk Fakta Akademik
CREATE NONCLUSTERED COLUMNSTORE INDEX NCCIX_Fakta_Akademik
ON dbo.Fakta_Akademik
(
    ID_Mahasiswa, 
    ID_MK, 
    ID_Dosen, 
    ID_Waktu, 
    Jumlah_SKS_Diambil, 
    Bobot_Nilai
);
GO

-- 2. Columnstore untuk Fakta Publikasi
CREATE NONCLUSTERED COLUMNSTORE INDEX NCCIX_Fakta_Publikasi
ON dbo.Fakta_Publikasi
(
    ID_Dosen, 
    ID_Jurnal, 
    ID_Waktu, 
    Jumlah_Sitasi, 
    Jumlah_Publikasi
);
GO

PRINT '>> Indexing Strategy berhasil diterapkan.';
