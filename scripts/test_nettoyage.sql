USE DataWarehouse ;
GO 


-- Nous voulons verifier que tout les clients ont un id 
-- SELECT 
-- COUNT(*) AS TOTALROWS
-- FROM bronze.crm_cust_info
-- WHERE cst_id IS NOT NULL 

SELECT 
Total_rows,
Distinct_rows,
Null_rows,
Total_rows - Distinct_rows AS Duplicate_rows
from(
	SELECT 
	COUNT(*) AS Total_rows ,
	COUNT(DISTINCT cst_id ) AS Distinct_rows,
	SUM(CASE WHEN cst_id IS NULL THEN 1 ELSE 0 END) AS Null_rows
	FROM bronze.crm_cust_info
	) as stats;
GO

SELECT *
FROM bronze.crm_cust_info
WHERE cst_id IS NULL


SELECT 
cst_id ,
COUNT(*) AS Total_rows
FROM bronze.crm_cust_info
WHERE cst_id IS NOT NULL
GROUP BY cst_id 
HAVING COUNT(*) > 1


SELECT 
*
FROM bronze.crm_cust_info
WHERE cst_id =  29433 -- 29473  29449,  , 29483 , 29466


SELECT 
    COUNT(*) AS Total_customer,

   SUM(
        CASE 
            WHEN DATALENGTH(cst_firstname) <> DATALENGTH(TRIM(cst_firstname))  OR cst_firstname IS NULL
                THEN 1
            ELSE 0
        END
    ) AS invalid_firstname,

     ROUND( 100.0 * SUM(
        CASE 
            WHEN DATALENGTH(cst_firstname) <> DATALENGTH(TRIM(cst_firstname))  OR cst_firstname IS NULL
                THEN 1
            ELSE 0
        END
    ) / COUNT(*) ,2) AS invalid_firstname_pct

FROM bronze.crm_cust_info;




SELECT 
    COUNT(*) AS Total_customer,

   SUM(
        CASE 
            WHEN DATALENGTH(cst_lastname) <> DATALENGTH(TRIM(cst_lastname)) OR cst_lastname IS NULL
                THEN 1
            ELSE 0
        END
    ) AS invalid_lastname,

     ROUND( 100.0 * SUM(
        CASE 
            WHEN DATALENGTH(cst_lastname) <> DATALENGTH(TRIM(cst_lastname))  OR cst_lastname IS NULL
                THEN 1
            ELSE 0
        END
    ) / COUNT(*) ,2) AS invalid_lastname_pct

FROM bronze.crm_cust_info;



SELECT 
cst_gndr ,
COUNT(*) AS Totals
FROM BRONZE.crm_cust_info
GROUP BY cst_gndr



SELECT 
cst_marital_status ,
COUNT(*) AS Totals
FROM BRONZE.crm_cust_info
GROUP BY cst_marital_status

SELECT 
*
FROM BRONZE.crm_cust_info
WHERE cst_marital_status IS NULL

SELECT 
*
FROM BRONZE.crm_cust_info
WHERE cst_gndr IS NULL






--############################|
--        CRM TABLES          |
--############################|

--****************
-- * CUSTOMER INFO
--****************

-- Les lignes avec cst_id NULL seront supprimées car elles ne contiennent pas d'informations exploitables.

-- 9 doublons ont été détectés.
-- Pour chaque doublon, la dernière ligne enregistrée est la plus complète et sera conservée.

-- Les noms et prénoms seront nettoyés avec TRIM().
-- Les valeurs NULL seront traitées selon les règles de nettoyage définies.

-- cst_gndr :
-- 4 577 valeurs NULL.
-- Elles seront remplacées par 'Unknown'.

-- cst_marital_status :
-- 6 valeurs NULL.
-- Ces lignes sont très incomplètes, dont 50 % sans identifiant client.
-- Elles seront exclues de la couche Silver.




