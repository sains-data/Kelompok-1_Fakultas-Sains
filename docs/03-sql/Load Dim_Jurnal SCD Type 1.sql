CREATE OR ALTER PROCEDURE dbo.usp_Load_Dim_Jurnal
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- 1. UPDATE (Jika ada perubahan nama jurnal/penerbit)
        UPDATE d
        SET 
            d.Nama_Jurnal = UPPER(s.Nama_Jurnal),
            d.Penerbit = s.Penerbit
        FROM dbo.Dim_Jurnal d
        INNER JOIN stg.Jurnal s ON d.Kode_Jurnal = s.Kode_Jurnal
        WHERE 
            d.Nama_Jurnal <> UPPER(s.Nama_Jurnal) OR 
            d.Penerbit <> s.Penerbit;

        -- 2. INSERT (Jurnal Baru)
        INSERT INTO dbo.Dim_Jurnal (
            Kode_Jurnal, Nama_Jurnal, Penerbit
        )
        SELECT 
            s.Kode_Jurnal,
            UPPER(s.Nama_Jurnal),
            s.Penerbit
        FROM stg.Jurnal s
        WHERE NOT EXISTS (
            SELECT 1 FROM dbo.Dim_Jurnal d WHERE d.Kode_Jurnal = s.Kode_Jurnal
        );

        COMMIT TRANSACTION;
        PRINT '>> [SUCCESS] Load Dim_Jurnal (SCD Type 1) selesai.';

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO
