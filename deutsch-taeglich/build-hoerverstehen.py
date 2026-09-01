#!/usr/bin/env python3
"""Baut deutsch-taeglich/hoerverstehen.html.

Die Seite muss die Tonspur selbst enthalten (eine veroeffentlichte Seite darf keine
externen Mediendateien laden). Deshalb wird die verkleinerte MP3 als data:-URI in
hoerverstehen-src.html eingesetzt. Die erzeugte Datei ist gross und liegt nicht im
Git — bei Bedarf einfach neu bauen:

    python3 deutsch-taeglich/build-hoerverstehen.py

Die verkleinerte Tonspur (mono, 22,05 kHz, 40 kbit/s) wurde aus dem Original
deutschb2_uebungstest1.mp3 erzeugt, ohne zu kuerzen oder zu veraendern.
"""

import base64
import pathlib
import sys

HIER = pathlib.Path(__file__).resolve().parent
QUELLE = HIER / "hoerverstehen-src.html"
AUDIO = HIER / "telc-quellen" / "uebungstest" / "hoerverstehen-web.mp3"
ZIEL = HIER / "hoerverstehen.html"

GRENZE = 16 * 1024 * 1024  # Obergrenze der veroeffentlichten Seite


def main() -> int:
    for pfad in (QUELLE, AUDIO):
        if not pfad.exists():
            print(f"fehlt: {pfad}", file=sys.stderr)
            return 1

    vorlage = QUELLE.read_text(encoding="utf-8")
    if "__AUDIO__" not in vorlage:
        print("Platzhalter __AUDIO__ nicht gefunden", file=sys.stderr)
        return 1

    b64 = base64.b64encode(AUDIO.read_bytes()).decode("ascii")
    seite = vorlage.replace("__AUDIO__", b64)
    ZIEL.write_text(seite, encoding="utf-8")

    gross = len(seite.encode("utf-8"))
    print(f"{ZIEL.name}: {gross / 1048576:.2f} MB (Audio {AUDIO.stat().st_size / 1048576:.2f} MB)")
    if gross > GRENZE:
        print("WARNUNG: ueber 16 MB — die Seite laesst sich so nicht veroeffentlichen.",
              file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
