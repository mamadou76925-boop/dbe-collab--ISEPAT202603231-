#!/usr/bin/env bash
# Analyse d'un journal d'accès d'API back-end et écriture d'un rapport.
set -euo pipefail

TOP=3
FICHIER=""
RAPPORT=""

usage() {
    echo "Usage : bash scripts/analyse.sh <fichier.log> [--top N]" >&2
}

lire_arguments() {
    if [[ $# -eq 1 ]]; then
        FICHIER="$1"
    elif [[ $# -eq 3 && "$2" == "--top" && "$3" =~ ^[0-9]+$ ]]; then
        FICHIER="$1"
        TOP="$3"
    else
        usage
        exit 1
    fi
}

verifier_prerequis() {
    if [[ -z "${MATRICULE:-}" ]]; then
        echo "Erreur : la variable MATRICULE n'est pas définie" >&2
        exit 1
    fi
    if [[ ! -f "$FICHIER" ]]; then
        echo "Erreur : fichier introuvable : $FICHIER" >&2
        exit 2
    fi
    if [[ ! -s "$FICHIER" ]]; then
        echo "Erreur : fichier vide : $FICHIER" >&2
        exit 3
    fi
}

compter_familles() {
    local famille nb
    for famille in 2 3 4 5; do
        nb=$(awk -v f="$famille" 'substr($9,1,1)==f {n++} END {print n+0}' "$FICHIER")
        echo "${famille}xx : $nb"
    done
}

top_endpoints() {
    awk '{p=$7; sub(/\?.*/, "", p); print p}' "$FICHIER" \
        | sort | uniq -c | sort -k1,1nr -k2 \
        | awk -v n="$TOP" 'NR<=n {print $1, $2}'
}

ip_suspecte() {
    local res
    res=$(awk '$7=="/api/auth/login" && $9==401 {c[$1]++} END {for (i in c) print c[i], i}' "$FICHIER" \
        | sort -k1,1nr | awk 'NR==1 {print $2 " (" $1 " échecs 401)"}')
    echo "${res:-Aucune IP suspecte}"
}

temps_moyen_200() {
    awk '$9==200 {gsub("ms", "", $11); s+=$11; n++} END {if (n>0) printf "%.1f ms\n", s/n; else print "n/a"}' "$FICHIER"
}

requetes_par_heure() {
    awk '{h[substr($4,14,2)]++} END {for (k in h) print k "h : " h[k]}' "$FICHIER" | sort
}

ecrire_rapport() {
    mkdir -p rapports
    RAPPORT="rapports/rapport_${MATRICULE}_$(date +%Y%m%d_%H%M).txt"
    {
        echo "=== Rapport d'analyse ==="
        echo "Date        : $(date '+%F %T')"
        echo "Utilisateur : $(whoami)@$(hostname)"
        echo "Matricule   : $MATRICULE"
        echo "Fichier     : $FICHIER"
        echo "SHA256      : $(sha256sum "$FICHIER" | cut -d' ' -f1)"
        echo
        echo "--- Requêtes par famille ---"
        compter_familles
        echo
        echo "--- Top $TOP des endpoints ---"
        top_endpoints
        echo
        echo "--- IP suspecte ---"
        ip_suspecte
        echo
        echo "--- Temps de réponse moyen (200) ---"
        temps_moyen_200
        echo
        echo "--- Requêtes par heure ---"
        requetes_par_heure
    } > "$RAPPORT"
    echo "Rapport écrit : $RAPPORT"
}

main() {
    lire_arguments "$@"
    verifier_prerequis
    ecrire_rapport
}

main "$@"
