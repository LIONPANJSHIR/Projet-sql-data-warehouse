USE master ;
GO 

IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'Datawarehouse')
BEGIN 
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE
    DROP DATABASE DataWarehouse
END ;
GO

-- Creation de la base de donnée
CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO 

-- Creation des schéma

CREATE SCHEMA bronze ;
GO
CREATE SCHEMA silver ;
GO
CREATE SCHEMA gold ;
GO 