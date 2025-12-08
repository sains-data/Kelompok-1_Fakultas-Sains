 USE DM_FakultasSains_DW; 
GO

-- Membuat Role untuk berbagai level manajemen
CREATE ROLE db_executive;    -- Untuk Dekan/Wakil Dekan
CREATE ROLE db_analyst;      -- Untuk Kaprodi & Tim Mutu
CREATE ROLE db_viewer;       -- Untuk Staf Admin & Dosen Umum
CREATE ROLE db_etl_operator; -- Untuk Sistem Backend
GO

-- Memberikan Hak Akses (Grant Permissions)
-- Executive: Full Read & Unmask
GRANT SELECT ON SCHEMA::dbo TO db_executive;
GRANT UNMASK TO db_executive;

-- Analyst: Read DBO & Full Control Staging
GRANT SELECT ON SCHEMA::dbo TO db_analyst;
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::stg TO db_analyst;
GRANT UNMASK TO db_analyst;

-- Viewer: Restricted Access (Hanya View Dashboard)
GRANT SELECT ON dbo.vw_Student_Performance TO db_viewer;
GRANT SELECT ON dbo.vw_Course_Failure_Analysis TO db_viewer;
GRANT SELECT ON dbo.vw_Dosen_Productivity TO db_viewer;
-- (Viewer tidak diberikan hak UNMASK)
GO