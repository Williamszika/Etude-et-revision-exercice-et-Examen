#!/usr/bin/env python3
"""Erzeugt mit ElevenLabs echte Sprachaufnahmen zu einer Lektion von Deutsch taeglich.

WARUM DIESES SKRIPT UEBERHAUPT NOETIG IST
-----------------------------------------
Die veroeffentlichte Seite kann ElevenLabs NICHT selbst aufrufen. Eine Artifact-Seite
darf keine Netzanfragen an fremde Server stellen (fetch/XHR sind gesperrt, ohne
Fehlermeldung), und externe Mediendateien darf sie auch nicht laden -- genau deshalb
baut build-hoerverstehen.py die telc-Tonspur als data:-URI in die Seite ein.

Daraus folgt: Ton wird VORHER hier erzeugt und danach in die Seite eingebettet.
Der Schluessel bleibt dabei auf diesem Rechner.

DER SCHLUESSEL GEHOERT NIRGENDWO HIN AUSSER IN DIE UMGEBUNGSVARIABLE
--------------------------------------------------------------------
    export ELEVENLABS_API_KEY='sk_...'
    python3 deutsch-taeglich/elevenlabs-audio.py --datum 2026-09-13

Nicht als Argument uebergeben (steht sonst in der Prozessliste), nicht in eine Datei
im Repo schreiben, nicht in die Seite schreiben. Das Repo ist oeffentlich und die
Seite wird per Link geteilt -- ein Schluessel dort ist ein Schluessel fuer alle.

NICHTS WIRD OHNE AUSDRUECKLICHE FREIGABE VERBRAUCHT
---------------------------------------------------
Ohne --echt rechnet das Skript nur und ruft die Sprachsynthese nicht auf. Es zeigt
Zeichenzahl je Block und, wenn ein Schluessel gesetzt ist, den echten Kontostand.
Erst --echt erzeugt wirklich Ton und verbraucht wirklich Credits.

    # nur rechnen, kostet nichts
    python3 deutsch-taeglich/elevenlabs-audio.py --datum 2026-09-13
    # Stimmen des Kontos anzeigen
    python3 deutsch-taeglich/elevenlabs-audio.py --stimmen
    # wirklich erzeugen, nur das Diktat
    python3 deutsch-taeglich/elevenlabs-audio.py --datum 2026-09-13 \
        --teil diktat --stimme <VOICE_ID> --echt

Die MP3 landen in deutsch-taeglich/audio/<datum>/ und stehen in .gitignore.
"""

from __future__ import annotations

import argparse
import json
import os
import pathlib
import re
import sys

HIER = pathlib.Path(__file__).resolve().parent
LEKTIONEN = HIER / "lektionen"
AUDIO = HIER / "audio"

API = "https://api.elevenlabs.io/v1"
MODELL = "eleven_multilingual_v2"

TEILE = ("diktat", "lesetext", "vokabeln", "leben", "aussprache", "telc")


def sauber(text: str) -> str:
    """Markierungen der Lektionen entfernen -- gesprochen wird der reine Satz."""
    text = re.sub(r"\*\*(.+?)\*\*", r"\1", text or "")
    text = text.replace("**", "").replace("__", "")
    return re.sub(r"\s+", " ", text).strip()


def stuecke(lektion: dict, teil: str) -> list[tuple[str, str]]:
    """(Dateiname ohne Endung, zu sprechender Text) fuer einen Block."""
    raus: list[tuple[str, str]] = []

    if teil == "diktat":
        d = lektion.get("diktat") or {}
        if d.get("text"):
            raus.append(("diktat", sauber(d["text"])))
        for i, s in enumerate(d.get("saetze") or [], 1):
            satz = s.get("satz") if isinstance(s, dict) else s
            if satz:
                raus.append((f"diktat-satz-{i:02d}", sauber(satz)))

    elif teil == "lesetext":
        t = (lektion.get("lesen") or {}).get("text")
        if t:
            raus.append(("lesetext", sauber(t)))

    elif teil == "vokabeln":
        for i, w in enumerate((lektion.get("vokabeln") or {}).get("woerter") or [], 1):
            if w.get("de"):
                raus.append((f"vokabel-{i:02d}", sauber(w["de"])))
            if w.get("beispiel"):
                raus.append((f"vokabel-{i:02d}-beispiel", sauber(w["beispiel"])))

    elif teil == "leben":
        lb = lektion.get("leben") or {}
        for feld in ("dusagst", "duhoerst"):
            for i, z in enumerate(lb.get(feld) or [], 1):
                if z.get("de"):
                    raus.append((f"leben-{feld}-{i:02d}", sauber(z["de"])))
        for i, z in enumerate(lb.get("rettung") or [], 1):
            raus.append((f"leben-rettung-{i:02d}", sauber(z)))

    elif teil == "aussprache":
        a = lektion.get("aussprache") or {}
        if a.get("satz"):
            raus.append(("aussprache", sauber(a["satz"])))
        for i, b in enumerate(a.get("beispiele") or [], 1):
            satz = b.get("de") if isinstance(b, dict) else b
            if satz:
                raus.append((f"aussprache-{i:02d}", sauber(satz)))

    elif teil == "telc":
        t = (lektion.get("telc") or {}).get("text")
        if t:
            raus.append(("telc", sauber(t)))

    return [(name, text) for name, text in raus if text]


def kontostand(schluessel: str) -> dict | None:
    import requests

    try:
        antwort = requests.get(
            f"{API}/user/subscription", headers={"xi-api-key": schluessel}, timeout=30
        )
        antwort.raise_for_status()
        return antwort.json()
    except Exception as fehler:  # Netz, Schluessel, Kontingent -- alles nur berichten
        print(f"  (Kontostand nicht abrufbar: {fehler})", file=sys.stderr)
        return None


def zeige_konto(daten: dict | None) -> None:
    if not daten:
        return
    benutzt = daten.get("character_count")
    grenze = daten.get("character_limit")
    if benutzt is None or grenze is None:
        return
    print(f"  Konto: {benutzt} von {grenze} Zeichen verbraucht, "
          f"noch {grenze - benutzt} uebrig.")


def stimmen_zeigen(schluessel: str) -> int:
    import requests

    antwort = requests.get(f"{API}/voices", headers={"xi-api-key": schluessel}, timeout=30)
    antwort.raise_for_status()
    for stimme in antwort.json().get("voices", []):
        sprachen = (stimme.get("labels") or {}).get("language", "")
        print(f"  {stimme.get('voice_id')}  {stimme.get('name')}  {sprachen}")
    print("\nEine deutschtaugliche Stimme aussuchen und die voice_id an --stimme geben.")
    return 0


def sprechen(schluessel: str, stimme: str, modell: str, text: str, ziel: pathlib.Path) -> None:
    import requests

    antwort = requests.post(
        f"{API}/text-to-speech/{stimme}",
        headers={"xi-api-key": schluessel, "Content-Type": "application/json"},
        json={"text": text, "model_id": modell},
        timeout=180,
    )
    antwort.raise_for_status()
    ziel.write_bytes(antwort.content)


def main() -> int:
    p = argparse.ArgumentParser(description=__doc__,
                                formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("--datum", help="Lektionsdatum, z. B. 2026-09-13")
    p.add_argument("--teil", default="alle", choices=("alle",) + TEILE,
                   help="Welcher Block vertont wird (Voreinstellung: alle)")
    p.add_argument("--stimme", help="voice_id von ElevenLabs")
    p.add_argument("--modell", default=MODELL, help=f"Voreinstellung: {MODELL}")
    p.add_argument("--stimmen", action="store_true", help="Nur die Stimmen des Kontos zeigen")
    p.add_argument("--echt", action="store_true",
                   help="WIRKLICH erzeugen und Credits verbrauchen (sonst nur rechnen)")
    a = p.parse_args()

    schluessel = os.environ.get("ELEVENLABS_API_KEY", "").strip()

    if a.stimmen:
        if not schluessel:
            print("ELEVENLABS_API_KEY ist nicht gesetzt.", file=sys.stderr)
            return 1
        return stimmen_zeigen(schluessel)

    if not a.datum:
        print("Bitte --datum angeben (oder --stimmen).", file=sys.stderr)
        return 1

    pfad = LEKTIONEN / f"{a.datum}.json"
    if not pfad.exists():
        print(f"Lektion fehlt: {pfad}", file=sys.stderr)
        return 1
    lektion = json.loads(pfad.read_text(encoding="utf-8"))

    teile = TEILE if a.teil == "alle" else (a.teil,)
    aufgaben: list[tuple[str, str, str]] = []
    print(f"Lektion {a.datum} — {lektion.get('thema', '')}\n")
    for teil in teile:
        st = stuecke(lektion, teil)
        zeichen = sum(len(t) for _, t in st)
        if st:
            print(f"  {teil:<11} {len(st):>3} Datei(en)  {zeichen:>6} Zeichen")
        aufgaben += [(teil, name, text) for name, text in st]

    gesamt = sum(len(t) for _, _, t in aufgaben)
    print(f"\n  {'GESAMT':<11} {len(aufgaben):>3} Datei(en)  {gesamt:>6} Zeichen")
    print("\n  Ein Zeichen kostet bei ElevenLabs in der Regel ein Credit; wie viel dein\n"
          "  Tarif und dein Modell wirklich abrechnen, sagt dir der Kontostand unten —\n"
          "  geschaetzt wird hier nichts.")

    if schluessel:
        print()
        zeige_konto(kontostand(schluessel))

    if not a.echt:
        print("\n  PROBELAUF — es wurde nichts erzeugt und nichts verbraucht.")
        print("  Zum wirklichen Erzeugen: --stimme <VOICE_ID> --echt")
        return 0

    if not schluessel:
        print("\nELEVENLABS_API_KEY ist nicht gesetzt.", file=sys.stderr)
        return 1
    if not a.stimme:
        print("\nBitte --stimme <VOICE_ID> angeben (Liste: --stimmen).", file=sys.stderr)
        return 1

    ordner = AUDIO / a.datum
    ordner.mkdir(parents=True, exist_ok=True)
    print(f"\n  Erzeuge nach {ordner} …")
    fertig = 0
    for teil, name, text in aufgaben:
        ziel = ordner / f"{name}.mp3"
        if ziel.exists():
            print(f"    schon da, uebersprungen: {ziel.name}")
            continue
        try:
            sprechen(schluessel, a.stimme, a.modell, text, ziel)
        except Exception as fehler:
            print(f"    FEHLER bei {ziel.name}: {fehler}", file=sys.stderr)
            print("    Abbruch — bereits erzeugte Dateien bleiben erhalten.", file=sys.stderr)
            break
        fertig += 1
        print(f"    {ziel.name}  ({len(text)} Zeichen)")

    print(f"\n  {fertig} Datei(en) erzeugt.")
    if schluessel:
        zeige_konto(kontostand(schluessel))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
