# Partie 4 — Git/GitHub pratique individuelle (guide pas à pas)

```
code/                 → fichiers du projet (G2) : GenerateurLogs.java, analyse.sh, surveille.sh, .gitignore
etapes/G4_ci.yml      → pipeline demandé en G4
etapes/analyse_wip1-3.sh → les 3 états successifs de analyse.sh pour G5 (fonction « requêtes par heure »)
etapes/G5_README.md   → README de G5 (à compléter avec votre nom)
etapes/docs_git.md    → modèle de docs/git.md
installer.sh          → copie le tout dans ~/dbe-eval-<matricule>
```

Tout a été testé en local (scripts, rebase, stash, cherry-pick, revert). Les commandes ci-dessous
supposent que vous avez fait la partie 2 : `docs/linux.md`, `rapports/` et l'archive
`rendus/linux_<matricule>.tar.gz` doivent venir de **votre** session Linux. Pas de contournement :
l'empreinte de l'archive est recopiée sur la fiche et le contrôle oral peut vous faire refaire une commande.

Remplacez `<ISEPAT202603231>` par votre matricule et `<mamadou ndiaye>` par votre compte GitHub.

## 0. Préparer et enregistrer

```bash
export MATRICULE=<ISEPAT202603231>
bash installer.sh          # si le projet n'existe pas déjà
cd ~/dbe-eval-$MATRICULE
script -q --timing=docs/preuves/git.tm docs/preuves/git.log
```

## G1 — Configuration et signature (2 pts)

```bash
git config --global user.name "Prénom Nom"
git config --global user.email "vous@exemple.com"
git config --global init.defaultBranch main
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/id_ed25519.pub
git config --global commit.gpgsign true
git config --global tag.gpgSign true
# (clé absente ?)  ssh-keygen -t ed25519 -C "vous@exemple.com"
# pour voir « Good signature » en local :
echo "vous@exemple.com $(cat ~/.ssh/id_ed25519.pub)" >> ~/.ssh/allowed_signers
git config --global gpg.ssh.allowedSignersFile ~/.ssh/allowed_signers
```

GitHub → Settings → SSH and GPG keys : ajouter la même clé **deux fois** (Authentication key, puis Signing key).

## G2 — Dépôt local (2 pts) — 4 commits atomiques minimum

```bash
git init
git add .gitignore src/GenerateurLogs.java && git commit -m "Ajoute le générateur de logs Java"
git add scripts                           && git commit -m "Ajoute les scripts d'analyse et de surveillance"
git add docs/linux.md docs/git.md         && git commit -m "Ajoute la documentation"
git add rendus/linux_$MATRICULE.tar.gz    && git commit -m "Ajoute l'archive de rendu Linux"
git status --short     # rien d'inattendu ; logs/ et out/ sont ignorés
```

## G3 — Publier (2 pts)

Avec l'interface web : New repository → `dbe-eval-<mat>`, **Private**, sans README ; Settings → Collaborators → `pape1283` ;
Settings → Secrets and variables → Actions → **Variables** → `MATRICULE`.
Ou avec `gh` :

```bash
gh repo create dbe-eval-$MATRICULE --private
gh api -X PUT repos/<user>/dbe-eval-$MATRICULE/collaborators/pape1283
gh variable set MATRICULE --body "$MATRICULE" -R <user>/dbe-eval-$MATRICULE
```

```bash
git remote add origin git@github.com:<user>/dbe-eval-$MATRICULE.git
git push -u origin main
```

## G4 — Intégration continue (4 pts)

```bash
git switch -c ci/pipeline
mkdir -p .github/workflows
cp <dossier>/etapes/G4_ci.yml .github/workflows/ci.yml
git add .github && git commit -m "Ajoute le pipeline d'intégration continue"
git push -u origin ci/pipeline
```

Sur GitHub : Compare & pull request → base `main` → attendre le ✔ vert → **Squash and merge**
(le commit est signé par GitHub et l'historique reste linéaire ; évitez « Create a merge commit »).
Comparez ensuite l'artefact `rapport` (ou le log du job) avec votre rapport local : même matricule, mêmes nombres, même SHA256.

```bash
git switch main && git pull
git branch -d ci/pipeline
```

## G5 — Fonctionnalité, réécriture d'historique et rebase (5 pts)

```bash
git switch -c feature/heures
cp <dossier>/etapes/analyse_wip1.sh scripts/analyse.sh && git commit -am "wip 1"
cp <dossier>/etapes/analyse_wip2.sh scripts/analyse.sh && git commit -am "wip 2"
cp <dossier>/etapes/analyse_wip3.sh scripts/analyse.sh && git commit -am "wip 3"

git switch main
cp <dossier>/etapes/G5_README.md README.md      # puis remplacez <NOM Prénom> et <matricule>
git add README.md && git commit -m "Ajoute le README"

git switch feature/heures
git rebase -i main
```

Dans l'éditeur : laissez `pick` sur « wip 1 » et mettez `squash` (ou `s`) sur « wip 2 » et « wip 3 ».
À l'écran suivant, remplacez tous les messages par : `Ajoute le nombre de requêtes par heure au rapport`.

```bash
git switch main
git merge --ff-only feature/heures
git log --oneline --graph      # linéaire, aucun « wip »
git push
```

Les commits réécrits par le rebase sont re-signés automatiquement (`commit.gpgsign true`).

## G6 — Stash (2 pts)

```bash
echo "" >> README.md && echo "Section en cours de rédaction…" >> README.md   # modification non commitée
git stash push -m "readme en cours"
git stash list            # à coller dans docs/git.md
```

→ faites G7, puis : `git stash pop`.

## G7 — Correctif et cherry-pick (2 pts)

```bash
git branch release/1.0 HEAD~1        # avant-dernier commit de main (à faire AVANT le correctif)
sed -i 's|\[--top N\]"|[--top N]  (exemple : --top 5)"|' scripts/analyse.sh
git commit -am "Corrige le message d'usage de analyse.sh (exemple --top 5)"
git push
git switch release/1.0
git cherry-pick -x main
git push -u origin release/1.0
git switch main
git stash pop
git add README.md && git commit -m "Complète le README" && git push
```

`-x` ajoute « (cherry picked from commit …) » au message : c'est la trace attendue.

## G8 — Annuler un commit publié (2 pts)

```bash
sed -i 's/^TOP=3$/TOP=0/' scripts/analyse.sh
git commit -am "Change le top par défaut"
git push
git revert HEAD        # accepter le message proposé
git push               # historique conservé : pas de reset, pas de push --force
```

## G9 — Version signée (2 pts)

```bash
git tag -s v1.0 -m "Version 1.0"
git push origin v1.0
git tag -v v1.0       # vérifie la signature (avec allowed_signers)
gh release create v1.0 rendus/linux_$MATRICULE.tar.gz --title "v1.0" --notes "Première version"
```

Sans `gh` : GitHub → Releases → Draft a new release → tag `v1.0` → joindre l'archive → Publish.

## G10 — Preuves (2 pts)

```bash
git reflog -n 60 > docs/preuves/reflog.txt
history > docs/preuves/historique_git.txt
exit                                   # fin de l'enregistrement (script)
git add docs && git commit -m "Ajoute les preuves de la partie Git" && git push --all && git push --tags
git rev-parse --short HEAD             # → à recopier sur la fiche de contrôle
```

## Vérifications avant de rendre

- `git log --show-signature` : tous les commits « Good signature » ; « Verified » sur GitHub (y compris le tag).
- Aucun « Add files via upload », aucun `push --force` sur `main`.
- `docs/git.md` contient les commandes importantes et la sortie de `git stash list`.
- Le dépôt est privé et `pape1283` est collaborateur.
