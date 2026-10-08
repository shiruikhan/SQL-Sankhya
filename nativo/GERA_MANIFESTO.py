# Regenera nativo/MANIFESTO.csv varrendo functions/, packages/, procedures/, tables/ e triggers/.
# Uso: python nativo/GERA_MANIFESTO.py   (rodar após cada recaptura; data lida do cabeçalho "Capturado do banco em dd/mm/aaaa")
import os,re,csv,sys
root=sys.argv[1] if len(sys.argv)>1 else os.path.dirname(os.path.abspath(__file__))
TIPOS=[('functions','FUNCTION'),('packages','PACKAGE_SPEC'),('procedures','PROCEDURE'),('tables','TABLE'),('triggers','TRIGGER')]
DEFAULT={'tables':'18/09/2026'}  # tabelas: data registrada no README do catálogo, não no arquivo
rows=[]
for d,tipo in TIPOS:
    for f in sorted(os.listdir(os.path.join(root,d))):
        if f.lower() in ('readme.md','tabelas_faltantes.md'): continue
        p=os.path.join(root,d,f)
        raw=open(p,'rb').read()
        try: t=raw.decode('utf-8')
        except UnicodeDecodeError: t=raw.decode('latin-1')
        m=re.search(r'[Cc]apturad[oa][^\n]{0,60}?(\d{2}/\d{2}/\d{4})',t)
        data=m.group(1) if m else DEFAULT.get(d,'')
        nome=os.path.splitext(f)[0]
        sub=tipo
        rows.append([sub,nome,f'{d}/{f}',data,len(t.splitlines())])
rows.sort(key=lambda r:(r[0],r[1]))
out=os.path.join(root,'MANIFESTO.csv')
with open(out,'w',encoding='utf-8',newline='') as fh:
    w=csv.writer(fh,lineterminator='\n'); w.writerow(['tipo','objeto','arquivo','capturado_em','linhas']); w.writerows(rows)
from collections import Counter
c=Counter((r[0],r[3]) for r in rows); 
for k,v in sorted(c.items()): print(k,v)
print(len(rows))
