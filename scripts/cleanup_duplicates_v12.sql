-- Nettoyage doublons et corrections pré-migration v13
-- Script généré après audit intégrité

\echo '=== NETTOYAGE PRE-MIGRATION V12→V13 ==='
\echo ''

-- 1. Correction ir_model_data pour groupe "Discount on lines"
--    Le groupe existe dans 'sale' mais doit être dans 'product' pour v13
\echo '1. Correction module ownership pour group_discount_per_so_line:'
UPDATE ir_model_data
SET module = 'product'
WHERE module = 'sale'
  AND name = 'group_discount_per_so_line'
  AND model = 'res.groups';

SELECT '   Updated ' || ROW_COUNT() || ' record(s)' as result;

\echo ''

-- 2. Nettoyage doublons res_partner (VAT)
--    Garder le plus ancien partenaire, désactiver les autres
\echo '2. Nettoyage doublons res_partner VAT:'

-- Pour chaque VAT dupliqué, garder l'ID le plus petit et désactiver les autres
WITH duplicates AS (
    SELECT vat, company_id, MIN(id) as keep_id
    FROM res_partner
    WHERE vat IS NOT NULL AND vat != ''
    GROUP BY vat, company_id
    HAVING COUNT(*) > 1
)
UPDATE res_partner rp
SET active = FALSE
FROM duplicates d
WHERE rp.vat = d.vat
  AND (rp.company_id = d.company_id OR (rp.company_id IS NULL AND d.company_id IS NULL))
  AND rp.id != d.keep_id;

SELECT '   Désactivé ' || ROW_COUNT() || ' partenaire(s) dupliqué(s)' as result;

\echo ''

-- 3. Vérification autres groupes potentiellement migrés
\echo '3. Vérification autres groupes product dans sale:'
SELECT id, module, name, model, res_id
FROM ir_model_data
WHERE model = 'res.groups'
  AND module = 'sale'
  AND name IN ('group_product_pricelist', 'group_sale_pricelist', 'group_product_variant')
LIMIT 5;

\echo ''

-- 4. Vérification finale: comptage doublons restants
\echo '4. Vérification post-nettoyage:'

SELECT 'res_groups duplicates' as table_name, COUNT(*) as remaining_duplicates
FROM (
    SELECT category_id, name, COUNT(*) as count
    FROM res_groups
    GROUP BY category_id, name
    HAVING COUNT(*) > 1
) sub
UNION ALL
SELECT 'res_partner VAT active duplicates', COUNT(*)
FROM (
    SELECT vat, company_id, COUNT(*) as count
    FROM res_partner
    WHERE vat IS NOT NULL AND vat != '' AND active = TRUE
    GROUP BY vat, company_id
    HAVING COUNT(*) > 1
) sub;

\echo ''
\echo '=== FIN NETTOYAGE ==='
