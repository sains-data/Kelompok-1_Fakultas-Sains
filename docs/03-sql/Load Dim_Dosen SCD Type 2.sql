USE DM_FakultasSains_DW;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Load_Dim_Dosen
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- 1. EXPIRE OLD RECORDS (Tutup masa berlaku data lama jika ada perubahan)
        UPDATE d
        SET 
            EndDate = GETDATE(),
            IsCurrent = 0
        FROM dbo.Dim_Dosen d
        INNER JOIN stg.Dosen s ON d.NIP_Dosen = s.NIP_Dosen -- Business Key
        -- Lookup ke Dim_Prodi untuk cek apakah Prodi Dosen berubah
        INNER JOIN dbo.Dim_Prodi p ON s.Nama_Prodi = p.Nama_Prodi 
        WHERE d.IsCurrent = 1
        AND (
            d.Nama_Dosen <> UPPER(s.Nama_Dosen) OR 
            d.Jabatan_Fungsional <> s.Jabatan_Fungsional OR
            d.ID_Prodi <> p.ID_Prodi -- Cek jika pindah prodi
        );

        -- 2. INSERT NEW RECORDS (Dosen baru atau perubahan data)
        INSERT INTO dbo.Dim_Dosen (
            NIP_Dosen, Nama_Dosen, Jabatan_Fungsional, Nama_Prodi,
            ID_Prodi, StartDate, EndDate, IsCurrent
        )
        SELECT 
            s.NIP_Dosen,
            UPPER(s.Nama_Dosen), -- Transformasi UPPER
            s.Jabatan_Fungsional,
            s.Nama_Prodi,
            p.ID_Prodi,          -- Ambil Surrogate Key dari Dim_Prodi
            GETDATE(),           -- StartDate hari ini
            NULL,
            1
        FROM stg.Dosen s
        -- Join ke Dim_Prodi untuk mendapatkan ID_Prodi yang benar
        INNER JOIN dbo.Dim_Prodi p ON s.Nama_Prodi = p.Nama_Prodi 
        WHERE NOT EXISTS (
            SELECT 1 
            FROM dbo.Dim_Dosen d 
            WHERE d.NIP_Dosen = s.NIP_Dosen AND d.IsCurrent = 1
        );

        COMMIT TRANSACTION;
        PRINT '>> [SUCCESS] Load Dim_Dosen (SCD Type 2) selesai.';

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW; -- Lempar error agar ketahuan
    END CATCH;
END;
GO
