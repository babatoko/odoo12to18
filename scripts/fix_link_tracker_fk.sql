-- Fix link_tracker foreign key violation
-- Error: Key (mass_mailing_id)=(8) is not present in table "mailing_mailing"

\echo '=== FIX LINK_TRACKER FOREIGN KEY ==='
\echo ''

-- 1. Identifier les enregistrements orphelins
\echo '1. Enregistrements link_tracker avec mass_mailing_id orphelin:'
SELECT id, mass_mailing_id, url
FROM link_tracker
WHERE mass_mailing_id IS NOT NULL
  AND mass_mailing_id NOT IN (SELECT id FROM mailing_mailing);

\echo ''

-- 2. Nettoyer les références orphelines (SET NULL)
\echo '2. Nettoyage références orphelines:'
UPDATE link_tracker
SET mass_mailing_id = NULL
WHERE mass_mailing_id IS NOT NULL
  AND mass_mailing_id NOT IN (SELECT id FROM mailing_mailing);

SELECT '   Mis à NULL: ' || ROW_COUNT() || ' enregistrement(s)' as result;

\echo ''

-- 3. Vérification post-fix
\echo '3. Vérification - reste-t-il des orphelins?:'
SELECT COUNT(*) as orphan_count
FROM link_tracker
WHERE mass_mailing_id IS NOT NULL
  AND mass_mailing_id NOT IN (SELECT id FROM mailing_mailing);

\echo ''
\echo '=== FIN FIX ==='
