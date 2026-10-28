#!/usr/bin/env bash
# Renderiza o DANFE de teste (../*.jrxml) a partir de um XML de NF-e, sem Sankhya.
# Uso (Git Bash): ./render.sh [xml da nota] [dir de saida]
#   padrao: exemplo-entrega.xml -> saida/
set -euo pipefail

AQUI="$(cd "$(dirname "$0")" && pwd)"
LIBS="$AQUI/../../../../nativo/libs"
JDK="${JDK:-/c/Program Files/Java/jdk1.8.0_202}"
XML="$(realpath "${1:-$AQUI/exemplo-entrega.xml}")"
SAIDA="$(realpath -m "${2:-$AQUI/saida}")"

win() { cygpath -m "$1"; }

CP=""
for j in jasperreports-4.0.0.jar commons-digester-1.7.jar commons-beanutils.jar commons-collections.jar \
         package-repository-client.jar sanutil.jar san-jasper-client-4.35b448.jar barbecue-1.1.jar itext-1.3.1.jar; do
  CP="$CP$(win "$LIBS/$j");"
done
CP="$CP$(win "$JDK/lib/tools.jar")"

mkdir -p "$SAIDA/jasper" "$SAIDA/classes"
rm -f "$SAIDA"/pagina-*.png
"$JDK/bin/javac" -nowarn -encoding UTF-8 -cp "$CP" -d "$(win "$SAIDA/classes")" "$(win "$AQUI/RenderDanfe.java")"

# A JVM roda de dentro de saida/jasper para o principal achar ./danfe_retrato_sub.jasper
cd "$SAIDA/jasper"
"$JDK/bin/java" -Djava.awt.headless=true -cp "$(win "$SAIDA/classes");$CP" \
  RenderDanfe "$(win "$AQUI/..")" "$(win "$XML")" "$(win "$SAIDA")"
