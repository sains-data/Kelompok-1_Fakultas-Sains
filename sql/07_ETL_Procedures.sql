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

--Pembuktian
-- Jalankan Load Prodi Dulu
EXEC dbo.usp_Load_Dim_Prodi;

-- Baru Jalankan Load Mahasiswa (Karena butuh Prodi)
EXEC dbo.usp_Load_Dim_Mahasiswa;

-- Cek Hasilnya
SELECT * FROM dbo.Dim_Prodi;
SELECT * FROM dbo.Dim_Mahasiswa;

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
--scd type 1
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

USE DM_FakultasSains_DW;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Load_Fakta_Akademik
AS
BEGIN
    SET NOCOUNT ON;

    -- Masukkan data ke tabel fakta
    INSERT INTO dbo.Fakta_Akademik (
        ID_Mahasiswa, 
        ID_MK, 
        ID_Dosen, 
        ID_Waktu, 
        Jumlah_SKS_Diambil, 
        Bobot_Nilai, 
        Status_Lulus
    )
    SELECT 
        M.ID_Mahasiswa, -- Mengambil Surrogate Key dari Dimensi
        MK.ID_MK,       -- Mengambil Surrogate Key dari Dimensi
        D.ID_Dosen,     -- Mengambil Surrogate Key dari Dimensi
        CAST(S.ID_Waktu AS INT), 
        CAST(S.Jumlah_SKS_Diambil AS INT), 
        CAST(S.Bobot_Nilai AS DECIMAL(3,2)), 
        S.Status_Lulus
    FROM stg.Fakta_Akademik S
    
    -- 1. JOIN ke Dim_Mahasiswa (SCD Tipe 2: Ambil yang Aktif/IsCurrent=1)
    INNER JOIN dbo.Dim_Mahasiswa M 
        ON S.ID_Mahasiswa = M.NIM 
        AND M.IsCurrent = 1  -- [PENTING: Sesuai Modul Hal 22]

    -- 2. JOIN ke Dim_MataKuliah (SCD Tipe 1)
    INNER JOIN dbo.Dim_MataKuliah MK 
        ON S.ID_MK = MK.Kode_MK

    -- 3. JOIN ke Dim_Dosen (SCD Tipe 2: Ambil yang Aktif)
    INNER JOIN dbo.Dim_Dosen D 
        ON S.ID_Dosen = D.NIP_Dosen 
        AND D.IsCurrent = 1

    -- 4. JOIN ke Dim_Waktu (Pastikan ID_Waktu valid)
    INNER JOIN dbo.Dim_Waktu W
        ON CAST(S.ID_Waktu AS INT) = W.ID_Waktu;

    PRINT '>> [SUCCESS] Load Fakta_Akademik selesai.';
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Load_Fakta_Publikasi
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.Fakta_Publikasi (
        ID_Dosen, 
        ID_Jurnal, 
        ID_Waktu, 
        Jumlah_Sitasi, 
        Jumlah_Publikasi
    )
    SELECT 
        D.ID_Dosen, 
        J.ID_Jurnal, 
        CAST(S.ID_Waktu AS INT), 
        CAST(S.Jumlah_Sitasi AS INT), 
        CAST(S.Jumlah_Publikasi AS INT)
    FROM stg.Fakta_Publikasi S
    
    -- 1. JOIN ke Dim_Dosen (Ambil yang Aktif)
    INNER JOIN dbo.Dim_Dosen D 
        ON S.ID_Dosen = D.NIP_Dosen 
        AND D.IsCurrent = 1

    -- 2. JOIN ke Dim_Jurnal
    INNER JOIN dbo.Dim_Jurnal J 
        ON S.ID_Jurnal = J.Kode_Jurnal

    -- 3. JOIN ke Dim_Waktu
    INNER JOIN dbo.Dim_Waktu W
        ON CAST(S.ID_Waktu AS INT) = W.ID_Waktu;

    PRINT '>> [SUCCESS] Load Fakta_Publikasi selesai.';
END;
GO
CREATE OR ALTER PROCEDURE dbo.usp_Master_ETL
AS
BEGIN
    SET NOCOUNT ON;
    
    PRINT '==================================================';
    PRINT '   STARTING MASTER ETL PROCESS (DATA WAREHOUSE)   ';
    PRINT '==================================================';

    ---------------------------------------------------
    -- STEP 1: LOAD DIMENSI (Wajib Duluan)
    ---------------------------------------------------
    PRINT '>>> 1. Memuat Tabel Dimensi...';
    
    -- Pastikan nama-nama SP ini sudah ada di database kamu
    -- Beri tanda '--' di depan jika SP belum dibuat
    
    EXEC dbo.usp_Load_Dim_Prodi;      -- (Nyalakan jika ada)
    EXEC dbo.usp_Load_Dim_MataKuliah; -- (Nyalakan jika ada)
    EXEC dbo.usp_Load_Dim_Dosen;      -- (Nyalakan jika ada)
    EXEC dbo.usp_Load_Dim_Mahasiswa;  -- (Nyalakan jika ada)
    EXEC dbo.usp_Load_Dim_Jurnal;  -- (Nyalakan jika ada)
    EXEC dbo.usp_Load_Dim_Waktu; 
    
  
    
    -- Dimensi Waktu biasanya statis (tidak perlu di-load tiap hari), 
    -- tapi kalau kamu buat SP-nya, boleh dimasukkan:
    -- EXEC dbo.usp_Load_Dim_Waktu; 

    PRINT '>>> Dimensi Selesai.';

    ---------------------------------------------------
    -- STEP 2: LOAD FAKTA (Setelah Dimensi Aman)
    ---------------------------------------------------
    PRINT '>>> 2. Memuat Tabel Fakta...';

    PRINT '   - Loading Fakta Akademik...';
    EXEC dbo.usp_Load_Fakta_Akademik;
    
    PRINT '   - Loading Fakta Publikasi...';
    EXEC dbo.usp_Load_Fakta_Publikasi;

    -- Fakta Keuangan (Jika ada)
    -- EXEC dbo.usp_Load_Fact_Transaksi;

    PRINT '==================================================';
    PRINT '   MASTER ETL COMPLETED SUCCESSFULLY (ALL DATA)   ';
    PRINT '==================================================';
END;
GO
EXEC dbo.usp_Master_ETL;
