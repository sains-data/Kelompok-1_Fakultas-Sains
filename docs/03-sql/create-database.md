CREATE DATABASE DM_FakultasSains_DW
ON PRIMARY
(
    NAME = N'DM_FakultasSains_DW_Data',
    FILENAME = N'D:\datadw\DM_FakultasSains_DW_Data.mdf', 
    SIZE = 1GB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 256MB
)
LOG ON
(
    NAME = N'DM_FakultasSains_DW_Log',
    FILENAME = N'D:\datadw\DM_FakultasSains_DW_Log.ldf',
    SIZE = 256MB,
    MAXSIZE = 2GB,
    FILEGROWTH = 64MB
);
GO

USE DM_FakultasSains_DW;
GO


