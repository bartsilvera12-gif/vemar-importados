#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#  Build estático de Vemar Importados para Hostinger (Apache / public_html)
#  Copia solo lo que el sitio referencia (sin videos/fotos muertas) y agrega
#  el .htaccess. Genera dist/ y vemar-hostinger.zip.
#
#  Uso:  bash build-hostinger.sh
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")"

DIST="dist"
ZIP="vemar-hostinger.zip"

echo "▸ Limpiando $DIST/ ..."
rm -rf "$DIST" "$ZIP"
mkdir -p "$DIST"

echo "▸ Copiando archivos base ..."
cp index.html admin.html support.js favicon.svg "$DIST"/

echo "▸ Copiando carpetas de imágenes referenciadas ..."
# Colecciones/ e images/ son livianas → se copian enteras.
cp -r Colecciones "$DIST"/
cp -r images "$DIST"/

echo "▸ Copiando solo los archivos de uploads/ que el sitio usa ..."
mkdir -p "$DIST/uploads"
# Lista de archivos de uploads/ realmente referenciados en el HTML (evita los
# videos pesados sin usar: hero.mp4, hero2.MP4, hero-web.mp4, etc.)
UPLOADS=$(grep -ohE "uploads/[A-Za-z0-9._%-]+" index.html admin.html | sort -u | sed 's#uploads/##')
for f in $UPLOADS; do
  if [ -f "uploads/$f" ]; then
    cp "uploads/$f" "$DIST/uploads/"
    echo "   + uploads/$f"
  else
    echo "   ! FALTA uploads/$f (referenciado pero no existe)"
  fi
done

echo "▸ Escribiendo .htaccess ..."
cat > "$DIST/.htaccess" <<'HTACCESS'
# ── Vemar Importados · configuración Apache (Hostinger) ──────────────────────
Options -Indexes
DirectoryIndex index.html

# Forzar HTTPS
<IfModule mod_rewrite.c>
  RewriteEngine On
  RewriteCond %{HTTPS} off
  RewriteCond %{HTTP:X-Forwarded-Proto} !https
  RewriteRule ^ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]
</IfModule>

# Compresión de texto
<IfModule mod_deflate.c>
  AddOutputFilterByType DEFLATE text/html text/css text/plain text/xml \
    application/javascript application/json image/svg+xml
</IfModule>

# Caché de estáticos (el HTML se mantiene fresco para ver cambios al re-subir)
<IfModule mod_expires.c>
  ExpiresActive On
  ExpiresByType text/css              "access plus 1 month"
  ExpiresByType application/javascript "access plus 1 month"
  ExpiresByType image/jpeg            "access plus 1 year"
  ExpiresByType image/png             "access plus 1 year"
  ExpiresByType image/svg+xml         "access plus 1 year"
  ExpiresByType image/webp            "access plus 1 year"
  ExpiresByType video/mp4             "access plus 1 year"
  ExpiresByType text/html             "access plus 0 seconds"
</IfModule>

<IfModule mod_headers.c>
  <FilesMatch "\.html$">
    Header set Cache-Control "no-cache, must-revalidate"
  </FilesMatch>
</IfModule>

# Tipos MIME correctos
<IfModule mod_mime.c>
  AddType application/javascript .js
  AddType image/svg+xml          .svg
  AddType video/mp4              .mp4
</IfModule>

# App de una sola página (routing por hash): rutas desconocidas → index
ErrorDocument 404 /index.html
HTACCESS

echo "▸ Comprimiendo → $ZIP ..."
( cd "$DIST" && zip -qr "../$ZIP" . -x ".DS_Store" )

echo ""
echo "✅ Listo."
du -sh "$DIST" | sed 's/^/   dist:  /'
du -h  "$ZIP" | sed 's/^/   zip:   /'
echo ""
echo "   Subí el CONTENIDO de dist/ (o descomprimí el zip) dentro de public_html."
