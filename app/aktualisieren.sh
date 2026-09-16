#!/bin/bash
# Deutsch täglich — aktualisieren und aufs iPhone spielen.
#
# Ein Befehl statt vier. Der Grund, warum es diesen Skript gibt:
#
#   `flutter pub get` schreibt `pubspec.lock` und `analysis_options.yaml`
#   selbst um. Git sieht dann lokale Änderungen und **verweigert den Pull** —
#   am 16.09.2026 gleich zweimal, und beide Male hat sie danach die alte
#   Fassung neu gebaut und sich gewundert, dass sich nichts geändert hat.
#   Diese Dateien erzeugt das Werkzeug; ihre eigene Arbeit steckt nie darin.
#   Also werden sie vor dem Pull verworfen.
#
#   Und `flutter run` kam auf ihrem Mac nie durch (status code 255), obwohl
#   `xcodebuild` sauber baut. Deshalb hier der Weg, der funktioniert:
#   xcodebuild + devicectl.
#
# Aufruf:   bash app/aktualisieren.sh
# Anderes Gerät:  GERAET=<UDID> bash app/aktualisieren.sh

set -euo pipefail

GERAET="${GERAET:-00008130-000C45D91E09001C}"
ZWEIG="claude/nursing-exam-prep-workflow-gvn5u0"

# Immer vom Ort dieses Skripts aus arbeiten, egal wo sie gerade steht.
APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$APP_DIR/.." && pwd)"

sag() { printf '\n\033[1m▸ %s\033[0m\n' "$1"; }

sag "1/5 · Neuen Stand holen"
cd "$REPO"
# Nur die vom Werkzeug erzeugten Dateien zurücksetzen — nichts anderes.
for erzeugt in app/pubspec.lock app/analysis_options.yaml; do
  if ! git diff --quiet -- "$erzeugt" 2>/dev/null; then
    echo "   $erzeugt wurde von Flutter geändert — wird verworfen"
    git checkout -- "$erzeugt"
  fi
done
git pull origin "$ZWEIG"

sag "2/5 · Abhängigkeiten"
cd "$APP_DIR"
flutter pub get

sag "3/5 · Bauen (Release) — das dauert ein paar Minuten"
cd "$APP_DIR/ios"
xcodebuild -workspace Runner.xcworkspace -scheme Runner \
  -configuration Release -destination "id=$GERAET" \
  -allowProvisioningUpdates build

# Den Pfad zur fertigen App fragen statt raten: der Ordnername in DerivedData
# enthält einen Hash, der sich ändern kann.
FERTIG="$(xcodebuild -workspace Runner.xcworkspace -scheme Runner \
  -configuration Release -destination "id=$GERAET" -showBuildSettings 2>/dev/null \
  | awk -F' = ' '/ BUILT_PRODUCTS_DIR = /{print $2; exit}')"

if [ -z "${FERTIG:-}" ] || [ ! -d "$FERTIG/Runner.app" ]; then
  echo "Die gebaute App wurde nicht gefunden (gesucht in: ${FERTIG:-unbekannt})." >&2
  exit 1
fi

sag "4/5 · Aufs iPhone spielen"
echo "   $FERTIG/Runner.app"
xcrun devicectl device install app --device "$GERAET" "$FERTIG/Runner.app"

sag "5/5 · Fertig"
cat <<'ENDE'
   Öffne Deutsch täglich auf dem iPhone.

   Beim allerersten Mal nach einer neuen Signatur:
   Einstellungen → Allgemein → VPN und Geräteverwaltung → deinen Namen
   → Vertrauen.

   Für die Diktate braucht das Telefon die deutsche Stimme:
   Einstellungen → Bedienungshilfen → Gesprochene Inhalte → Stimmen
   → Deutsch → Anna (Erweitert).
ENDE
