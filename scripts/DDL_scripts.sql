USE DataWarehouse;
GO

/* ============================================================
   BRONZE LAYER
   Objectif :
   - Stockage des données brutes provenant des systèmes sources
   - Pas de contraintes PK / FK
   - Transformation minimale
   - Conservation des valeurs invalides pour contrôle en Silver
   ============================================================ */


/* ============================================================
   CRM - Customer Information
   ============================================================ */

DROP TABLE IF EXISTS bronze.crm_cust_info;
GO

CREATE TABLE bronze.crm_cust_info
(
    cst_id              INT,
    cst_key             VARCHAR(50),
    cst_firstname       VARCHAR(50),
    cst_lastname        VARCHAR(50),
    cst_marital_status  VARCHAR(20),
    cst_gndr            VARCHAR(20),
    cst_create_date     VARCHAR(20),

    -- Métadonnées techniques
    dwh_ingestion_timestamp DATETIME2 DEFAULT SYSDATETIME(),
    dwh_source_system       VARCHAR(20) DEFAULT 'CRM'
);
GO


/* ============================================================
   CRM - Product Information
   ============================================================ */

DROP TABLE IF EXISTS bronze.crm_prd_info;
GO

CREATE TABLE bronze.crm_prd_info
(
    prd_id              INT,
    prd_key             VARCHAR(50),
    prd_nm              VARCHAR(100),
    prd_cost            VARCHAR(50),
    prd_line            VARCHAR(50),
    prd_start_dt        VARCHAR(20),
    prd_end_dt          VARCHAR(20),

    dwh_ingestion_timestamp DATETIME2 DEFAULT SYSDATETIME(),
    dwh_source_system       VARCHAR(20) DEFAULT 'CRM'
);
GO


/* ============================================================
   CRM - Sales Details
   ============================================================ */

DROP TABLE IF EXISTS bronze.crm_sales_details;
GO

CREATE TABLE bronze.crm_sales_details
(
    sls_ord_num         VARCHAR(50),
    sls_prd_key         VARCHAR(50),
    sls_cust_id         INT,

    -- Dates conservées telles qu'elles arrivent de la source
    sls_order_dt        VARCHAR(20),
    sls_ship_dt         VARCHAR(20),
    sls_due_dt          VARCHAR(20),

    sls_sales           VARCHAR(50),
    sls_quantity        VARCHAR(50),
    sls_price           VARCHAR(50),

    dwh_ingestion_timestamp DATETIME2 DEFAULT SYSDATETIME(),
    dwh_source_system       VARCHAR(20) DEFAULT 'CRM'
);
GO


/* ============================================================
   ERP - Customer Information
   ============================================================ */

DROP TABLE IF EXISTS bronze.erp_cust_az12;
GO

CREATE TABLE bronze.erp_cust_az12
(
    cid                 VARCHAR(55),
    bdate               VARCHAR(20),
    gen                 VARCHAR(50),

    dwh_ingestion_timestamp DATETIME2 DEFAULT SYSDATETIME(),
    dwh_source_system       VARCHAR(20) DEFAULT 'ERP'
);
GO


/* ============================================================
   ERP - Customer Location
   ============================================================ */

DROP TABLE IF EXISTS bronze.erp_loc_a101;
GO

CREATE TABLE bronze.erp_loc_a101
(
    cid                 VARCHAR(55),
    cntry               VARCHAR(55),

    dwh_ingestion_timestamp DATETIME2 DEFAULT SYSDATETIME(),
    dwh_source_system       VARCHAR(20) DEFAULT 'ERP'
);
GO


/* ============================================================
   ERP - Product Categories
   ============================================================ */

DROP TABLE IF EXISTS bronze.erp_px_cat_g1v2;
GO

CREATE TABLE bronze.erp_px_cat_g1v2
(
    id                  VARCHAR(55),
    cat                 VARCHAR(55),
    subcat              VARCHAR(55),
    maintenance         VARCHAR(55),

    dwh_ingestion_timestamp DATETIME2 DEFAULT SYSDATETIME(),
    dwh_source_system       VARCHAR(20) DEFAULT 'ERP'
);
GO