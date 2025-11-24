USE DM_FakultasSains_DW;
GO

-- ==================================================
-- 7. Fakta_Akademik (Transaksi Nilai/KRS)
-- ==================================================
CREATE TABLE dbo.Fakta_Akademik (
    ID_Fakta_Akademik BIGINT IDENTITY(1,1) PRIMARY KEY, -- Surrogate Key untuk Fakta
    
    -- Foreign Keys (Menghubungkan ke Tabel Dimensi)
    ID_Mahasiswa INT NOT NULL,
    ID_MK INT NOT NULL,
    ID_Dosen INT NOT NULL,
    ID_Waktu INT NOT NULL, 
    
    -- Measures (Nilai yang bisa dihitung)
    Jumlah_SKS_Diambil INT,
    Bobot_Nilai DECIMAL(3,2), -- Contoh: 4.00, 3.50
    Status_Lulus VARCHAR(50), -- Contoh: 'Lulus', 'Tidak Lulus'
    
    -- Constraints (Menjaga Integritas Data)
    CONSTRAINT FK_FaktaAkademik_Mahasiswa FOREIGN KEY (ID_Mahasiswa) 
        REFERENCES dbo.Dim_Mahasiswa(ID_Mahasiswa),
        
    CONSTRAINT FK_FaktaAkademik_MK FOREIGN KEY (ID_MK) 
        REFERENCES dbo.Dim_MataKuliah(ID_MK),
        
    CONSTRAINT FK_FaktaAkademik_Dosen FOREIGN KEY (ID_Dosen) 
        REFERENCES dbo.Dim_Dosen(ID_Dosen),
        
    CONSTRAINT FK_FaktaAkademik_Waktu FOREIGN KEY (ID_Waktu) 
        REFERENCES dbo.Dim_Waktu(ID_Waktu)
);
GO

-- ==================================================
-- 8. Fakta_Publikasi (Transaksi Penelitian Dosen)
-- ==================================================
CREATE TABLE dbo.Fakta_Publikasi (
    ID_Fakta_Publikasi BIGINT IDENTITY(1,1) PRIMARY KEY,
    
    -- Foreign Keys
    ID_Dosen INT NOT NULL,
    ID_Jurnal INT NOT NULL,
    ID_Waktu INT NOT NULL,
    
    -- Measures
    Jumlah_Sitasi INT,
    Jumlah_Publikasi INT, 
    
    -- Constraints
    CONSTRAINT FK_FaktaPublikasi_Dosen FOREIGN KEY (ID_Dosen) 
        REFERENCES dbo.Dim_Dosen(ID_Dosen),
        
    CONSTRAINT FK_FaktaPublikasi_Jurnal FOREIGN KEY (ID_Jurnal) 
        REFERENCES dbo.Dim_Jurnal(ID_Jurnal),
        
    CONSTRAINT FK_FaktaPublikasi_Waktu FOREIGN KEY (ID_Waktu) 
        REFERENCES dbo.Dim_Waktu(ID_Waktu)
);
GO

