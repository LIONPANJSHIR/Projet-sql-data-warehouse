-- ============================================================
-- INITIALISATION DE LA BASE DE DONNÉES DATA WAREHOUSE
-- Architecture en médaillon : Bronze / Silver / Gold
-- ============================================================


-- ------------------------------------------------------------
-- 1. Se placer dans la base système master
-- Nécessaire pour pouvoir supprimer/recréer une autre base.
-- ------------------------------------------------------------
USE master;
GO


-- ------------------------------------------------------------
-- 2. Vérifier si la base DataWarehouse existe déjà
-- Si elle existe, elle sera supprimée afin de repartir
-- d'un environnement propre.
-- ------------------------------------------------------------
IF EXISTS (
    SELECT 1
    FROM sys.databases
    WHERE name = 'DataWarehouse'
)
BEGIN

    -- Passage en mode SINGLE_USER afin de fermer immédiatement
    -- toutes les connexions actives sur la base.
    ALTER DATABASE DataWarehouse
    SET SINGLE_USER
    WITH ROLLBACK IMMEDIATE;

    -- Suppression de l'ancienne base de données.
    DROP DATABASE DataWarehouse;

END;
GO


-- ------------------------------------------------------------
-- 3. Création de la base de données principale
-- ------------------------------------------------------------
CREATE DATABASE DataWarehouse;
GO


-- ------------------------------------------------------------
-- 4. Sélection de la nouvelle base de données
-- Toutes les opérations suivantes seront exécutées
-- dans DataWarehouse.
-- ------------------------------------------------------------
USE DataWarehouse;
GO


-- ============================================================
-- CRÉATION DES SCHÉMAS DE L'ARCHITECTURE MÉDAILLON
-- ============================================================


-- ------------------------------------------------------------
-- BRONZE
-- Couche contenant les données brutes provenant des sources.
-- Les transformations doivent y être minimales.
-- ------------------------------------------------------------
CREATE SCHEMA bronze;
GO


-- ------------------------------------------------------------
-- SILVER
-- Couche contenant les données nettoyées, standardisées
-- et validées après les traitements de Data Quality.
-- ------------------------------------------------------------
CREATE SCHEMA silver;
GO


-- ------------------------------------------------------------
-- GOLD
-- Couche contenant les données métier prêtes pour l'analyse,
-- les KPI, les dashboards et les outils de Business Intelligence.
-- ------------------------------------------------------------
CREATE SCHEMA gold;
GO