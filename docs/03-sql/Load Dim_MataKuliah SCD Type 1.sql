CREATE OR ALTER PROCEDURE dbo.usp_Load_Dim_MataKuliah
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- 1. UPDATE (Jika data sudah ada tapi berubah)
        UPDATE d
        SET 
            d.Nama_MK = UPPER(s.Nama_MK), -- Update Nama
            d.SKS = CAST(s.SKS AS TINYINT),
            d.ID_Prodi = p.ID_Prodi       -- Update Prodi jika berubah
        FROM dbo.Dim_MataKuliah d
        INNER JOIN stg.MataKuliah s ON d.Kode_MK = s.Kode_MK -- Business Key
        INNER JOIN dbo.Dim_Prodi p ON s.Nama_Prodi = p.Nama_Prodi
        WHERE 
            d.Nama_MK <> UPPER(s.Nama_MK) OR 
            d.SKS <> CAST(s.SKS AS TINYINT) OR
            d.ID_Prodi <> p.ID_Prodi;

        -- 2. INSERT (Jika Mata Kuliah belum ada)
        INSERT INTO dbo.Dim_MataKuliah (
            Kode_MK, Nama_MK, SKS, Nama_Prodi, ID_Prodi
        )
        SELECT 
            s.Kode_MK,
            UPPER(s.Nama_MK),
            CAST(s.SKS AS TINYINT),
            s.Nama_Prodi,
            p.ID_Prodi
        FROM stg.MataKuliah s
        INNER JOIN dbo.Dim_Prodi p ON s.Nama_Prodi = p.Nama_Prodi
        WHERE NOT EXISTS (
            SELECT 1 FROM dbo.Dim_MataKuliah d WHERE d.Kode_MK = s.Kode_MK
        );

        COMMIT TRANSACTION;
        PRINT '>> [SUCCESS] Load Dim_MataKuliah (SCD Type 1) selesai.';

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO
