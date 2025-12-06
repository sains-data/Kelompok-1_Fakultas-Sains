EXEC dbo.usp_Load_Dim_Prodi;

-- 2. Load Referensi Independen
EXEC dbo.usp_Load_Dim_Jurnal;

-- 3. Load Dimensi Anak (Butuh Prodi)
EXEC dbo.usp_Load_Dim_MataKuliah;
EXEC dbo.usp_Load_Dim_Dosen;
EXEC dbo.usp_Load_Dim_Mahasiswa;  -- (Yang sudah Anda buat tadi)

SELECT * FROM dbo.Dim_Prodi;
SELECT * FROM dbo.Dim_Dosen;
SELECT * FROM dbo.Dim_MataKuliah;
SELECT * FROM dbo.Dim_Mahasiswa;

-- Load Fakta Akademik
EXEC dbo.usp_Load_Fakta_Akademik;

-- Load Fakta Publikasi
EXEC dbo.usp_Load_Fakta_Publikasi;

-- Cek Hasil Akhir
SELECT COUNT(*) AS Total_Fakta_Akademik FROM dbo.Fakta_Akademik;
SELECT COUNT(*) AS Total_Fakta_Publikasi FROM dbo.Fakta_Publikasi;

