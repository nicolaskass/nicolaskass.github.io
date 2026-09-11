#!/usr/bin/env bash
# Genera los PDF del CV a partir del HTML.
#
# El HTML es la fuente de verdad: el PDF sale de él aplicando el bloque
# @media print de css/cv.css. Mantener dos fuentes (HTML y LaTeX) garantiza
# que se desincronicen — el mismo problema que el resto del portfolio
# resuelve atando las cosas mecánicamente.
#
# Requisitos:  python3 -m venv .venv && .venv/bin/pip install weasyprint
# Uso:         ./build-pdf.sh

set -euo pipefail
cd "$(dirname "$0")"

PY=".venv/bin/python"
if [ ! -x "$PY" ]; then
    echo "Falta el entorno. Correr:" >&2
    echo "  python3 -m venv .venv && .venv/bin/pip install weasyprint" >&2
    exit 1
fi

render() {
    local src="$1" out="$2" label="$3"
    echo "→ $label"
    "$PY" -m weasyprint "$src" "$out" 2>&1 \
        | grep -viE "cannot fetch|ignored|WARNING: Expected" || true
    if [ ! -s "$out" ]; then
        echo "  ERROR: no se generó $out" >&2
        exit 1
    fi
    echo "  $out — $(du -h "$out" | cut -f1)"

    # Una hoja final con un par de renglones y el pie parece un error de
    # impresión. Acá no se corrige solo (el ajuste automático vive en el
    # panel de T3): se avisa, para recortar o compactar antes de publicar.
    if command -v pdftotext >/dev/null; then
        local paginas ultima
        read -r paginas ultima < <(pdftotext -layout "$out" - | awk '
            BEGIN { RS = "\f" }
            /[^[:space:]]/ {
                c = 0; n = split($0, l, "\n")
                for (i = 1; i <= n; i++) if (l[i] ~ /[^[:space:]]/) c++
                ultima = c; paginas++
            }
            END { print paginas, ultima }')
        echo "  $paginas páginas · última hoja: $((ultima - 1)) renglones"
        if [ "$paginas" -gt 1 ] && [ $((ultima - 1)) -lt 8 ]; then
            echo "  AVISO: la última hoja quedó casi vacía" >&2
        fi
    fi
}

render index.html    nicolas-kass-cv-en.pdf "CV en inglés"
render es/index.html nicolas-kass-cv-es.pdf "CV en español"

echo
echo "Listo. Recordá que las fechas con [[...]] tienen que estar completadas"
echo "antes de publicar: grep -rn '\[\[' index.html es/index.html"
