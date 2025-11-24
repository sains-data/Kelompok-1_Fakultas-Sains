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
