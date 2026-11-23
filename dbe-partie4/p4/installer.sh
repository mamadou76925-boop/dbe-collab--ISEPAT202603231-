#!/usr/bin/env bash
# Copie les fichiers du projet dans ~/dbe-eval-<matricule> (sans écraser l'existant).
# Usage : MATRICULE=xxxx bash installer.sh
set -euo pipefail
: "${MATRICULE:?Définissez MATRICULE avant de lancer ce script}"
CIBLE="$HOME/dbe-eval-$ISEPAT202603231"
ICI="$(cd "$(dirname "$0")" && pwd)"
mkdir -p "$CIBLE"/{src,scripts,logs,docs/preuves,rapports,rendus}
cp -n "$ICI"/code/src/*.java "$CIBLE/src/"
cp -n "$ICI"/code/scripts/*.sh "$CIBLE/scripts/"
cp -n "$ICI"/code/.gitignore "$CIBLE/.gitignore"
cp -n "$ICI"/etapes/docs_git.md "$CIBLE/docs/git.md"
echo "Projet prêt dans $CIBLE"
