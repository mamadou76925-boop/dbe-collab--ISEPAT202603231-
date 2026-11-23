#!/usr/bin/env bash
# Toutes les 5 s : heure + nombre de lignes de logs/access.log.
LOG=logs/surveillance.log
mkdir -p logs

arret() {
    echo "$(date '+%F %T') arrêt propre" >> "$LOG"
    exit 0
}
trap arret TERM

while true; do
    echo "$(date '+%F %T') $(wc -l < logs/access.log) lignes" >> "$LOG"
    sleep 5 &
    wait $!
done
