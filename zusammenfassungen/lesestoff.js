// Holt den Text jeder Zusammenfassung ins Buch „Meine Kurse“ — ihr Wunsch vom 04.11.2026:
// „Ich kann nicht diese Link öffnen in diesem Buch … alles wieder in dem Buch, damit ich die
// Zusammenfassung in dem Buch lesen kann.“
//
// Jede Zusammenfassung wird in Chromium geöffnet (damit auch Teile, die ein Skript erst aufbaut,
// dabei sind), dann werden ihr Inhalt und ihr CSS abgeschrieben:
//   · CSS auf „#zfansicht .zfl“ eingegrenzt, Dunkelmodus und Druck weg, fixed/sticky → static,
//     bei body/html/:root bleiben nur Farben, Schrift und Variablen (kein Seitenrand, keine Breite)
//   · Skripte, Stile, Links im Kopf fallen weg; ids bekommen ein Präfix, #-Links werden mitgezogen
//   · relative Links (PDFs im Repo) zeigen auf GitHub
// Ergebnis: zusammenfassungen/lesestoff.json — build.py nimmt es von dort, ohne Chromium.
//
//   node zusammenfassungen/lesestoff.js          (nach jeder neuen oder geänderten Zusammenfassung)
const {chromium} = require('playwright');
const fs = require('fs'), path = require('path');
const REPO = path.dirname(__dirname);
const GH = 'https://github.com/Williamszika/Etude-et-revision-exercice-et-Examen/blob/claude/nursing-exam-prep-workflow-gvn5u0/';

// Kurse ohne zusammenfassung.html: welche Datei im Ordner das Lesestück ist (nach <title> geprüft)
const DATEI = {
  'asthma-bronchiale': 'schulung-asthma/asthma.html',
  'impfkalender-2026': 'schulung-impfungen/impfkalender.html',
  'staatliche-abschlusspruefung': 'examen-abschluss/examen.html',
  'ezia-projekt': 'schulung-ezia-projekt/projekt.html',
  'zwischenpruefung': 'schulung-zwischenpruefung/ablauf.html',
  'demenz': 'schulung-demenz/vorbereitung.html',
  'pflegeplanung-fuenf-tage': 'schulung-pflegeplanung/planung.html',
  'pflegeplanung': 'schulung-pflegeplanung/index.html',
  'lebensentwuerfe': 'schulung-lebensentwuerfe/index.html',
};

(async () => {
  const daten = JSON.parse(fs.readFileSync(path.join(REPO, 'schulungen/schulungen.json'), 'utf8'));
  const b = await chromium.launch();
  const ctx = await b.newContext({colorScheme: 'light', viewport: {width: 900, height: 1200}});
  const aus = {};
  for (const s of daten.schulungen) {
    let rel = DATEI[s.id] || (s.ordner ? s.ordner + '/zusammenfassung.html' : null);
    if (!rel || !fs.existsSync(path.join(REPO, rel))) { console.log('  –', s.id, '(keine Datei)'); continue; }
    const p = await ctx.newPage();
    await p.goto('file://' + path.join(REPO, rel));
    await p.waitForTimeout(400);
    const r = await p.evaluate(({praefix, repo, gh}) => {
      const SCOPE = '#zfansicht .zfl';
      // ---- CSS ----
      const teile = sel => { const out = []; let d = 0, akt = '';
        for (const c of sel) { if (c === '(' || c === '[') d++; else if (c === ')' || c === ']') d--;
          if (c === ',' && d === 0) { out.push(akt.trim()); akt = ''; } else akt += c; }
        if (akt.trim()) out.push(akt.trim()); return out; };
      const WURZEL = /^(?::root|html|body)(?![\w-])((?:\[[^\]]*\]|:not\([^)]*\)|\.[\w-]+)*)\s*/;
      const BEHALTEN = /^(--|color$|font|line-height|letter-spacing|text-rendering|-webkit-font-smoothing)/;
      function regel(r) {
        if (r.type === 1) {
          const sels = [];
          let nurWurzel = true;
          for (let x of teile(r.selectorText)) {
            if (/data-theme[^\]]*dark/.test(x) || /\.dark\b/.test(x)) continue;
            x = x.replace(/\[data-theme[^\]]*\]/g, '').replace(/:not\(\s*\)/g, '');
            let m;
            // „html body .x“ oder „body > main“: Wurzel-Token vorn abschneiden
            while ((m = x.match(WURZEL)) && m[0].length) { x = x.slice(m[0].length).replace(/^>\s*/, ''); if (!x) break; }
            if (!x) sels.push(SCOPE); else { nurWurzel = false; sels.push(SCOPE + ' ' + x); }
          }
          if (!sels.length) return '';
          // cssText statt Einzelwerte: Kurzschreibweisen mit var() bleiben sonst leer
          let decl = r.style.cssText;
          if (nurWurzel) decl = decl.split(/;(?![^(]*\))/).map(x => x.trim()).filter(x => x && BEHALTEN.test(x.split(':')[0].trim())).join(';');
          decl = decl.replace(/position\s*:\s*(fixed|sticky)/g, 'position:static');
          if (!decl) return '';
          return sels.join(',') + '{' + decl + '}';
        }
        if (r.type === 4) { // @media
          const m = r.media.mediaText;
          if (/prefers-color-scheme:\s*dark|print/.test(m)) return '';
          const innen = [...r.cssRules].map(regel).join('');
          return innen ? '@media ' + m + '{' + innen + '}' : '';
        }
        if (r.type === 5 || r.type === 7) return r.cssText; // @font-face, @keyframes
        if (r.type === 12) { const innen = [...r.cssRules].map(regel).join(''); return innen ? '@supports ' + r.conditionText + '{' + innen + '}' : ''; }
        return '';
      }
      let css = '';
      for (const sh of document.styleSheets) { let rs; try { rs = sh.cssRules; } catch (e) { continue; } for (const r of rs) css += regel(r); }
      // ---- Inhalt ----
      const body = document.body.cloneNode(true);
      body.querySelectorAll('script,style,link,noscript,template,meta,title').forEach(e => e.remove());
      body.querySelectorAll('[id]').forEach(e => e.id = praefix + e.id);
      body.querySelectorAll('label[for]').forEach(e => e.htmlFor = praefix + e.htmlFor);
      body.querySelectorAll('[aria-controls]').forEach(e => e.setAttribute('aria-controls', praefix + e.getAttribute('aria-controls')));
      body.querySelectorAll('[onclick],[onchange],[oninput]').forEach(e => { e.removeAttribute('onclick'); e.removeAttribute('onchange'); e.removeAttribute('oninput'); });
      body.querySelectorAll('a[href]').forEach(a => {
        const h = a.getAttribute('href');
        if (h.startsWith('#')) { a.setAttribute('href', h.length > 1 ? '#' + praefix + h.slice(1) : '#'); return; }
        if (a.href.startsWith('file://')) {
          const p = decodeURIComponent(a.href.replace('file://', '')).split('#')[0];
          if (p.startsWith(repo + '/')) a.href = gh + p.slice(repo.length + 1);
        }
        a.target = '_blank'; a.rel = 'noopener';
      });
      return {css, html: body.innerHTML.replace(/\n\s*\n+/g, '\n'), titel: document.title};
    }, {praefix: 'z-' + s.id + '-', repo: REPO, gh: GH});
    await p.close();
    aus[s.id] = {datei: rel, titel: r.titel, css: r.css, html: r.html};
    console.log('  ✓', s.id.padEnd(34), rel.padEnd(46), Math.round((r.css.length + r.html.length) / 1024) + ' KB');
  }
  await b.close();
  fs.writeFileSync(path.join(__dirname, 'lesestoff.json'), JSON.stringify(aus));
  console.log('OK  ' + Object.keys(aus).length + ' Zusammenfassungen -> zusammenfassungen/lesestoff.json');
})();
