# Migration Odoo v12 → v13 (Run 3)

Scripts automatisés pour migration incrémentale selon méthodologie OpenUpgrade officielle.

## Plan validé par le board

**Distinction importante :**
- **OpenUpgrade 13.0** (fork) : utilisé UNIQUEMENT pour la migration
- **Odoo 13 Normal** : utilisé pour le serveur test (validation avant production)

## Workflow complet

### Étape 0 : Préparation

```bash
# 1. Cleanup Run 2
./scripts/cleanup_run2.sh

# 2. Préparer environnement (OpenUpgrade + Odoo Normal + openupgradelib)
./scripts/prepare_openupgrade_env.sh

# 3. Créer container migration (OpenUpgrade)
./scripts/create_migration_container.sh

# 4. Backup pre-migration avec Barman
./scripts/barman_backup_pre_migration.sh
```

### Étape 1 : Phase A - Migration OpenUpgrade

```bash
# Lancer migration avec OpenUpgrade fork
./scripts/run_phase_a_migration.sh

# Analyser logs
./scripts/analyze_migration_logs.sh /logs/migration_v13_phase_a_*.log
```

**Si erreurs détectées, 3 options :**

#### OPTION A : Erreur module spécifique
```bash
# 1. Corriger données via SQL
psql production_db -c "UPDATE ... WHERE ..."

# 2. Relancer SEULEMENT ce module
./scripts/fix_and_retry_module.sh account
```

#### OPTION B : Erreur générique
```bash
# Reprendre du point d'échec (ne re-exécute pas end-migration scripts)
./scripts/resume_from_checkpoint.sh
```

#### OPTION C : Base incohérente (cas extrême)
```bash
# 1. Lister backups pre-migration
ssh production-consolidation "barman list-backup odoo_server | grep pre_migration_v13"

# 2. Rollback Barman
./scripts/barman_restore_pre_migration.sh <backup_id>

# 3. Relancer Phase A
./scripts/run_phase_a_migration.sh
```

### Étape 2 : Phase B - Validation finale

```bash
# Valider tous modules migrés
./scripts/validate_all_modules.sh

# Si modules OK, lancer validation finale
./scripts/run_phase_a_migration.sh  # Relance avec --update all pour finalisation
```

### Étape 3 : Démarrage service v13 (Odoo Normal)

```bash
# Switch : Stop OpenUpgrade, Start Odoo 13 Normal
./scripts/switch_to_odoo_normal.sh

# Démarrer service Odoo 13 Normal
./scripts/start_odoo_v13_normal.sh
```

**Accès : http://localhost:8069/web**

### Étape 4 : Validation Board

- Board teste interface web
- Board teste fonctionnalités critiques
- Board signale erreurs fonctionnelles
- Si erreurs : CTO corrige et itère
- Board valide "v13 OK"

### Étape 5 : Checkpoint final Barman

```bash
# SEULEMENT après validation board
./scripts/barman_create_validated_checkpoint.sh
```

## Scripts disponibles

| # | Script | Description |
|---|--------|-------------|
| 1 | cleanup_run2.sh | Détruire containers Run 2 |
| 2 | prepare_openupgrade_env.sh | Installer OpenUpgrade + Odoo 13 Normal + openupgradelib |
| 3 | create_migration_container.sh | Container migration avec fork OpenUpgrade |
| 4 | barman_backup_pre_migration.sh | Backup initial via Barman (production-consolidation) |
| 5 | barman_restore_pre_migration.sh | Restore backup via Barman si rollback nécessaire |
| 6 | run_phase_a_migration.sh | Phase A migration OpenUpgrade |
| 7 | analyze_migration_logs.sh | Parser logs et identifier erreurs/modules |
| 8 | fix_and_retry_module.sh | Upgrade ciblé module spécifique (OPTION A) |
| 9 | resume_from_checkpoint.sh | Reprise migration du point d'échec (OPTION B) |
| 10 | validate_all_modules.sh | Vérifier état modules v13 en base |
| 11 | switch_to_odoo_normal.sh | Stop migration, start Odoo 13 Normal |
| 12 | start_odoo_v13_normal.sh | Démarrer service Odoo 13 Normal |
| 13 | barman_create_validated_checkpoint.sh | Checkpoint final validé |

## Infrastructure

### Barman (production-consolidation)
```bash
# Commandes Barman utiles
ssh production-consolidation "barman list-backup odoo_server"
ssh production-consolidation "barman show-backup odoo_server <backup_id>"
ssh production-consolidation "barman check odoo_server"
```

### Containers Docker

- **odoo_migration** : Container migration (OpenUpgrade fork), port 8013
- **odoo_v13_test** : Container test (Odoo 13 Normal), port 8069

## Logs

Tous les logs sont stockés dans `/logs/` avec timestamps :
- `migration_v13_phase_a_YYYYMMDD_HHMMSS.log`
- `migration_v13_retry_<module>_YYYYMMDD_HHMMSS.log`
- `migration_v13_resume_YYYYMMDD_HHMMSS.log`
- `module_states_YYYYMMDD_HHMMSS.txt`

## Méthodologie OpenUpgrade

**Documentation officielle consultée :**
- Introduction : Architecture, repos, migration séquentielle
- Required Knowledge : Prérequis, openupgradelib, SQL
- Migration Script Development : Workflow itératif (run → check → fix → repeat)
- Migration Files : Structure scripts (pre/post/end-migration.py)

**Workflow itératif recommandé :**
1. Run upgrade
2. Check errors
3. Fix data
4. Repeat

**Ne PAS** rollback complet à chaque erreur - utiliser upgrade ciblé par module.

## Co-Auteur

Co-Authored-By: Paperclip <noreply@paperclip.ing>
