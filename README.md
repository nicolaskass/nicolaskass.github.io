# nicolaskass.github.io

CV personal, publicado con GitHub Pages en https://nicolaskass.github.io

- `index.html` — versión en inglés
- `es/index.html` — versión en español
- `css/cv.css` — estilos compartidos, con el bloque `@media print` que produce el PDF
- `build-pdf.sh` — genera los dos PDF desde el HTML

**El HTML es la fuente de verdad.** El PDF se deriva de él aplicando el CSS de
impresión; no hay una segunda fuente en LaTeX que pueda desincronizarse.

```bash
python3 -m venv .venv && .venv/bin/pip install weasyprint
./build-pdf.sh
```

Antes de publicar cambios, verificar que no queden marcadores sin completar:

```bash
grep -rn '\[\[' index.html es/index.html
```
