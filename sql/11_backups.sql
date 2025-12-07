-- =============================================================
-- SCRIPT STRATEGI BACKUP (FULL, DIFF, LOG)
-- Simpan file ini sebagai: 11_Backup.sql
-- =============================================================

USE master; -- Pindah ke master dulu biar aman
GO

-- Pastikan folder 'C:\Backups\' sudah dibuat manual di Windows Explorer!

-- =============================================================
-- 1. FULL BACKUP (Ibarat: Save Game Utama)
-- Dilakukan: Mingguan (Setiap Minggu jam 02:00)
-- =============================================================
BACKUP DATABASE [DM_FakultasSains_DW]
TO DISK = N'D:\datadw\Backups\DM_FakultasSains_DW_Full.bak'
WITH
    FORMAT, -- Menimpa file lama (Overwrite)
    COMPRESSION, -- Biar file hemat size
    NAME = N'Full Database Backup for Fakultas Sains',
    STATS = 10; -- Tampilkan progress per 10%
GO

-- =============================================================
-- 2. DIFFERENTIAL BACKUP (Ibarat: Save Perubahan sejak Full)
-- Dilakukan: Harian (Setiap Hari jam 02:00)
-- =============================================================
BACKUP DATABASE [DM_FakultasSains_DW]
TO DISK = N'D:\datadw\Backups\DM_FakultasSains_DW_Full.bak'
WITH
    DIFFERENTIAL, -- Ini kuncinya! Cuma simpan yg berubah aja
    COMPRESSION,
    NAME = N'Differential Database Backup',
    STATS = 10;
GO

-- =============================================================
-- 3. TRANSACTION LOG BACKUP (Ibarat: Save Detik-per-detik)
-- Dilakukan: Setiap 6 Jam
-- =============================================================
-- (Pastikan Recovery Model database kamu FULL agar ini jalan)
ALTER DATABASE [DM_FakultasSains_DW] SET RECOVERY FULL;
GO

BACKUP LOG [DM_FakultasSains_DW]
TO DISK = N'D:\datadw\Backups\DM_FakultasSains_DW_Log.trn'
WITH
    COMPRESSION,
    NAME = N'Transaction Log Backup',
    STATS = 10;
GO

-- =============================================================
-- 4. AZURE BLOB STORAGE (OPTIONAL - SIMULASI)
-- Karena ini localhost dan tidak ada akun Azure, bagian ini 
-- didokumentasikan sebagai 'Rencana Implementasi Cloud'.
-- =============================================================
/*
-- Script ini akan dijalankan jika Azure Storage Account tersedia:
BACKUP DATABASE [DM_FakultasSains_DW]
TO URL = N'https://storageaccount.blob.core.windows.net/backups/DM_FakultasSains_DW.bak'
WITH CREDENTIAL = 'AzureStorageCredential', COMPRESSION;
*/
GO

--  MEMUNCULKAN FILE .DIFF
BACKUP DATABASE [DM_FakultasSains_DW]
TO DISK = N'D:\datadw\Backups\DM_FakultasSains_DW_Diff.bak'
WITH
    DIFFERENTIAL, -- Kuncinya di sini
    COMPRESSION,
    NAME = N'Differential Database Backup',
    STATS = 10;
GO