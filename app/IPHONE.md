# Deutsch täglich sur iPhone — avec un Mac et un compte Apple gratuit

Ce document explique **un seul chemin** : installer l'app sur ton iPhone depuis un Mac,
avec ton identifiant Apple normal, **sans payer les 99 €/an**.

Écrit le 19.09.2026, après que tu m'as dit avoir un iPhone.

---

## Avant de commencer — lis ces quatre lignes

| | |
|---|---|
| **L'app s'arrête au bout de 7 jours** | Elle ne disparaît pas, mais elle refuse de s'ouvrir. Il faut rebrancher l'iPhone au Mac et relancer. |
| **Il faut un Mac** | Pas de Mac, pas d'app. Ni Windows, ni iPad, ni le téléphone seul. C'est une règle d'Apple, pas un manque du projet. |
| **Trois apps maximum** | Un compte gratuit peut faire tourner 3 apps signées à la fois. |
| **La première fois est longue** | Xcode fait ~15 Go à télécharger. Compte une soirée. Les fois suivantes : 5 minutes. |

**Si tu n'as pas de Mac, arrête-toi ici** et reste sur Safari → Partager → *Sur l'écran
d'accueil*. Tu y gagnes la voix allemande, tes réponses sauvegardées et une icône sur
l'écran. Tu n'y perds que le hors-ligne.

---

## Ce qu'il te faut

- Un **Mac** (le tien, celui de quelqu'un, celui de l'école — n'importe lequel)
- Ton **iPhone** et son **câble**
- Ton **identifiant Apple** habituel (celui de l'App Store — gratuit, rien à payer)

---

## Étape 1 — Xcode

Sur le Mac : **App Store** → chercher **Xcode** → installer. C'est gratuit et très gros.

Quand c'est fini, ouvre Xcode une fois et accepte la licence. Puis, dans le Terminal :

```bash
sudo xcodebuild -license accept
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
xcodebuild -runFirstLaunch
```

## Étape 2 — Flutter sur le Mac

Dans le Terminal :

```bash
# Homebrew, si tu ne l'as pas :
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew install --cask flutter
brew install cocoapods
flutter doctor
```

`flutter doctor` doit montrer une coche verte devant **Xcode**. S'il manque quelque chose,
il te dit quoi faire — suis ses instructions, elles sont fiables.

## Étape 3 — Récupérer le projet

```bash
git clone https://github.com/Williamszika/Etude-et-revision-exercice-et-Examen.git
cd Etude-et-revision-exercice-et-Examen
git checkout claude/nursing-exam-prep-workflow-gvn5u0
cd app
flutter pub get
```

## Étape 4 — Ton identifiant Apple dans Xcode

Ouvre le projet :

```bash
open ios/Runner.xcworkspace
```

⚠️ **`Runner.xcworkspace`, pas `Runner.xcodeproj`.** Avec le mauvais fichier, rien ne compile.

Dans Xcode :

1. Menu **Xcode → Settings → Accounts** → **+** → **Apple ID** → connecte-toi.
   Ton compte apparaît avec l'équipe **« Ton Nom (Personal Team) »**. C'est elle qu'il faut.
2. Dans la colonne de gauche, clique sur **Runner** (tout en haut, l'icône bleue).
3. Onglet **Signing & Capabilities**.
4. Coche **Automatically manage signing**.
5. **Team** → choisis ton **Personal Team**.
6. **Bundle Identifier** → remplace `de.zika.deutschTaeglich` par quelque chose
   **d'unique à toi**, par exemple `de.zika.deutschtaeglich.bia`.
   *Apple refuse un identifiant déjà pris par quelqu'un d'autre dans le monde.*

Si un carré rouge s'affiche, lis-le : neuf fois sur dix c'est l'identifiant à changer.

## Étape 5 — Brancher et lancer

1. Branche l'iPhone au Mac. Sur le téléphone : **Se fier à cet ordinateur** → ton code.
2. Sur l'iPhone : **Réglages → Confidentialité et sécurité → Mode développeur** → **activer**.
   Le téléphone redémarre. *(iOS 16 et plus. Sur iOS 15, cette étape n'existe pas.)*
3. Dans Xcode, en haut, choisis **ton iPhone** comme destination (pas un simulateur).
4. Appuie sur **▶︎**.

Xcode compile, installe, et lance l'app.

## Étape 6 — La seule étape qui surprend tout le monde

La première fois, l'app s'installe mais **refuse de s'ouvrir** : *« Développeur non fiable »*.

Sur l'iPhone : **Réglages → Général → VPN et gestion de l'appareil** → ton identifiant Apple
→ **Faire confiance**.

Maintenant elle s'ouvre.

---

## Au bout de 7 jours

L'app ne s'ouvre plus. Rien n'est cassé, c'est Apple qui coupe la signature.

Rebranche l'iPhone, ouvre Xcode, appuie sur **▶︎**. Trente secondes. Tes réponses et tes
coches de vocabulaire sont conservées.

**Tu n'as pas besoin de refaire les étapes 1 à 4** — seulement lancer.

---

## Est-ce que ça vaut le coup ?

Franchement : **seulement si le hors-ligne compte beaucoup pour toi.**

| | Safari + écran d'accueil | L'app installée |
|---|---|---|
| Voix allemande (dictée, lecture, prononciation) | ✅ | ✅ |
| Réponses et coches gardées | ✅ | ✅ |
| Nouvelles leçons automatiques | ✅ | ✅ |
| Icône sur l'écran d'accueil | ✅ | ✅ |
| **Fonctionne sans réseau** | ❌ | ✅ |
| À refaire tous les 7 jours | — | ⚠️ oui |
| Il faut un Mac | — | ⚠️ oui |

L'app apporte **une seule chose** : le hors-ligne. Si tu révises dans le métro ou en service
sans réseau, ça change tout. Sinon, Safari suffit largement.

---

## Si ça coince

Envoie-moi **le texte exact** du message d'erreur de Xcode — pas une description, le texte.
Les erreurs de signature se ressemblent toutes et se distinguent sur un mot.

Ce que je **ne** peux **pas** faire d'ici : compiler pour iPhone (il faut macOS) ni signer à ta
place (il faut ton compte). Ce que je peux faire : corriger le code, et il est déjà vérifié —
le contrôle `flutter build ios --release --no-codesign` tourne sur GitHub à chaque modification
et il est au vert.
