 USE DM_FakultasSains_DW; 
GO

-- Membuat Role untuk berbagai level manajemen
CREATE ROLE db_executive;    -- Untuk Dekan/Wakil Dekan
CREATE ROLE db_analyst;      -- Untuk Kaprodi & Tim Mutu
CREATE ROLE db_viewer;       -- Untuk Staf Admin & Dosen Umum
CREATE ROLE db_etl_operator; -- Untuk Sistem Backend
GO

-- Memberikan Hak Akses (Grant Permissions)
-- Executive: Full Read & Unmask
GRANT SELECT ON SCHEMA::dbo TO db_executive;
GRANT UNMASK TO db_executive;

-- Analyst: Read DBO & Full Control Staging
GRANT SELECT ON SCHEMA::dbo TO db_analyst;
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::stg TO db_analyst;
GRANT UNMASK TO db_analyst;

-- Viewer: Restricted Access (Hanya View Dashboard)
GRANT SELECT ON dbo.vw_Student_Performance TO db_viewer;
GRANT SELECT ON dbo.vw_Course_Failure_Analysis TO db_viewer;
GRANT SELECT ON dbo.vw_Dosen_Productivity TO db_viewer;
-- (Viewer tidak diberikan hak UNMASK)
GO
-- Membuat Login Server
CREATE LOGIN dekan_user WITH PASSWORD = 'StrongP@ssw0rd!';
CREATE LOGIN kaprodi_user WITH PASSWORD = 'StrongP@ssw0rd!';
CREATE LOGIN staff_user WITH PASSWORD = 'StrongP@ssw0rd!';

-- Mapping User ke Database & Role
CREATE USER dekan_user FOR LOGIN dekan_user;
ALTER ROLE db_executive ADD MEMBER dekan_user;

CREATE USER kaprodi_user FOR LOGIN kaprodi_user;
ALTER ROLE db_analyst ADD MEMBER kaprodi_user;

CREATE USER staff_user FOR LOGIN staff_user;
ALTER ROLE db_viewer ADD MEMBER staff_user;
GO
USE DM_FakultasSains_DW;
GO

-- Cek apakah kolom sudah ada, kalau belum, tambahkan
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.Dim_Mahasiswa') AND name = 'Email_Pribadi')
BEGIN
    ALTER TABLE dbo.Dim_Mahasiswa ADD Email_Pribadi VARCHAR(100);
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.Dim_Mahasiswa') AND name = 'No_HP')
BEGIN
    ALTER TABLE dbo.Dim_Mahasiswa ADD No_HP VARCHAR(20);
END
GO

UPDATE dbo.Dim_Mahasiswa 
SET Email_Pribadi = CONCAT(CAST(NIM AS VARCHAR(20)), '@student.sains.ac.id'),
    No_HP = '0812-XXXX-' + RIGHT(CAST(NIM AS VARCHAR(20)), 4)
WHERE Email_Pribadi IS NULL; -- Cuma isi yang masih kosong
GO

SELECT TOP 10 * FROM dbo.Dim_Mahasiswa;

-- Pasang Sensor Email (Masking)
ALTER TABLE dbo.Dim_Mahasiswa
ALTER COLUMN Email_Pribadi ADD MASKED WITH (FUNCTION = 'email()');

-- Pasang Sensor HP (Masking)
ALTER TABLE dbo.Dim_Mahasiswa
ALTER COLUMN No_HP ADD MASKED WITH (FUNCTION = 'partial(0,"XXX-XXX-",4)');
GO

USE DM_FakultasSains_DW; -- Pastikan nama database benar
GO

-- =============================================
-- 1. MEMBUAT TABEL LOG (AUDIT TRAIL)
-- =============================================
IF OBJECT_ID('dbo.AuditLog_System', 'U') IS NOT NULL
    DROP TABLE dbo.AuditLog_System; -- Hapus dulu kalau sudah ada biar ga error
GO

CREATE TABLE dbo.AuditLog_System (
    AuditID BIGINT IDENTITY(1,1) PRIMARY KEY,
    WaktuKejadian DATETIME2 DEFAULT SYSDATETIME(),
    SiapaPelaku NVARCHAR(128) DEFAULT SUSER_SNAME(), 
    Aksi NVARCHAR(50), -- INSERT, UPDATE, atau DELETE
    NamaTabel NVARCHAR(128),
    BarisTerdampak INT
);
GO -- <--- PENTING: GO ini memisahkan batch

-- =============================================
-- 2. MEMBUAT TRIGGER (CCTV)
-- =============================================
CREATE OR ALTER TRIGGER trg_Audit_Nilai
ON dbo.Fakta_Akademik
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Deklarasi variabel (Penting biar ga error Msg 137)
    DECLARE @Aksi NVARCHAR(50);

    -- Logika menentukan jenis aktivitas
    IF EXISTS(SELECT * FROM inserted) AND EXISTS(SELECT * FROM deleted)
        SET @Aksi = 'UPDATE'; -- Ada data baru & lama = Edit
    ELSE IF EXISTS(SELECT * FROM inserted)
        SET @Aksi = 'INSERT'; -- Cuma ada data baru = Input
    ELSE IF EXISTS(SELECT * FROM deleted)
        SET @Aksi = 'DELETE'; -- Cuma ada data lama = Hapus

    -- Masukkan ke tabel log
    INSERT INTO dbo.AuditLog_System (Aksi, NamaTabel, BarisTerdampak)
    VALUES (@Aksi, 'Fakta_Akademik', @@ROWCOUNT);
END;
GO

