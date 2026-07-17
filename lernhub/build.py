#!/usr/bin/env python3
"""Construit lernhub/index.html à partir du contenu de Lernmaterial/ (résumés, quiz, exercices…)."""
import os, json, re
BASE='Lernmaterial'
TITLES={
 '01-beobachtung-wahrnehmung':'Beobachtung & Wahrnehmung','02-bewusstseins-und-denkstoerungen':'Bewusstseins- & Denkstörungen',
 '03-vitalzeichen':'Vitalzeichen (Puls, RR, Temperatur, Atmung)','04-haut-und-hauterkrankungen':'Haut & Hauterkrankungen',
 '05-bewegung-sturz-mobilitaet':'Bewegung, Sturz & Mobilität','06-bewegungsapparat-anatomie':'Bewegungsapparat & Anatomie',
 '07-herz-kreislauf-thrombose':'Herz-Kreislauf & Thrombose','08-harn-kontinenz-katheter':'Harn, Kontinenz & Katheter',
 '09-stuhl-laxanzien':'Ausscheidung: Stuhl & Laxanzien','10-ernaehrung-fluessigkeit':'Ernährung & Flüssigkeit',
 '11-injektionen':'Injektionen (s.c. / i.m.)','12-koerper-mund-zahnpflege':'Körper-, Mund- & Zahnpflege','13-pflegeprozess-recht':'Pflegeprozess & Recht',
}
def load_quiz(p):
    if os.path.exists(p):
        try:
            d=json.load(open(p,encoding='utf-8'))
            if isinstance(d,list) and d: return d
        except: pass
    return None

themes=[]
for d in sorted(x for x in os.listdir(BASE) if os.path.isdir(os.path.join(BASE,x)) and re.match(r'\d\d-',x)):
    files={}
    for key in ['zusammenfassung','uebungen','fallbeispiel','klausur']:
        p=os.path.join(BASE,d,key+'.md')
        if os.path.exists(p): files[key]=open(p,encoding='utf-8').read()
    t={'id':d,'title':TITLES.get(d,d),'partial':not all(k in files for k in ['zusammenfassung','uebungen','fallbeispiel','klausur']),'files':files}
    q=load_quiz(os.path.join(BASE,d,'quiz.json'))
    if q: t['quiz']=q
    themes.append(t)

# entrée « quiz mélangé »
themes.append({'id':'mix','title':'Zufalls-Quiz (alle Themen)','special':True,'mixquiz':True,'partial':False,'files':{}})

def add_special(fname,key,title,quizfile=None):
    p=os.path.join(BASE,fname)
    if os.path.exists(p):
        t={'id':fname,'title':title,'special':True,'partial':False,'files':{key:open(p,encoding='utf-8').read()}}
        if quizfile:
            q=load_quiz(os.path.join(BASE,quizfile))
            if q: t['quiz']=q
        themes.append(t)
add_special('00-probeklausur.md','klausur','Probeklausur (alle Themen, 90 Min)','00-probeklausur-quiz.json')
add_special('00-lernplan.md','zusammenfassung','Lernplan & Lerntipps')

data=json.dumps(themes,ensure_ascii=False).replace('</','<\\/')
out=open('lernhub/_template.html',encoding='utf-8').read().replace('__DATA__',data)
open('lernhub/index.html','w',encoding='utf-8').write(out)
qn=sum(len(t.get('quiz',[])) for t in themes)
print("entrées:",len(themes),"| avec quiz:",sum(1 for t in themes if t.get('quiz')),"| questions:",qn,"| HTML:",round(len(out)/1024),"KB")
