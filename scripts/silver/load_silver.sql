TRUNCATE TABLE silver.crm_cust_info;

INSERT INTO silver.crm_cust_info 
(
    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_gndr,
    cst_marital_status,
    cst_create_date
)
SELECT 
    cst_id,
    cst_key,

    -- Nettoyage des espaces
    TRIM(cst_firstname) AS cst_firstname,
    TRIM(cst_lastname) AS cst_lastname,

    -- Standardisation du genre
    CASE 
        WHEN TRIM(UPPER(cst_gndr)) = 'M' THEN 'Homme'
        WHEN TRIM(UPPER(cst_gndr)) = 'F' THEN 'Femme'
        ELSE 'Non_renseigné'
    END AS cst_gndr,

    -- Standardisation du statut marital
    CASE 
        WHEN TRIM(UPPER(cst_marital_status)) = 'M' THEN 'Marié(e)'
        WHEN TRIM(UPPER(cst_marital_status)) = 'S' THEN 'Célibataire'
        ELSE 'Non_renseigné'
    END AS cst_marital_status,

    cst_create_date

FROM (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY cst_id
            ORDER BY cst_create_date DESC
        ) AS flag_last
    FROM bronze.crm_cust_info
    WHERE cst_id IS NOT NULL
) AS t

WHERE flag_last = 1;








TRUNCATE TABLE silver.crm_prd_info;

/*==============================================================
  Chargement de la table Silver : silver.crm_prd_info
  Source : bronze.crm_prd_info

  Objectifs :
    - Extraire la catégorie depuis la clé produit
    - Nettoyer et standardiser la clé produit
    - Remplacer les coûts NULL par 0
    - Standardiser les lignes de produits
    - Recalculer les dates de fin des différentes versions produit
==============================================================*/

INSERT INTO silver.crm_prd_info (
    prd_id,
    prd_key,
    cat_id,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
)

SELECT 
    -- Identifiant unique du produit
    prd_id,

    -- Extraction de la clé produit sans le préfixe catégorie
    SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,

    -- Extraction de la catégorie depuis les 5 premiers caractères
    -- Remplacement des "-" par "_" pour correspondre au format ERP
    REPLACE(
        SUBSTRING(prd_key, 1, 5),
        '-',
        '_'
    ) AS cat_id,

    -- Nom du produit
    prd_nm,

    -- Remplacement des coûts NULL par 0
   ISNULL(TRY_CAST(prd_cost AS INT), 0) AS prd_cost,

    -- Standardisation des codes de ligne produit
    CASE
        WHEN TRIM(UPPER(prd_line)) = 'M' THEN 'Montagne'
        WHEN TRIM(UPPER(prd_line)) = 'R' THEN 'Route'
        WHEN TRIM(UPPER(prd_line)) = 'T' THEN 'Touring'
        WHEN TRIM(UPPER(prd_line)) = 'S' THEN 'Autres achats'
        ELSE 'Non_renseigné'
    END AS prd_line,

    -- Date de début de validité de la version produit
    prd_start_dt,

    -- Date de fin calculée à partir de la prochaine version du même produit.
    -- La date de fin correspond à la veille de la prochaine date de début.
    -- La version la plus récente conserve une date de fin NULL.
    CAST(
        DATEADD(
            DAY,
            -1,
            LEAD(prd_start_dt) OVER (
                PARTITION BY prd_key
                ORDER BY prd_start_dt
            )
        ) AS DATE
    ) AS prd_end_dt

FROM bronze.crm_prd_info;