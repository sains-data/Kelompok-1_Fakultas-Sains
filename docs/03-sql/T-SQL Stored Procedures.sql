USE DM_FakultasSains_DW;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Load_Dim_Prodi
AS
BEGIN
    -- Setting standar agar lebih cepat dan aman
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        -- Mulai Transaksi (Biar kalau error, data balik seperti semula)
        BEGIN TRANSACTION;

        -- 1. UPDATE DATA LAMA (SCD Tipe 1)
        -- Jika Kode Prodi sudah ada tapi Namanya berubah, kita update namanya.
        UPDATE T
        SET T.Nama_Prodi = S.Nama_Prodi
        FROM dbo.Dim_Prodi T
        INNER JOIN stg.Prodi S ON T.Kode_Prodi = S.Kode_Prodi
        WHERE T.Nama_Prodi <> S.Nama_Prodi; -- Hanya update jika ada beda

        -- 2. INSERT DATA BARU
        -- Masukkan data yang belum ada di Dimensi
        INSERT INTO dbo.Dim_Prodi (Kode_Prodi, Nama_Prodi)
        SELECT S.Kode_Prodi, S.Nama_Prodi
        FROM stg.Prodi S
        WHERE NOT EXISTS (
            SELECT 1 
            FROM dbo.Dim_Prodi T 
            WHERE T.Kode_Prodi = S.Kode_Prodi
        );

        -- Simpan perubahan permanen
        COMMIT TRANSACTION;
        PRINT '>> [SUCCESS] Load Dim_Prodi selesai.';
        
    END TRY
    BEGIN CATCH
        -- Jika ada error, batalkan semua perubahan
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        -- Tampilkan pesan error
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH;
END;
GO
