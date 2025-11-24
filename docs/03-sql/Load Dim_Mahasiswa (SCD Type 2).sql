-- Stored Procedure: Load Dim_Mahasiswa (SCD Type 2)
CREATE PROCEDURE dbo.usp_Load_Dim_Mahasiswa
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Expire old records (mematikan/menutup baris lama yang berubah)
    UPDATE d
    SET
        EndDate = GETDATE(),
        IsCurrent = 0
    FROM dbo.Dim_Mahasiswa d
    INNER JOIN stg.Mahasiswa s ON d.NIM = s.NIM -- Gabung berdasarkan Business Key (NIM)
    INNER JOIN dbo.Dim_Prodi p ON s.ID_Prodi = p.Kode_Prodi -- Gabung untuk mendapatkan ID_Prodi
    WHERE d.IsCurrent = 1
    AND (
        -- Kondisi: Perubahan pada atribut yang dilacak (tracked attributes)
        d.Nama_Mahasiswa <> UPPER(s.Nama_Mahasiswa) OR -- Transformasi UPPER()
        d.Status <> s.Status OR
        d.ID_Prodi <> p.ID_Prodi
    );

    -- 2. Insert new records (mahasiswa baru atau baris baru untuk perubahan)
    INSERT INTO dbo.Dim_Mahasiswa (
        NIM, Nama_Mahasiswa, Status, Nama_Prodi,
        StartDate, EndDate, IsCurrent, ID_Prodi
    )
    SELECT
        s.NIM,
        UPPER(s.Nama_Mahasiswa), -- Transformasi UPPER()
        s.Status,
        s.Nama_Prodi,
        GETDATE(), -- StartDate diisi dengan tanggal hari ini saat dimuat
        NULL,
        1,
        p.ID_Prodi
    FROM stg.Mahasiswa s
    INNER JOIN dbo.Dim_Prodi p ON s.ID_Prodi = p.Kode_Prodi -- Ambil Surrogate Key dari Dim_Prodi
    WHERE NOT EXISTS (
        -- HANYA masukkan jika:
        -- a) NIM baru (tidak ada di Dim_Mahasiswa) ATAU
        -- b) NIM sudah ada tetapi baris terakhir (IsCurrent=1) sudah di-Expire pada langkah 1
        SELECT 1
        FROM dbo.Dim_Mahasiswa d
        WHERE d.NIM = s.NIM AND d.IsCurrent = 1
    );

END;
GO
