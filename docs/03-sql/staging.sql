USE DM_FakultasSains_DW;
GO

-- 1. Pastikan Schema 'stg' ada
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'stg')
BEGIN
    EXEC('CREATE SCHEMA stg')
END
GO

-- ==================================================
-- 2. CREATE TABEL STAGING (Tempat Data Mentah)
-- ==================================================

-- Staging Prodi (Induk)
CREATE TABLE stg.Prodi (
    Kode_Prodi VARCHAR(255),
    Nama_Prodi VARCHAR(255)
);
GO

-- Staging Mahasiswa
CREATE TABLE stg.Mahasiswa (
    NIM VARCHAR(255),
    Nama_Mahasiswa VARCHAR(255),
    Status VARCHAR(255),
    ID_Prodi VARCHAR(255), -- Masih VARCHAR biar aman saat import
    Nama_Prodi VARCHAR(255),
    StartDate DATE,        -- Langsung DATE biar SSIS enak
    EndDate DATE,          -- Langsung DATE biar SSIS enak
    IsCurrent VARCHAR(255)
);
GO

-- Staging Dosen
CREATE TABLE stg.Dosen (
    NIP_Dosen VARCHAR(255),
    Nama_Dosen VARCHAR(255),
    Jabatan_Fungsional VARCHAR(255),
    ID_Prodi VARCHAR(255),
    Nama_Prodi VARCHAR(255),
    StartDate DATE,
    EndDate DATE,
    IsCurrent VARCHAR(255)
);
GO

-- Staging Mata Kuliah
CREATE TABLE stg.MataKuliah (
    Kode_MK VARCHAR(255),
    Nama_MK VARCHAR(255),
    SKS VARCHAR(255),
    ID_Prodi VARCHAR(255),
    Nama_Prodi VARCHAR(255)
);
GO

-- Staging Jurnal
CREATE TABLE stg.Jurnal (
    Kode_Jurnal VARCHAR(255),
    Nama_Jurnal VARCHAR(255),
    Penerbit VARCHAR(255)
);
GO

-- Staging Fakta Akademik (Nilai)
CREATE TABLE stg.Fakta_Akademik (
    ID_Mahasiswa VARCHAR(255), 
    ID_MK VARCHAR(255),
    ID_Dosen VARCHAR(255),
    ID_Waktu VARCHAR(255),
    Jumlah_SKS_Diambil VARCHAR(255),
    Bobot_Nilai VARCHAR(255),
    Status_Lulus VARCHAR(255)
);
GO

-- Staging Fakta Publikasi
CREATE TABLE stg.Fakta_Publikasi (
    ID_Dosen VARCHAR(255),
    ID_Jurnal VARCHAR(255),
    ID_Waktu VARCHAR(255),
    Jumlah_Sitasi VARCHAR(255),
    Jumlah_Publikasi VARCHAR(255)
);
GO
