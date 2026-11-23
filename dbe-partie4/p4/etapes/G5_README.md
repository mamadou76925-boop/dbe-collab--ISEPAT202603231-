# Analyse de journaux d'accès (DBE)

Projet de l'évaluation Linux & Git/GitHub : analyse d'un journal d'accès d'API back-end.

## Description

- `src/GenerateurLogs.java` génère un journal d'accès propre à chaque matricule.
- `scripts/analyse.sh` produit un rapport (familles de codes HTTP, top des endpoints, IP suspecte, temps moyen).
- `scripts/surveille.sh` surveille le nombre de lignes du journal en tâche de fond.

## Usage

```bash
export MATRICULE=<votre-matricule>
javac -encoding UTF-8 -d out src/*.java
mkdir -p logs
java -cp out GenerateurLogs "$MATRICULE" 2000 > logs/access.log
bash scripts/analyse.sh logs/access.log --top 3
```

Codes de retour : 1 arguments ou MATRICULE incorrects, 2 fichier absent, 3 fichier vide.

## Auteur

<NOM Prénom> — matricule <matricule>
