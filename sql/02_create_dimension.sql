USE DM_FakultasSains_DW;
GO

-- ==================================================
-- 1. Dim_Prodi (Induk Utama)
-- ==================================================
CREATE TABLE dbo.Dim_Prodi (
    ID_Prodi INT IDENTITY(1,1) PRIMARY KEY,
    Kode_Prodi VARCHAR(10) NOT NULL,
    Nama_Prodi VARCHAR(100) NOT NULL
);
GO

-- ==================================================
-- 2. Dim_Waktu (Dimensi Waktu)
-- ==================================================
CREATE TABLE dbo.Dim_Waktu (
    ID_Waktu INT PRIMARY KEY, 
    Tanggal DATE NOT NULL,
    Tahun SMALLINT NOT NULL,
    Bulan_Angka TINYINT NOT NULL,
    Nama_Bulan VARCHAR(15) NOT NULL,
    Tahun_Ajaran VARCHAR(9) NOT NULL,
    Semester VARCHAR(10) NOT NULL
);
GO

-- ==================================================
-- 3. Dim_Jurnal (Referensi Publikasi)
-- ==================================================
CREATE TABLE dbo.Dim_Jurnal (
    ID_Jurnal INT IDENTITY(1,1) PRIMARY KEY,
    Kode_Jurnal VARCHAR(20),
    Nama_Jurnal VARCHAR(150),
    Penerbit VARCHAR(100)
);
GO

-- ==================================================
-- 4. Dim_MataKuliah (Anak dari Prodi)
-- ==================================================
CREATE TABLE dbo.Dim_MataKuliah (
    ID_MK INT IDENTITY(1,1) PRIMARY KEY,
    Kode_MK VARCHAR(20) NOT NULL,
    Nama_MK VARCHAR(100) NOT NULL,
    SKS TINYINT NOT NULL,
    Nama_Prodi VARCHAR(100), 
    
    -- Foreign Key ke Dim_Prodi
    ID_Prodi INT NOT NULL,
    CONSTRAINT FK_Dim_MK_Prodi FOREIGN KEY (ID_Prodi) 
        REFERENCES dbo.Dim_Prodi(ID_Prodi)
);
GO

-- ==================================================
-- 5. Dim_Mahasiswa (SCD Type 2 + Anak dari Prodi)
-- ==================================================
CREATE TABLE dbo.Dim_Mahasiswa (
    ID_Mahasiswa INT IDENTITY(1,1) PRIMARY KEY,
    NIM VARCHAR(20) NOT NULL,
    Nama_Mahasiswa VARCHAR(100) NOT NULL,
    Status VARCHAR(50),
    Nama_Prodi VARCHAR(100), 
    
    -- Atribut SCD Type 2 
    StartDate DATETIME NOT NULL DEFAULT GETDATE(),
    EndDate DATETIME NULL,
    IsCurrent BIT NOT NULL DEFAULT 1,
    
    -- Foreign Key ke Dim_Prodi
    ID_Prodi INT NOT NULL,
    CONSTRAINT FK_Dim_Mahasiswa_Prodi FOREIGN KEY (ID_Prodi) 
        REFERENCES dbo.Dim_Prodi(ID_Prodi)
);
GO

-- ==================================================
-- 6. Dim_Dosen (SCD Type 2 + Anak dari Prodi)
-- ==================================================
CREATE TABLE dbo.Dim_Dosen (
    ID_Dosen INT IDENTITY(1,1) PRIMARY KEY,
    NIP_Dosen VARCHAR(20) NOT NULL,
    Nama_Dosen VARCHAR(100) NOT NULL,
    Jabatan_Fungsional VARCHAR(50),
    Nama_Prodi VARCHAR(100), 
    
    -- Atribut SCD Type 2 
    StartDate DATETIME NOT NULL DEFAULT GETDATE(),
    EndDate DATETIME NULL,
    IsCurrent BIT NOT NULL DEFAULT 1,

    -- Foreign Key ke Dim_Prodi
    ID_Prodi INT NOT NULL,
    CONSTRAINT FK_Dim_Dosen_Prodi FOREIGN KEY (ID_Prodi) 
        REFERENCES dbo.Dim_Prodi(ID_Prodi)
);
GO
