# 📚 Étude & Révision — Pflegeausbildung (2. Lehrjahr)

Système de préparation aux Klausuren pour la **generalistische Pflegeausbildung** (Pflegefachfrau / Pflegefachmann), avec des agents IA qui lisent tes PDFs et créent du matériel d'apprentissage en **allemand B2**.

## 🗂️ Structure du dépôt

```
PDFs/                     ← Dépose ici tes PDFs de cours (en bloc)
Wissen/                   ← Extractions complètes des PDFs (générées par les agents)
Lernmaterial/             ← Résumés, exercices, Fallbeispiele, Klausuren (générés)
ressources/               ← Conventions des Klausuren allemandes (Operatoren, AFB, Notenschlüssel)
.claude/workflows/        ← Le workflow d'agents « klausur-prep »
```

## 🚀 Comment l'utiliser

1. **Dépose tes PDFs** dans le dossier `PDFs/` (ou envoie-les directement dans la conversation Claude).
2. Dis à Claude : **« Lance le workflow klausur-prep sur mes PDFs »**.
3. Les agents vont :
   - 📖 **Lire** chaque PDF entièrement (texte, images, schémas, photos de texte → OCR)
   - 🗂️ **Catégoriser** tous les contenus par thème (Themenkarte)
   - ✍️ **Résumer** chaque catégorie en allemand B2
   - 🧩 Créer des **exercices interactifs** (Multiple Choice, Zuordnung, Lückentext, offene Fragen avec les Operatoren : *Nennen, Beschreiben, Erklären, Begründen…*)
   - 🏥 Rédiger des **Fallbeispiele** (cas cliniques) avec questions d'examen
   - 📝 Construire des **Klausuren complètes** avec Erwartungshorizont (corrigé) et Notenschlüssel
   - ✅ **Vérifier** la qualité (exactitude médicale + niveau de langue B2)
4. Claude publie ensuite un **Artifact interactif** (page web privée) avec tout le matériel : résumés, quiz cliquables, Fallbeispiele et Klausuren.

## 🎯 Ce que produisent les agents

| Produit | Contenu |
|---|---|
| Zusammenfassung | Résumé structuré par thème, vocabulaire clé (Fachbegriffe) |
| Übungen | Exercices AFB I–III avec les Operatoren allemands |
| Fallbeispiel | Cas clinique réaliste + Aufgaben comme dans une vraie Klausur |
| Klausur | Examen blanc complet, 90 min, avec corrigé et barème |

## 📖 Références

Le fichier `ressources/klausur-konventionen.md` documente comment les Klausuren sont
construites en Allemagne (Operatoren, Anforderungsbereiche I–III, structure des
Fallbeispiele, Notenschlüssel, Zwischenprüfung §7 PflAPrV). Les agents s'en servent
comme guide pour générer des examens réalistes.
