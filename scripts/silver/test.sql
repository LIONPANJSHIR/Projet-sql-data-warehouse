USE DataWarehouse ;
GO 


-- Nous voulons verifier que tout les clients ont un id 
-- SELECT 
-- COUNT(*) AS TOTALROWS
-- FROM bronze.crm_cust_info
-- WHERE cst_id IS NOT NULL 

SELECT 
cst_id,
COUNT(*) AS TOTALROWS
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1


SELECT 
*
from (

    SELECT
    *,
    ROW_NUMBER() OVER(
        PARTITION BY cst_id 
        ORDER BY cst_create_date DESC
    ) AS duplicated_id_flag
    FROM bronze.crm_cust_info
    -- ORDER BY cst_id
) as ranked

ORDER BY duplicated_id_flag DESC






