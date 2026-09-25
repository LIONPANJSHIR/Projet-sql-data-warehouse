
USE DataWarehouse;
GO

/* ============================================================
   silver LAYER
   ============================================================
   Objectif :
   - Stocker les données brutes provenant des systèmes sources.
   - Conserver les données aussi proches que possible de leur
     format d'origine.
   - Ne pas appliquer de contraintes PK / FK à ce stade.
   - Limiter les transformations et nettoyages.
   - Conserver les valeurs invalides ou incohérentes afin de
     pouvoir les identifier et les traiter dans la couche Silver.

   Systèmes sources :
   - CRM : données clients, produits et ventes.
   - ERP : informations complémentaires clients, localisation
           et catégories produits.

   Métadonnées techniques :
   - dwh_ingestion_timestamp :
       Date et heure de chargement de la ligne dans le DWH.
   - dwh_source_system :
       Système source dont provient la donnée.
   ============================================================ */


/* ============================================================
   TABLE : silver.crm_cust_info
   SOURCE : CRM
   DESCRIPTION :
   Stocke les informations brutes relatives aux clients.
   ============================================================ */

DROP TABLE IF EXISTS silver.crm_cust_info;
GO

CREATE TABLE silver.crm_cust_info
(
    -- Identifiant du client dans le système source
    cst_id                   INT,

    -- Clé métier du client
    cst_key                  VARCHAR(50),

    -- Informations d'identité
    cst_firstname            VARCHAR(50),
    cst_lastname             VARCHAR(50),

    -- Statut matrimonial tel qu'il apparaît dans la source
    cst_marital_status       VARCHAR(20),

    -- Genre tel qu'il apparaît dans la source
    cst_gndr                 VARCHAR(20),

    -- Date conservée sous forme texte en silver
    -- La conversion vers DATE sera effectuée en Silver
    cst_create_date          DATE,

    -- Métadonnées techniques du Data Warehouse
    dwh_ingestion_timestamp  DATETIME2 DEFAULT SYSDATETIME(),
    dwh_source_system        VARCHAR(20) DEFAULT 'CRM'
);
GO


/* ============================================================
   TABLE : silver.crm_prd_info
   SOURCE : CRM
   DESCRIPTION :
   Stocke les informations brutes relatives aux produits.
   ============================================================ */

DROP TABLE IF EXISTS silver.crm_prd_info;
GO

CREATE TABLE silver.crm_prd_info
(
    -- Identifiant du produit
    prd_id                   INT,

    -- Clé métier du produit
    prd_key                  VARCHAR(50),

    -- Clé métier du catalogue
 
    cat_id                 VARCHAR(50),

    -- Nom du produit
    prd_nm                   VARCHAR(100),

    -- Coût conservé dans son format source
    -- La conversion numérique sera réalisée en Silver
    prd_cost                 VARCHAR(50),

    -- Ligne / gamme du produit
    prd_line                 VARCHAR(50),

    -- Dates conservées sous forme texte
    prd_start_dt             DATE,
    prd_end_dt               DATE,

    -- Métadonnées techniques
    dwh_ingestion_timestamp  DATETIME2 DEFAULT SYSDATETIME(),
    dwh_source_system        VARCHAR(20) DEFAULT 'CRM'
);
GO


/* ============================================================
   TABLE : silver.crm_sales_details
   SOURCE : CRM
   DESCRIPTION :
   Stocke les transactions de ventes provenant du CRM.
   ============================================================ */

DROP TABLE IF EXISTS silver.crm_sales_details;
GO

CREATE TABLE silver.crm_sales_details
(
    -- Numéro de commande
    sls_ord_num              VARCHAR(50),

    -- Clé du produit vendu
    sls_prd_key              VARCHAR(50),

    -- Identifiant du client
    sls_cust_id              INT,

    -- Dates conservées telles qu'elles arrivent de la source.
    -- Leur validation et conversion seront effectuées en Silver.
    sls_order_dt             VARCHAR(20),
    sls_ship_dt              VARCHAR(20),
    sls_due_dt               VARCHAR(20),

    -- Mesures commerciales conservées dans leur format source
    sls_sales                VARCHAR(50),
    sls_quantity             VARCHAR(50),
    sls_price                VARCHAR(50),

    -- Métadonnées techniques
    dwh_ingestion_timestamp  DATETIME2 NOT NULL
        DEFAULT SYSDATETIME(),

    dwh_source_system        VARCHAR(20) NOT NULL
        DEFAULT 'CRM'
);
GO


/* ============================================================
   TABLE : silver.erp_cust_az12
   SOURCE : ERP
   DESCRIPTION :
   Stocke les informations complémentaires relatives aux clients
   issues du système ERP.
   ============================================================ */

DROP TABLE IF EXISTS silver.erp_cust_az12;
GO

CREATE TABLE silver.erp_cust_az12
(
    -- Identifiant / clé client provenant de l'ERP
    cid                      VARCHAR(55),

    -- Date de naissance conservée sous forme texte
    bdate                    VARCHAR(20),

    -- Genre provenant de l'ERP
    gen                      VARCHAR(50),

    -- Métadonnées techniques
    dwh_ingestion_timestamp  DATETIME2 DEFAULT SYSDATETIME(),
    dwh_source_system        VARCHAR(20) DEFAULT 'ERP'
);
GO


/* ============================================================
   TABLE : silver.erp_loc_a101
   SOURCE : ERP
   DESCRIPTION :
   Stocke les informations de localisation des clients.
   ============================================================ */

DROP TABLE IF EXISTS silver.erp_loc_a101;
GO

CREATE TABLE silver.erp_loc_a101
(
    -- Identifiant du client
    cid                      VARCHAR(55),

    -- Pays / localisation du client
    cntry                    VARCHAR(55),

    -- Métadonnées techniques
    dwh_ingestion_timestamp  DATETIME2 DEFAULT SYSDATETIME(),
    dwh_source_system        VARCHAR(20) DEFAULT 'ERP'
);
GO


/* ============================================================
   TABLE : silver.erp_px_cat_g1v2
   SOURCE : ERP
   DESCRIPTION :
   Stocke la hiérarchie de catégories associée aux produits.
   ============================================================ */

DROP TABLE IF EXISTS silver.erp_px_cat_g1v2;
GO

CREATE TABLE silver.erp_px_cat_g1v2
(
    -- Identifiant métier permettant de relier la catégorie
    -- aux informations produits
    id                       VARCHAR(55),

    -- Catégorie principale
    cat                      VARCHAR(55),

    -- Sous-catégorie
    subcat                   VARCHAR(55),

    -- Information relative à la maintenance du produit
    maintenance              VARCHAR(55),

    -- Métadonnées techniques
    dwh_ingestion_timestamp  DATETIME2 DEFAULT SYSDATETIME(),
    dwh_source_system        VARCHAR(20) DEFAULT 'ERP'
);
GO

