-- Audit intégrité base v12 avant migration v13
-- Recherche des doublons qui violeront les contraintes uniques v13

\echo '=== AUDIT INTEGRITE BASE V12 ==='
\echo ''

-- 1. Doublons res_groups (contrainte res_groups_name_uniq)
\echo '1. Doublons res_groups (category_id, name):'
SELECT category_id, name, COUNT(*) as count, STRING_AGG(id::varchar, ', ') as ids
FROM res_groups
GROUP BY category_id, name
HAVING COUNT(*) > 1
ORDER BY count DESC;

\echo ''

-- 2. Doublons product_product sans combination_indices unique
\echo '2. Product variants avec combination_indices identiques:'
SELECT product_tmpl_id, combination_indices, COUNT(*) as count, STRING_AGG(id::varchar, ', ') as ids
FROM product_product
WHERE combination_indices IS NOT NULL
GROUP BY product_tmpl_id, combination_indices
HAVING COUNT(*) > 1
ORDER BY count DESC
LIMIT 20;

\echo ''

-- 3. Produits sans combination_indices (potentiel problème)
\echo '3. Products sans combination_indices:'
SELECT COUNT(*) as count
FROM product_product
WHERE combination_indices IS NULL OR combination_indices = '';

\echo ''

-- 4. Doublons ir_model_data (xml_id uniques)
\echo '4. Doublons ir_model_data (module, name):'
SELECT module, name, COUNT(*) as count
FROM ir_model_data
GROUP BY module, name
HAVING COUNT(*) > 1
LIMIT 10;

\echo ''

-- 5. Doublons res_partner (vat unique par company)
\echo '5. Doublons res_partner VAT:'
SELECT vat, company_id, COUNT(*) as count, STRING_AGG(id::varchar, ', ') as ids
FROM res_partner
WHERE vat IS NOT NULL AND vat != ''
GROUP BY vat, company_id
HAVING COUNT(*) > 1
LIMIT 10;

\echo ''

-- 6. Doublons product_template (barcode unique)
\echo '6. Doublons product barcode:'
SELECT barcode, COUNT(*) as count, STRING_AGG(id::varchar, ', ') as ids
FROM product_product
WHERE barcode IS NOT NULL AND barcode != ''
GROUP BY barcode
HAVING COUNT(*) > 1
LIMIT 10;

\echo ''
\echo '=== FIN AUDIT ==='
