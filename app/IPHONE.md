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
```

Il doit afficher une coche verte devant **Xcode**. S'il se plaint, il écrit exactement
la commande à lancer — suis-la, c'est fiable.

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

## 5. Le dernier obstacle : autoriser le certificat

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
l'app elle-même change (ou tous les 7 jours, avec le compte gratuit).

### Au bout de 7 jours (compte gratuit)

L'app affiche une erreur au lancement. Rebranche l'iPhone au Mac :

```bash
cd ~/Documents/Etude-et-revision-exercice-et-Examen/app
git pull
flutter run --release
```

Deux minutes. Tes mots cochés et tes réponses **restent** — ils sont dans le téléphone,
pas dans l'app.

---

## Si ça coince

| Message | Ce que ça veut dire |
|---|---|
| `The device must be opted into Developer Mode` **(code -27)** | Mode développeur pas activé → étape 4 |
| `Could not build the precompiled application for the device` + `status code 255`, revenu en quelques secondes | L'iPhone est en Wi-Fi seulement, ou le mode développeur est éteint. Branche le câble. |
| `flutter_tts does not support Swift Package Manager` | **Simple avertissement**, ça ne bloque rien aujourd'hui |
| `No profiles for 'de.zika.deutschTaeglich' were found` | L'identifiant n'est pas unique → étape 3, point 5 |
| `Signing for "Runner" requires a development team` | Tu as sauté l'étape 3, point 4 |
| `Unable to install` / `device is locked` | Déverrouille l'iPhone et relance |
| `CocoaPods not installed` | `brew install cocoapods` puis `cd ios && pod install` |
| `Could not find a valid iOS deployment target` | `flutter clean` puis `flutter pub get` |
| L'app se ferme tout de suite | Tu as sauté l'étape 5 (faire confiance au certificat) |

**Le code lui-même est vérifié.** Le fichier `.github/workflows/app-bauen.yml` contient
un travail `iphone` qui compile l'app pour iOS sur un Mac chez GitHub à chaque
modification. S'il est vert et que ça échoue chez toi, le problème vient de Xcode ou de
la signature — pas du code. Regarde le tableau ci-dessus.

### Voir le vrai message

`flutter run` masque l'erreur d'Xcode. Celle-ci la montre :

```bash
flutter build ios --release 2>&1 | tail -40
```

Copie-moi la sortie **en entier** — avec ça je vois précisément ce qui coince.
