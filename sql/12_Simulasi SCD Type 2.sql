USE DM_FakultasSains_DW;
GO

-- 1. DEKLARASI TARGET (NIP Tono)
DECLARE @NIP_Target VARCHAR(50) = '197938053098997328'; 

-- 2. EKSEKUSI INSERT YANG BENAR (Menyertakan ID_Prodi)
INSERT INTO dbo.Dim_Dosen (
    NIP_Dosen, 
    Nama_Dosen, 
    Jabatan_Fungsional, 
    ID_Prodi,          -- <--- TAMBAHAN PENTING (Biar gak error NULL)
    StartDate, 
    EndDate, 
    IsCurrent
)
SELECT 
    NIP_Dosen, 
    Nama_Dosen, 
    'Asisten Ahli',    -- Jabatan Baru
    ID_Prodi,          -- <--- AMBIL ID_PRODI DARI DATA LAMA
    GETDATE(),         -- StartDate Hari Ini
    NULL,              -- EndDate NULL
    1                  -- IsCurrent 1 (Aktif)
FROM dbo.Dim_Dosen 
WHERE NIP_Dosen = @NIP_Target 
  AND IsCurrent = 0 
  AND EndDate >= CAST(GETDATE() AS DATE); -- Ambil dari baris history yang baru dibuat

-- 3. CEK HASILNYA
PRINT 'SCD Type 2 Sukses! Cek hasilnya:';
SELECT * FROM dbo.Dim_Dosen WHERE NIP_Dosen = @NIP_Target;

UPDATE dbo.Dim_Dosen SET Nama_Prodi = 'Sains Data' WHERE Nama_Prodi IS NULL;

USE DM_FakultasSains_DW;
GO

USE DM_FakultasSains_DW;
GO

-- 1. CARI ID LAMA DAN BARU
DECLARE @ID_Lama INT;
DECLARE @ID_Baru INT;

-- Ambil ID Tono yang "Proses" (Lama)
SELECT TOP 1 @ID_Lama = ID_Dosen 
FROM dbo.Dim_Dosen 
WHERE NIP_Dosen = '197938053098997328' AND IsCurrent = 0;

-- Ambil ID Tono yang "Asisten Ahli" (Baru)
SELECT TOP 1 @ID_Baru = ID_Dosen 
FROM dbo.Dim_Dosen 
WHERE NIP_Dosen = '197938053098997328' AND IsCurrent = 1;

PRINT 'ID Lama: ' + CAST(@ID_Lama AS VARCHAR);
PRINT 'ID Baru: ' + CAST(@ID_Baru AS VARCHAR);

-- 2. PINDAHKAN SATU PUBLIKASI KE ID BARU
-- (Kita ambil 1 paper sembarang milik ID Lama, lalu kasih ke ID Baru)
UPDATE TOP (1) dbo.Fakta_Publikasi
SET ID_Dosen = @ID_Baru
WHERE ID_Dosen = @ID_Lama;

PRINT 'Sukses! Satu paper telah dipindahkan ke jabatan baru.';


-- Cek Riwayat Jabatan Tono Mahendra
SELECT 
    ID_Dosen, 
    NIP_Dosen, 
    Nama_Dosen, 
    Jabatan_Fungsional, 
    Nama_Prodi,
    StartDate, 
    EndDate, 
    IsCurrent
FROM dbo.Dim_Dosen
WHERE NIP_Dosen = '197938053098997328' -- NIP Tono yang tadi kita update
ORDER BY ID_Dosen ASC; 