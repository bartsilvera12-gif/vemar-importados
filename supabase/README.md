# Panel de administración Vemar (Supabase)

Schema propio **`vemar`** (nada en `public`). Instancia: `https://api.neura.com.py`.

## Puesta en marcha (una sola vez)

1. **Exponer el schema en PostgREST** — *(lo hacés vos en la infra de Neura)*
   Agregá `vemar` a `PGRST_DB_SCHEMAS` y recargá PostgREST. Ej.:
   ```
   PGRST_DB_SCHEMAS="public, storage, graphql_public, ...(los que ya están)..., vemar"
   ```

2. **Crear el schema, tablas, RLS, grants y bucket**
   En Supabase → **SQL Editor**, pegá y corré `schema.sql`.

3. **Migrar el catálogo actual** (10 productos + conjunto Grummet + 4 categorías)
   En el **SQL Editor**, corré `seed.sql`. Es idempotente (podés re-correrlo).

4. **Usuario admin**
   Ya creaste `admin@vemar.com` en Auth. Asegurate de que tenga contraseña
   (Authentication → Users → el usuario → *Reset/Set password* si hace falta).

## Uso

- **Panel:** `https://<tu-dominio>/admin.html` → login con email + contraseña.
  Pestañas: **Productos · Conjuntos · Categorías**. Crear / editar / borrar,
  subir imágenes (van al bucket `vemar` de Storage), marcar stock, "Nuevo",
  "Mostrar en Home", orden.
- **Sitio público:** lee de `vemar` al cargar. Si Supabase no responde, usa los
  datos locales embebidos como fallback (nunca queda en blanco).

## Notas

- La `anon key` está embebida en el cliente (por diseño); la seguridad la da el
  **RLS**: anon solo lee, escritura solo autenticados.
- Las imágenes migradas apuntan a rutas del repo (`Colecciones/...`); al subir
  una foto nueva desde el panel se reemplazan por URL de Storage.
- **CORS:** si el sitio público (otro dominio) recibiera error CORS al leer,
  habilitá el origin del sitio en la config de la instancia. En pruebas mismo-
  origen no hace falta.
