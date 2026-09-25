/*==============================================================================
    PROJECT     : Data Warehouse Project
    SCRIPT      : load_bronze.sql
    DATABASE    : DataWarehouse
    LAYER       : Bronze
    DESCRIPTION :
        Chargement des fichiers CSV provenant des systèmes CRM et ERP
        dans les tables de la couche Bronze.

    PROCESSUS :
        1. Création d'une table temporaire correspondant au fichier CSV.
        2. Chargement du CSV dans la table temporaire avec BULK INSERT.
        3. Insertion des données dans la table Bronze correspondante.
        4. Les colonnes techniques du Data Warehouse sont générées
           automatiquement grâce aux valeurs DEFAULT :

              dwh_ingestion_timestamp = SYSDATETIME()
              dwh_source_system       = 'CRM' ou 'ERP'

    REMARQUE :
        Les tables temporaires permettent de séparer :
            - la structure physique du fichier source ;
            - la structure enrichie de la couche Bronze.
==============================================================================*/
USE DataWarehouse;
GO

CREATE OR ALTER PROCEDURE bronze.load_bronze
AS
BEGIN
    SET NOCOUNT ON;  ---ne pas afficher le message indiquant combien de lignes ont été affectées après chaque requête.

    DECLARE @start_time      DATETIME2;
    DECLARE @end_time        DATETIME2;
    DECLARE @batch_start     DATETIME2;
    DECLARE @rows_loaded     INT;

    SET @batch_start = SYSDATETIME();

    PRINT '============================================================';
    PRINT '           DATA WAREHOUSE - BRONZE LOAD';
    PRINT '============================================================';
    PRINT 'Start time : ' + CONVERT(VARCHAR(30), @batch_start, 120);
    PRINT 'Mode       : FULL LOAD';
    PRINT '============================================================';
    PRINT '';

    BEGIN TRY

        /*========================================================
          1. CRM CUSTOMER INFO
        ========================================================*/

        SET @start_time = SYSDATETIME();

        PRINT '[1/6] Loading bronze.crm_cust_info ...';

        IF OBJECT_ID('tempdb..#crm_cust_info') IS NOT NULL
            DROP TABLE #crm_cust_info;

        CREATE TABLE #crm_cust_info (
            cst_id              INT,
            cst_key             VARCHAR(30),
            cst_firstname       VARCHAR(30),
            cst_lastname        VARCHAR(30),
            cst_marital_status  VARCHAR(10),
            cst_gndr            VARCHAR(10),
            cst_create_date     DATE
        );

        BULK INSERT #crm_cust_info
        FROM 'C:\Full_stack\Portfolio\data_engineer_project\data_warehouse_project\datasets\source_crm\cust_info.csv'
        WITH (
            FORMAT = 'CSV',
            FIRSTROW = 2,
            FIELDQUOTE = '"',
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            TABLOCK
        );

        TRUNCATE TABLE bronze.crm_cust_info;

        INSERT INTO bronze.crm_cust_info (
            cst_id,
            cst_key,
            cst_firstname,
            cst_lastname,
            cst_marital_status,
            cst_gndr,
            cst_create_date
        )
        SELECT
            cst_id,
            cst_key,
            cst_firstname,
            cst_lastname,
            cst_marital_status,
            cst_gndr,
            cst_create_date
        FROM #crm_cust_info;

        SET @rows_loaded = @@ROWCOUNT;
        SET @end_time = SYSDATETIME();

        PRINT '      Status   : SUCCESS';
        PRINT '      Rows     : ' + CAST(@rows_loaded AS VARCHAR(20));
        PRINT '      Duration : '
              + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS VARCHAR(20))
              + ' ms';
        PRINT '';


        /*========================================================
          2. CRM PRODUCT INFO
        ========================================================*/

        SET @start_time = SYSDATETIME()

        PRINT '[2/6] Loading bronze.crm_prd_info ...';

        IF OBJECT_ID('tempdb..#crm_prd_info') IS NOT NULL
            DROP TABLE #crm_prd_info;

        CREATE TABLE #crm_prd_info (
            prd_id          INT,
            prd_key         VARCHAR(50),
            prd_nm          VARCHAR(50),
            prd_cost        VARCHAR(50),
            prd_line        VARCHAR(50),
            prd_start_dt    DATE,
            prd_end_dt      DATE
        );

        BULK INSERT #crm_prd_info
        FROM 'C:\Full_stack\Portfolio\data_engineer_project\data_warehouse_project\datasets\source_crm\prd_info.csv'
        WITH (
            FORMAT = 'CSV',
            FIRSTROW = 2,
            FIELDQUOTE = '"',
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            TABLOCK
        );

        TRUNCATE TABLE bronze.crm_prd_info;

        INSERT INTO bronze.crm_prd_info (
            prd_id,
            prd_key,
            prd_nm,
            prd_cost,
            prd_line,
            prd_start_dt,
            prd_end_dt
        )
        SELECT
            prd_id,
            prd_key,
            prd_nm,
            prd_cost,
            prd_line,
            prd_start_dt,
            prd_end_dt
        FROM #crm_prd_info;

        SET @rows_loaded = @@ROWCOUNT
        SET @end_time   = SYSDATETIME()

        PRINT '      Status   : SUCCESS';
        PRINT '      Rows     : ' + CAST(@rows_loaded AS VARCHAR(20));
        PRINT '      Duration : '
              + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS VARCHAR(20))
              + ' ms';
        PRINT '';


        /*========================================================
          3. CRM SALES DETAILS
        ========================================================*/

        SET @start_time = SYSDATETIME();

        PRINT '[3/6] Loading bronze.crm_sales_details ...';

        IF OBJECT_ID('tempdb..#crm_sales_details') IS NOT NULL
            DROP TABLE #crm_sales_details;

        CREATE TABLE #crm_sales_details (
            sls_ord_num     VARCHAR(50),
            sls_prd_key     VARCHAR(50),
            sls_cust_id     INT,
            sls_order_dt    INT,
            sls_ship_dt     INT,
            sls_due_dt      INT,
            sls_sales       INT,
            sls_quantity    INT,
            sls_price       INT
        );

        BULK INSERT #crm_sales_details
        FROM 'C:\Full_stack\Portfolio\data_engineer_project\data_warehouse_project\datasets\source_crm\sales_details.csv'
        WITH (
            FORMAT = 'CSV',
            FIRSTROW = 2,
            FIELDQUOTE = '"',
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            TABLOCK
        );

        TRUNCATE TABLE bronze.crm_sales_details;

        INSERT INTO bronze.crm_sales_details (
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            sls_order_dt,
            sls_ship_dt,
            sls_due_dt,
            sls_sales,
            sls_quantity,
            sls_price
        )
        SELECT
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            sls_order_dt,
            sls_ship_dt,
            sls_due_dt,
            sls_sales,
            sls_quantity,
            sls_price
        FROM #crm_sales_details;

        SET @rows_loaded = @@ROWCOUNT;
        SET @end_time = SYSDATETIME();

        PRINT '      Status   : SUCCESS';
        PRINT '      Rows     : ' + CAST(@rows_loaded AS VARCHAR(20));
        PRINT '      Duration : '
              + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS VARCHAR(20))
              + ' ms';
        PRINT '';


        /*========================================================
          4. ERP CUSTOMER AZ12
        ========================================================*/

        SET @start_time = SYSDATETIME();

        PRINT '[4/6] Loading bronze.erp_cust_az12 ...';

        IF OBJECT_ID('tempdb..#erp_cust_az12') IS NOT NULL
            DROP TABLE #erp_cust_az12;

        CREATE TABLE #erp_cust_az12 (
            CID     VARCHAR(55),
            BDATE   DATE,
            GEN     VARCHAR(50)
        );

        BULK INSERT #erp_cust_az12
        FROM 'C:\Full_stack\Portfolio\data_engineer_project\data_warehouse_project\datasets\source_erp\CUST_AZ12.csv'
        WITH (
            FORMAT = 'CSV',
            FIRSTROW = 2,
            FIELDQUOTE = '"',
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            TABLOCK
        );

        TRUNCATE TABLE bronze.erp_cust_az12;

        INSERT INTO bronze.erp_cust_az12 (
            CID,
            BDATE,
            GEN
        )
        SELECT
            CID,
            BDATE,
            GEN
        FROM #erp_cust_az12;

        SET @rows_loaded = @@ROWCOUNT;
        SET @end_time = SYSDATETIME();

        PRINT '      Status   : SUCCESS';
        PRINT '      Rows     : ' + CAST(@rows_loaded AS VARCHAR(20));
        PRINT '      Duration : '
              + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS VARCHAR(20))
              + ' ms';
        PRINT '';


        /*========================================================
          5. ERP LOCATION
        ========================================================*/

        SET @start_time = SYSDATETIME();

        PRINT '[5/6] Loading bronze.erp_loc_a101 ...';

        IF OBJECT_ID('tempdb..#erp_loc_a101') IS NOT NULL
            DROP TABLE #erp_loc_a101;

        CREATE TABLE #erp_loc_a101 (
            cid     VARCHAR(55),
            cntry   VARCHAR(55)
        );

        BULK INSERT #erp_loc_a101
        FROM 'C:\Full_stack\Portfolio\data_engineer_project\data_warehouse_project\datasets\source_erp\LOC_A101.csv'
        WITH (
            FORMAT = 'CSV',
            FIRSTROW = 2,
            FIELDQUOTE = '"',
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            TABLOCK
        );

        TRUNCATE TABLE bronze.erp_loc_a101;

        INSERT INTO bronze.erp_loc_a101 (
            cid,
            cntry
        )
        SELECT
            cid,
            cntry
        FROM #erp_loc_a101;

        SET @rows_loaded = @@ROWCOUNT;
        SET @end_time = SYSDATETIME();

        PRINT '      Status   : SUCCESS';
        PRINT '      Rows     : ' + CAST(@rows_loaded AS VARCHAR(20));
        PRINT '      Duration : '
              + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS VARCHAR(20))
              + ' ms';
        PRINT '';


        /*========================================================
          6. ERP PRODUCT CATEGORY
        ========================================================*/

        SET @start_time = SYSDATETIME();

        PRINT '[6/6] Loading bronze.erp_px_cat_g1v2 ...';

        IF OBJECT_ID('tempdb..#erp_px_cat_g1v2') IS NOT NULL
            DROP TABLE #erp_px_cat_g1v2;

        CREATE TABLE #erp_px_cat_g1v2 (
            id           VARCHAR(55),
            cat          VARCHAR(55),
            subcat       VARCHAR(55),
            maintenance  VARCHAR(55)
        );

        BULK INSERT #erp_px_cat_g1v2
        FROM 'C:\Full_stack\Portfolio\data_engineer_project\data_warehouse_project\datasets\source_erp\PX_CAT_G1V2.csv'
        WITH (
            FORMAT = 'CSV',
            FIRSTROW = 2,
            FIELDQUOTE = '"',
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            TABLOCK
        );

        TRUNCATE TABLE bronze.erp_px_cat_g1v2;

        INSERT INTO bronze.erp_px_cat_g1v2 (
            id,
            cat,
            subcat,
            maintenance
        )
        SELECT
            id,
            cat,
            subcat,
            maintenance
        FROM #erp_px_cat_g1v2;

        SET @rows_loaded = @@ROWCOUNT;
        SET @end_time = SYSDATETIME();

        PRINT '      Status   : SUCCESS';
        PRINT '      Rows     : ' + CAST(@rows_loaded AS VARCHAR(20));
        PRINT '      Duration : '
              + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS VARCHAR(20))
              + ' ms';
        PRINT '';


        /*========================================================
          GLOBAL SUMMARY
        ========================================================*/

        SET @end_time = SYSDATETIME();

        PRINT '============================================================';
        PRINT '              BRONZE LOAD COMPLETED';
        PRINT '============================================================';
        PRINT 'Status         : SUCCESS';
        PRINT 'Start time     : '
              + CONVERT(VARCHAR(30), @batch_start, 120);
        PRINT 'End time       : '
              + CONVERT(VARCHAR(30), @end_time, 120);
        PRINT 'Total duration : '
              + CAST(DATEDIFF(SECOND, @batch_start, @end_time) AS VARCHAR(20))
              + ' seconds';
        PRINT '============================================================';

    END TRY

    BEGIN CATCH

        SET @end_time = SYSDATETIME();

        PRINT '';
        PRINT '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!';
        PRINT '                 BRONZE LOAD FAILED';
        PRINT '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!';

        PRINT 'Error number    : '
              + CAST(ERROR_NUMBER() AS VARCHAR(20));

        PRINT 'Error message   : '
              + ERROR_MESSAGE();

        PRINT 'Error procedure : '
              + COALESCE(ERROR_PROCEDURE(), 'N/A');

        PRINT 'Error line      : '
              + CAST(ERROR_LINE() AS VARCHAR(20));

        PRINT 'Failure time    : '
              + CONVERT(VARCHAR(30), @end_time, 120);

        PRINT '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!';

        THROW;

    END CATCH;

END;
GO



