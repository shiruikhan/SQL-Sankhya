SELECT DISTINCT nufin
FROM (
  SELECT nufin FROM JSON_TABLE('{"NUFIN":[101,102,103]}', '$'
    COLUMNS (
      NESTED PATH '$.NUFIN[*]' COLUMNS ( nufin NUMBER PATH '$' )
    )
  )
  UNION ALL
  SELECT nufin FROM JSON_TABLE('[{"NUFIN":201},{"NUFIN":202}]', '$'
    COLUMNS (
      NESTED PATH '$[*]' COLUMNS ( nufin NUMBER PATH '$.NUFIN' )
    )
  )
  UNION ALL
  SELECT JSON_VALUE('{"NUFIN":301}', '$.NUFIN' RETURNING NUMBER) AS nufin FROM dual
  UNION ALL
  SELECT JSON_VALUE('{"evento":{"financeiro":{"NUFIN":560989},"despesas":[{"NUFIN":560989},{"NUFIN":560996}]}}', '$.evento.financeiro.NUFIN' RETURNING NUMBER) AS nufin FROM dual
  UNION ALL
  SELECT jt.nufin FROM JSON_TABLE('{"evento":{"financeiro":{"NUFIN":560989},"despesas":[{"NUFIN":560989},{"NUFIN":560996}]}}', '$.evento.despesas[*]'
    COLUMNS ( nufin NUMBER PATH '$.NUFIN' )
  ) jt
)
WHERE nufin IS NOT NULL
ORDER BY nufin;
/

SELECT DISTINCT nuchq, nufin
FROM (
  SELECT e.nuchq, jt1.nufin
  FROM TGFECQ e
  LEFT JOIN JSON_TABLE(e.detalhe, '$'
    COLUMNS (
      NESTED PATH '$.NUFIN[*]' COLUMNS ( nufin NUMBER PATH '$' )
    )
  ) jt1 ON 1=1
  WHERE e.detalhe IS NOT NULL AND jt1.nufin IS NOT NULL
  UNION ALL
  SELECT e.nuchq, jt2.nufin
  FROM TGFECQ e
  LEFT JOIN JSON_TABLE(e.detalhe, '$'
    COLUMNS (
      NESTED PATH '$[*]' COLUMNS ( nufin NUMBER PATH '$.NUFIN' )
    )
  ) jt2 ON 1=1
  WHERE e.detalhe IS NOT NULL AND jt2.nufin IS NOT NULL
  UNION ALL
  SELECT e.nuchq, JSON_VALUE(e.detalhe, '$.NUFIN' RETURNING NUMBER) AS nufin
  FROM TGFECQ e
  WHERE e.detalhe IS NOT NULL
    AND JSON_VALUE(e.detalhe, '$.NUFIN' RETURNING NUMBER) IS NOT NULL
  UNION ALL
  SELECT e.nuchq, JSON_VALUE(e.detalhe, '$.evento.financeiro.NUFIN' RETURNING NUMBER) AS nufin
  FROM TGFECQ e
  WHERE e.detalhe IS NOT NULL
    AND JSON_VALUE(e.detalhe, '$.evento.financeiro.NUFIN' RETURNING NUMBER) IS NOT NULL
  UNION ALL
  SELECT e.nuchq, jt3.nufin
  FROM TGFECQ e
  LEFT JOIN JSON_TABLE(e.detalhe, '$.evento.despesas[*]'
    COLUMNS ( nufin NUMBER PATH '$.NUFIN' )
  ) jt3 ON 1=1
  WHERE e.detalhe IS NOT NULL AND jt3.nufin IS NOT NULL
)
ORDER BY nuchq, nufin;
/

WITH extr AS (
  SELECT e.nuchq AS nuchq,
         JSON_VALUE(e.detalhe, '$.evento.financeiro.NUFIN' RETURNING NUMBER) AS nufin
  FROM TGFECQ e
  WHERE e.detalhe IS NOT NULL
    AND JSON_VALUE(e.detalhe, '$.evento.financeiro.NUFIN' RETURNING NUMBER) IS NOT NULL
  UNION ALL
  SELECT e.nuchq, jt.nufin
  FROM TGFECQ e
  LEFT JOIN JSON_TABLE(e.detalhe, '$.evento.despesas[*]'
    COLUMNS ( nufin NUMBER PATH '$.NUFIN' )
  ) jt ON 1=1
  WHERE e.detalhe IS NOT NULL AND jt.nufin IS NOT NULL
)
SELECT DISTINCT e.nuchq, ch.numcheque, extr.nufin
FROM TGFECQ e
JOIN extr ON extr.nuchq = e.nuchq
LEFT JOIN TGFCHQ ch ON ch.nuchq = e.nuchq
ORDER BY e.nuchq, ch.numcheque, extr.nufin;
/

WITH extr AS (
  SELECT e.nuchq AS nuchq,
         JSON_VALUE(e.detalhe, '$.evento.financeiro.NUFIN' RETURNING NUMBER) AS nufin
  FROM TGFECQ e
  WHERE e.detalhe IS NOT NULL
    AND JSON_VALUE(e.detalhe, '$.evento.financeiro.NUFIN' RETURNING NUMBER) IS NOT NULL
  UNION ALL
  SELECT e.nuchq, jt.nufin
  FROM TGFECQ e
  LEFT JOIN JSON_TABLE(e.detalhe, '$.evento.despesas[*]'
    COLUMNS ( nufin NUMBER PATH '$.NUFIN' )
  ) jt ON 1=1
  WHERE e.detalhe IS NOT NULL AND jt.nufin IS NOT NULL
)
SELECT DISTINCT e.nuchq, ch.numcheque, extr.nufin, f.nubco
FROM TGFECQ e
JOIN extr ON extr.nuchq = e.nuchq
LEFT JOIN TGFFIN f ON f.nufin = extr.nufin
LEFT JOIN TGFCHQ ch ON ch.nuchq = e.nuchq
ORDER BY e.nuchq, ch.numcheque, extr.nufin, f.nubco;
/
/

WITH extr AS (
  SELECT e.nuchq AS nuchq,
         JSON_VALUE(e.detalhe, '$.evento.financeiro.NUFIN' RETURNING NUMBER) AS nufin
  FROM TGFECQ e
  WHERE e.detalhe IS NOT NULL
    AND JSON_VALUE(e.detalhe, '$.evento.financeiro.NUFIN' RETURNING NUMBER) IS NOT NULL
  UNION ALL
  SELECT e.nuchq, jt.nufin
  FROM TGFECQ e
  LEFT JOIN JSON_TABLE(e.detalhe, '$.evento.despesas[*]'
    COLUMNS ( nufin NUMBER PATH '$.NUFIN' )
  ) jt ON 1=1
  WHERE e.detalhe IS NOT NULL AND jt.nufin IS NOT NULL
)
SELECT DISTINCT e.nuchq, ch.numcheque, f.nubco, mbc.nundoc
FROM TGFECQ e
JOIN extr ON extr.nuchq = e.nuchq
LEFT JOIN TGFFIN f ON f.nufin = extr.nufin
LEFT JOIN TGFMBC mbc ON mbc.nubco = f.nubco
LEFT JOIN TGFCHQ ch ON ch.nuchq = e.nuchq
ORDER BY e.nuchq, ch.numcheque, f.nubco, mbc.nundoc;
/
WITH extr AS (
  SELECT e.nuchq AS nuchq,
         JSON_VALUE(e.detalhe, '$.evento.financeiro.NUFIN' RETURNING NUMBER) AS nufin
  FROM TGFECQ e
  WHERE e.detalhe IS NOT NULL
    AND JSON_VALUE(e.detalhe, '$.evento.financeiro.NUFIN' RETURNING NUMBER) IS NOT NULL
  UNION ALL
  SELECT e.nuchq, jt.nufin
  FROM TGFECQ e
  LEFT JOIN JSON_TABLE(e.detalhe, '$.evento.despesas[*]'
    COLUMNS ( nufin NUMBER PATH '$.NUFIN' )
  ) jt ON 1=1
  WHERE e.detalhe IS NOT NULL AND jt.nufin IS NOT NULL
)
SELECT DISTINCT e.nuchq, ch.numcheque, mbc.numtransf, mbc.numdoc
FROM TGFECQ e
JOIN extr ON extr.nuchq = e.nuchq
LEFT JOIN TGFFIN f ON f.nufin = extr.nufin
LEFT JOIN TGFMBC mbc ON mbc.nubco = f.nubco
LEFT JOIN TGFCHQ ch ON ch.nuchq = e.nuchq
ORDER BY e.nuchq, ch.numcheque, mbc.numtransf, mbc.numdoc;
/
SELECT DISTINCT numtransf
FROM (
  SELECT JSON_VALUE('{"evento":{"tipo":"P","financeiro":{"NUFIN":560991,"RECDESP":1,"VLRDESDOB":20677.95,"VLRBAIXA":20677.95,"VLRCHEQUE":20677.95,"DTNEG":"14/01/2026","DTVENC":"14/01/2026","DHBAIXA":"14/01/2026","CODPARC":10508,"Parceiro.NOMEPARC":"CONTATO AUTO PECAS LTDA","Parceiro.RAZAOSOCIAL":"CONTATO AUTO PECAS LTDA","CODEMP":501,"Empresa.RAZAOSOCIAL":"SPARK ELETRONICA","Empresa.NOMEFANTASIA":"SPARK ELETRONICA","NUMTRANSF":2102,"NUBCO":88200},"conta":{"CODCTABCOINT":503,"DESCRICAO":"CAIXA - PAGAMENTO CHEQUE","CODCTABCO":"99995","CODBCO":998,"Banco.NOMEBCO":"Caixa","CODAGE":"999","AgenciaBancaria.NOMEAGE":"CAIXA - TESOURARIA"},"despesas":[{"NUFIN":560991,"RECDESP":1,"VLRDESDOB":20677.95,"VLRBAIXA":20677.95,"VLRCHEQUE":20677.95,"DTNEG":"14/01/2026","DTVENC":"14/01/2026","DHBAIXA":"14/01/2026","CODPARC":10508,"Parceiro.NOMEPARC":"CONTATO AUTO PECAS LTDA","Parceiro.RAZAOSOCIAL":"CONTATO AUTO PECAS LTDA","CODEMP":501,"Empresa.RAZAOSOCIAL":"SPARK ELETRONICA","Empresa.NOMEFANTASIA":"SPARK ELETRONICA"},{"NUFIN":560996,"RECDESP":-1,"VLRDESDOB":20677.95,"VLRBAIXA":20677.95,"VLRCHEQUE":20677.95,"DTNEG":"01/01/2026","DTVENC":"19/01/2026","DHBAIXA":"19/01/2026","CODPARC":690,"Parceiro.NOMEPARC":"SOCIO 1","Parceiro.RAZAOSOCIAL":"SOCIO 1","CODEMP":501,"Empresa.RAZAOSOCIAL":"SPARK ELETRONICA","Empresa.NOMEFANTASIA":"SPARK ELETRONICA"}]}}',
                    '$.evento.financeiro.NUMTRANSF' RETURNING NUMBER) AS numtransf
  FROM dual
  UNION ALL
  SELECT jt.numtransf
  FROM JSON_TABLE('{"evento":{"tipo":"P","financeiro":{"NUFIN":560991,"RECDESP":1,"VLRDESDOB":20677.95,"VLRBAIXA":20677.95,"VLRCHEQUE":20677.95,"DTNEG":"14/01/2026","DTVENC":"14/01/2026","DHBAIXA":"14/01/2026","CODPARC":10508,"Parceiro.NOMEPARC":"CONTATO AUTO PECAS LTDA","Parceiro.RAZAOSOCIAL":"CONTATO AUTO PECAS LTDA","CODEMP":501,"Empresa.RAZAOSOCIAL":"SPARK ELETRONICA","Empresa.NOMEFANTASIA":"SPARK ELETRONICA","NUMTRANSF":2102,"NUBCO":88200},"conta":{"CODCTABCOINT":503,"DESCRICAO":"CAIXA - PAGAMENTO CHEQUE","CODCTABCO":"99995","CODBCO":998,"Banco.NOMEBCO":"Caixa","CODAGE":"999","AgenciaBancaria.NOMEAGE":"CAIXA - TESOURARIA"},"despesas":[{"NUFIN":560991,"RECDESP":1,"VLRDESDOB":20677.95,"VLRBAIXA":20677.95,"VLRCHEQUE":20677.95,"DTNEG":"14/01/2026","DTVENC":"14/01/2026","DHBAIXA":"14/01/2026","CODPARC":10508,"Parceiro.NOMEPARC":"CONTATO AUTO PECAS LTDA","Parceiro.RAZAOSOCIAL":"CONTATO AUTO PECAS LTDA","CODEMP":501,"Empresa.RAZAOSOCIAL":"SPARK ELETRONICA","Empresa.NOMEFANTASIA":"SPARK ELETRONICA"},{"NUFIN":560996,"RECDESP":-1,"VLRDESDOB":20677.95,"VLRBAIXA":20677.95,"VLRCHEQUE":20677.95,"DTNEG":"01/01/2026","DTVENC":"19/01/2026","DHBAIXA":"19/01/2026","CODPARC":690,"Parceiro.NOMEPARC":"SOCIO 1","Parceiro.RAZAOSOCIAL":"SOCIO 1","CODEMP":501,"Empresa.RAZAOSOCIAL":"SPARK ELETRONICA","Empresa.NOMEFANTASIA":"SPARK ELETRONICA"}]}}',
              '$.evento.despesas[*]'
              COLUMNS ( numtransf NUMBER PATH '$.NUMTRANSF' )) jt
  UNION ALL
  SELECT JSON_VALUE('{"evento":{"tipo":"P","financeiro":{"NUFIN":560991,"RECDESP":1,"VLRDESDOB":20677.95,"VLRBAIXA":20677.95,"VLRCHEQUE":20677.95,"DTNEG":"14/01/2026","DTVENC":"14/01/2026","DHBAIXA":"14/01/2026","CODPARC":10508,"Parceiro.NOMEPARC":"CONTATO AUTO PECAS LTDA","Parceiro.RAZAOSOCIAL":"CONTATO AUTO PECAS LTDA","CODEMP":501,"Empresa.RAZAOSOCIAL":"SPARK ELETRONICA","Empresa.NOMEFANTASIA":"SPARK ELETRONICA","NUMTRANSF":2102,"NUBCO":88200},"conta":{"CODCTABCOINT":503,"DESCRICAO":"CAIXA - PAGAMENTO CHEQUE","CODCTABCO":"99995","CODBCO":998,"Banco.NOMEBCO":"Caixa","CODAGE":"999","AgenciaBancaria.NOMEAGE":"CAIXA - TESOURARIA"},"despesas":[{"NUFIN":560991,"RECDESP":1,"VLRDESDOB":20677.95,"VLRBAIXA":20677.95,"VLRCHEQUE":20677.95,"DTNEG":"14/01/2026","DTVENC":"14/01/2026","DHBAIXA":"14/01/2026","CODPARC":10508,"Parceiro.NOMEPARC":"CONTATO AUTO PECAS LTDA","Parceiro.RAZAOSOCIAL":"CONTATO AUTO PECAS LTDA","CODEMP":501,"Empresa.RAZAOSOCIAL":"SPARK ELETRONICA","Empresa.NOMEFANTASIA":"SPARK ELETRONICA"},{"NUFIN":560996,"RECDESP":-1,"VLRDESDOB":20677.95,"VLRBAIXA":20677.95,"VLRCHEQUE":20677.95,"DTNEG":"01/01/2026","DTVENC":"19/01/2026","DHBAIXA":"19/01/2026","CODPARC":690,"Parceiro.NOMEPARC":"SOCIO 1","Parceiro.RAZAOSOCIAL":"SOCIO 1","CODEMP":501,"Empresa.RAZAOSOCIAL":"SPARK ELETRONICA","Empresa.NOMEFANTASIA":"SPARK ELETRONICA"}]}}',
                '$.NUMTRANSF' RETURNING NUMBER) AS numtransf
  FROM dual
)
WHERE numtransf IS NOT NULL
ORDER BY numtransf;
/

WITH extr AS (
  SELECT e.nuchq AS nuchq,
         JSON_VALUE(e.detalhe, '$.evento.financeiro.NUMTRANSF' RETURNING NUMBER) AS numtransf
  FROM TGFECQ e
  WHERE e.detalhe IS NOT NULL
    AND JSON_VALUE(e.detalhe, '$.evento.financeiro.NUMTRANSF' RETURNING NUMBER) IS NOT NULL
  UNION ALL
  SELECT e.nuchq, jt.numtransf
  FROM TGFECQ e
  LEFT JOIN JSON_TABLE(e.detalhe, '$.evento.despesas[*]'
    COLUMNS ( numtransf NUMBER PATH '$.NUMTRANSF' )
  ) jt ON 1=1
  WHERE e.detalhe IS NOT NULL AND jt.numtransf IS NOT NULL
  UNION ALL
  SELECT e.nuchq,
         JSON_VALUE(e.detalhe, '$.NUMTRANSF' RETURNING NUMBER)
  FROM TGFECQ e
  WHERE e.detalhe IS NOT NULL
    AND JSON_VALUE(e.detalhe, '$.NUMTRANSF' RETURNING NUMBER) IS NOT NULL
)
SELECT DISTINCT e.nuchq, ch.numcheque, extr.numtransf, mbc.numdoc
FROM TGFECQ e
JOIN extr ON extr.nuchq = e.nuchq
LEFT JOIN TGFMBC mbc ON mbc.numtransf = extr.numtransf
LEFT JOIN TGFCHQ ch ON ch.nuchq = e.nuchq
ORDER BY e.nuchq, ch.numcheque, extr.numtransf, mbc.numdoc;
/
