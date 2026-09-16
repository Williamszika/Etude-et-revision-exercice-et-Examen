# Deutsch täglich sur ton iPhone

Guide pour installer l'app sur ton iPhone depuis ton MacBook.

**Pourquoi tu dois le faire toi-même :** Apple n'autorise la compilation iOS que sur
macOS, et la signature exige *ton* compte Apple. Je peux préparer tout le projet — mais
la dernière étape se passe forcément sur ta machine.

---

## Avant de commencer

| Ce qu'il faut | Comment vérifier |
|---|---|
| **Xcode** installé et ouvert **une fois** | Il doit avoir fini « Installing components » |
| **Un identifiant Apple** | Le tien suffit. Pas besoin de payer. |
| **Un câble** entre le Mac et l'iPhone | Le Wi-Fi marche aussi, mais le câble la première fois |

### Les deux chemins possibles

| | Identifiant Apple **gratuit** | Compte développeur **payant** (99 €/an) |
|---|---|---|
| L'app dure | **7 jours**, puis elle refuse de s'ouvrir | **1 an** |
| Pour la remettre | Rebrancher le Mac, rappuyer sur ▶ (2 min) | Pareil, mais une fois par an |
| Combien d'apps | 3 en même temps | 100 |

**Commence par le gratuit.** Si au bout de quelques semaines les 7 jours t'agacent
vraiment, tu paieras à ce moment-là — pas avant.

---

## 1. Installer Flutter sur le Mac

Ouvre le **Terminal** (⌘ + Espace, tape « Terminal »).

```bash
# Homebrew, si tu ne l'as pas déjà
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Flutter et CocoaPods
brew install --cask flutter
brew install cocoapods
```

Vérifie :

```bash
flutter doctor
flutter --version
```

`flutter doctor` doit afficher une coche verte devant **Xcode**. S'il se plaint, il écrit
exactement la commande à lancer — suis-la, c'est fiable.

Flutter 3.35 ou plus récent suffit pour le projet iOS.

---

## 2. Récupérer le projet

```bash
cd ~/Documents
git clone https://github.com/Williamszika/Etude-et-revision-exercice-et-Examen.git
cd Etude-et-revision-exercice-et-Examen
git checkout claude/nursing-exam-prep-workflow-gvn5u0
cd app
flutter pub get
```

---

## 3. Mettre ton compte Apple dans le projet

C'est **la seule étape qui passe par Xcode**, et elle ne se fait qu'une fois.

```bash
open ios/Runner.xcworkspace
```

⚠️ **`Runner.xcworkspace`**, pas `Runner.xcodeproj`. Le fichier blanc, pas le bleu.

Dans Xcode :

1. Colonne de gauche : clique sur **Runner** tout en haut (l'icône bleue)
2. Au centre, onglet **Signing & Capabilities**
3. Coche **Automatically manage signing**
4. **Team** → *Add an Account…* → connecte-toi avec ton identifiant Apple
   → puis choisis ton nom dans la liste
5. **Bundle Identifier** : remplace `de.zika.deutschTaeglich` par quelque chose
   d'unique à toi, par exemple :

   ```
   com.zika.deutschtaeglich
   ```

   *Pourquoi :* Apple refuse deux apps avec le même identifiant dans le monde.
   Avec un compte gratuit, il faut qu'il soit à toi.

Quand le triangle jaune disparaît, c'est bon.

---

## 4. Brancher l'iPhone et lancer

### D'abord : le mode développeur

**Réglages → Confidentialité et sécurité → Mode développeur → activer.**
L'iPhone **redémarre**, puis redemande confirmation avec ton code.

Si l'entrée n'apparaît pas dans la liste : c'est normal, elle ne s'affiche
qu'**après** qu'un Mac ait tenté une première installation. Lance une fois
`flutter run`, redémarre l'iPhone, et regarde à nouveau.

### Ensuite : le câble

Branche l'iPhone, déverrouille l'écran, et réponds **Se fier** à
« Faire confiance à cet ordinateur ? ».

**Le Wi-Fi ne suffit pas pour la première installation.** Flutter doit
interroger l'appareil directement.

```bash
flutter devices
```

L'iPhone doit apparaître **sans** la mention `wireless` et **sans** l'erreur
`code -27`. Si tu vois encore l'une des deux, une des deux étapes ci-dessus
n'est pas faite.

Puis :

```bash
flutter run --release
```

**Compte 5 à 10 minutes la première fois.** Si ça revient en quelques
secondes, c'est que la compilation n'a jamais commencé — voir le tableau
plus bas.

---

## 5. ⚠️ Xcode doit compiler en **Release**, pas en Debug

**C'est le piège qui coûte le plus de temps.** Par défaut, le bouton ▶ d'Xcode
installe la version **Debug**. Or Apple interdit à une app Flutter en Debug de
démarrer depuis l'écran d'accueil : elle s'ouvre blanche, ou affiche

> *In iOS 14+, debug mode Flutter apps can only be launched from Flutter tooling,
> IDEs with Flutter plugins or from Xcode.*

Une app Debug ne fonctionne que tant que le Mac est branché. Inutilisable pour
réviser dans le train.

**À faire une fois :**

1. Menu **Product → Scheme → Edit Scheme…**
2. Colonne de gauche : **Run**, onglet **Info**
3. **Build Configuration** : passe de `Debug` à **`Release`**
4. **Close**, puis **▶**

Depuis le terminal, `flutter run --release` fait la même chose.

Le premier build Release prend 5 à 10 minutes — tout le code Dart est compilé
en natif. C'est justement ce qui rend l'app autonome.

---

## 6. Le dernier obstacle : autoriser le certificat

L'app s'installe mais **refuse de s'ouvrir** la première fois. C'est normal, Apple fait
ça avec tout ce qui ne vient pas de l'App Store.

Sur l'iPhone :

**Réglages → Général → VPN et gestion de l'appareil → *(ton nom)* → Faire confiance**

Ouvre l'app. Ça y est.

---

## Ce qu'il faut savoir ensuite

### La voix allemande

La dictée utilise la voix du téléphone. Si elle sonne anglaise ou ne dit rien :

**Réglages → Accessibilité → Contenu énoncé → Voix → Deutsch** → télécharge une voix

La voix **Anna** (ou **Helena**) en qualité *Améliorée* est nettement meilleure que celle
par défaut. C'est un téléchargement d'environ 100 Mo, une seule fois, et ensuite ça marche
**hors ligne**.

### Les nouvelles leçons arrivent toutes seules

L'app va chercher `deutsch-taeglich/app-daten.json` dans le dépôt à chaque ouverture.
La routine de 5h30 écrit la leçon → tu l'as à l'ouverture suivante.

**Tu n'as pas à recompiler pour avoir une nouvelle leçon.** Tu ne recompiles que si
l'app elle-même change (ou tous les 7 jours, avec le compte gratuit — et toujours en **Release**).

### Au bout de 7 jours (compte gratuit)

L'app affiche une erreur au lancement. Rebranche l'iPhone au Mac et relance les
**deux commandes** de la section « ✅ Le chemin qui a marché » (`xcodebuild` puis
`devicectl`). Deux minutes.

Tes mots cochés et tes réponses **restent** — ils sont dans le téléphone,
pas dans l'app.

---

## Si ça coince

| Message | Ce que ça veut dire |
|---|---|
| **Écran blanc**, ou *« debug mode Flutter apps can only be launched from Flutter tooling »* | L'app a été installée en **Debug**. Passe le scheme en **Release** → étape 5 |
| Tu configures la signature mais rien ne change | Tu es sur la cible **RunnerTests**. Il faut **Runner**, la ligne au-dessus dans TARGETS |
| Le projet n'a pas les bonnes dépendances (google_sign_in, geolocator…) | Tu as ouvert **un autre projet**. Le bon affiche `claude/nursing-exam-prep-workflow…` en haut et n'a que 4 dépendances |
| `Exited with status code 255` en **1 à 4 secondes**, sans autre message | `flutter` cache l'erreur d'Xcode. Lance `xcodebuild` directement, voir « Voir le vrai message » |
| `Exited with status code 255` alors que `xcodebuild` sur `generic/platform=iOS` réussit | Le code va bien, **c'est l'appareil**. Voir « Le test qui sépare le code de l'appareil » |
| `Exited with status code 255` alors qu'`xcodebuild` réussit **même en visant ton iPhone** | La compilation n'est pas en cause : il ne manque que la pose. Installe avec `devicectl` → « Poser l'app sur l'iPhone sans `flutter run` » |
| `The device must be opted into Developer Mode` **(code -27)** | Mode développeur pas activé → étape 4. **Tant que cette ligne apparaît, `flutter run` échouera**, même si la compilation est parfaite par ailleurs |
| `Could not build the precompiled application for the device` + `status code 255` | L'iPhone est en Wi-Fi seulement, ou le mode développeur est éteint. Branche le câble. |
| `flutter_tts does not support Swift Package Manager` | **Simple avertissement**, ça ne bloque rien aujourd'hui |
| `No profiles for 'de.zika.deutschTaeglich' were found` | L'identifiant n'est pas unique → étape 3, point 5 |
| `Signing for "Runner" requires a development team` | Tu as sauté l'étape 3, point 4 |
| `Unable to install` / `device is locked` | Déverrouille l'iPhone et relance |
| `git pull` refusé : *« Ihre lokalen Änderungen … app/analysis_options.yaml »* | C'est **Flutter** qui a modifié ce fichier chez toi (« Upgrading analysis_options.yaml… » pendant `flutter pub get`). Voir juste en dessous. |
| `CocoaPods not installed` | `brew install cocoapods` puis `cd ios && pod install` |
| `Could not find a valid iOS deployment target` | `flutter clean` puis `flutter pub get` |
| L'app se ferme tout de suite | Tu as sauté l'étape 5 (faire confiance au certificat) |

### Quand `git pull` refuse à cause de `analysis_options.yaml`

`flutter pub get` modifie lui-même ce fichier (il ajoute `ios/**` à la liste des
dossiers ignorés par l'analyseur). Git voit alors une modification locale et
refuse de tirer.

**Ce n'est pas ton travail que tu perds** — la ligne que Flutter a ajoutée chez toi
est exactement celle qui est déjà dans le dépôt. Jeter ta version et tirer donne
le même fichier :

```bash
cd ~/Documents/Etude-et-revision-exercice-et-Examen && git checkout -- app/analysis_options.yaml && git pull
```

Une fois ce `git pull` passé, le problème ne revient plus : le fichier du dépôt
contient déjà la ligne, donc `flutter pub get` n'a plus rien à modifier.

### Ne colle jamais une ligne qui commence par `#`

Dans **zsh** (le terminal du Mac), `#` n'est **pas** un commentaire en usage interactif.
Coller `flutter devices   # un commentaire` donne `command not found: #` et le commentaire
part comme argument. Tape les commandes seules.

### Ce que le job GitHub prouve — et ce qu'il ne prouve pas

`.github/workflows/app-bauen.yml` contient un travail `iphone` qui compile l'app pour iOS
sur un Mac chez GitHub à chaque modification.

**Il installe la dernière version stable de Flutter.** Il prouve donc que le code compile
**avec cette version-là** — pas qu'il compile avec la tienne. Si lui est vert et que ça
échoue chez toi, compare d'abord `flutter --version` avant de chercher ailleurs.

## 🔁 Mettre à jour l'app — **une seule commande**

Branche l'iPhone, déverrouille-le, puis :

```bash
bash ~/Documents/Etude-et-revision-exercice-et-Examen/app/aktualisieren.sh
```

Le script fait les cinq étapes dans l'ordre : il récupère le nouveau code,
installe les dépendances, compile en Release, pose l'app sur le téléphone et
te rappelle les deux réglages iPhone à faire.

**Pourquoi il existe.** Le 16.09.2026, `git pull` a été refusé **deux fois** —
d'abord à cause de `analysis_options.yaml`, puis de `pubspec.lock`. Les deux
sont réécrits par `flutter pub get` lui-même. Résultat : l'app a été recompilée
et réinstallée telle quelle, sans les corrections, et rien n'avait changé à
l'écran. Le script écarte ces deux fichiers générés avant de tirer — ton travail
à toi n'est jamais dedans.

Si un jour un **autre** fichier bloque le pull, dis-le moi : je l'ajoute à la
liste plutôt que de te faire deviner.

---

### ✅ Le chemin qui a marché — sans `flutter run`

Le 16.09.2026, après une journée d'essais, c'est **ce chemin-là** qui a mis l'app
sur son iPhone. `flutter run` échouait avec `status code 255` alors que la
compilation, elle, réussissait parfaitement (`** BUILD SUCCEEDED **`, zéro `error:`,
y compris en visant l'iPhone par son identifiant). Autrement dit : l'app était
déjà prête, seule la **pose** manquait. `devicectl`, l'outil d'Apple, la fait
sans passer par Flutter.

**Ce sont aussi les deux commandes à relancer tous les 7 jours** (compte Apple
gratuit), quand l'app refuse de s'ouvrir. Dans cet ordre, iPhone déverrouillé :

```bash
cd ~/Documents/Etude-et-revision-exercice-et-Examen/app/ios && xcodebuild -workspace Runner.xcworkspace -scheme Runner -configuration Release -destination id=00008130-000C45D91E09001C -allowProvisioningUpdates build
```

```bash
xcrun devicectl device install app --device 00008130-000C45D91E09001C ~/Library/Developer/Xcode/DerivedData/Runner-azwaycqbhxqgvcffhqlicyamtdcc/Build/Products/Release-iphoneos/Runner.app
```

La réussite ressemble à ça :

```
App installed:
• bundleID: de.zika.deutschTaeglich
```

Puis **accorde la confiance au certificat** (étape 6) — sans ça l'app se ferme
aussitôt ouverte.

*Si un jour ces chemins ne collent plus :* l'identifiant de l'appareil est celui
que `flutter devices` affiche, et le dossier `Runner-XXXXXX` apparaît dans la
sortie d'`xcodebuild` (cherche `DerivedData/Runner-`). Pour lister ce que
`devicectl` voit : `xcrun devicectl list devices`.

**À retenir :** compiler et installer sont deux choses distinctes. Quand la
compilation passe, ne recommence pas à chercher du côté du code.

### Le test qui sépare « le code » de « l'appareil »

Quand `flutter run` échoue avec `status code 255` sans rien dire d'autre, lance
**deux** compilations et compare. La première ne vise aucun appareil :

```bash
cd ~/Documents/Etude-et-revision-exercice-et-Examen/app/ios && xcodebuild -workspace Runner.xcworkspace -scheme Runner -configuration Release -destination generic/platform=iOS -allowProvisioningUpdates build 2>&1 | tail -5
```

| Ce que tu obtiens | Ce que ça veut dire |
|---|---|
| `** BUILD SUCCEEDED **` ici, mais `flutter run` échoue | Le code et la signature vont bien. **Le problème est l'appareil** : câble, Mode développeur, « Se fier » → étape 4 |
| Échec ici aussi | Le problème est dans le projet ou la signature → étapes 3 et 5 |

**Pourquoi ça marche :** `generic/platform=iOS` compile pour « un iPhone quelconque ».
Viser ton iPhone précis oblige Xcode à inscrire son numéro de série dans ton profil
de signature — et il ne peut le faire que s'il arrive vraiment à lui parler. Un
iPhone joignable seulement en Wi-Fi, avec le Mode développeur éteint, échoue donc
à la signature alors que le code est irréprochable.

Pour voir l'erreur exacte sur **ton** appareil, remplace la destination par son
identifiant (celui que `flutter devices` affiche) :

```bash
cd ~/Documents/Etude-et-revision-exercice-et-Examen/app/ios && xcodebuild -workspace Runner.xcworkspace -scheme Runner -configuration Release -destination id=TON-IDENTIFIANT -allowProvisioningUpdates build 2>&1 | grep -i error | head -30
```

### Voir le vrai message

`flutter run` masque l'erreur d'Xcode. Celle-ci la montre :

Le plus fiable est de contourner `flutter` et d'appeler Xcode directement :

```bash
cd ~/Documents/Etude-et-revision-exercice-et-Examen/app/ios
```

```bash
xcodebuild -workspace Runner.xcworkspace -scheme Runner -configuration Release -destination generic/platform=iOS -allowProvisioningUpdates build 2>&1 | tail -60
```

Copie-moi la sortie **en entier** — avec ça je vois précisément ce qui coince.
