-- ═══════════════════════════════════════════════════════════════════════════
--  VEMAR IMPORTADOS · Schema del panel de administración
--  Todo vive en el schema `vemar` (nada en `public`).
--  Correr en el SQL Editor de Supabase (api.neura.com.py) con rol admin.
--
--  NOTA: exponer el schema en PostgREST (PGRST_DB_SCHEMAS) lo hacés vos en la
--  infra. Este archivo crea tablas, RLS, GRANTS y el bucket de Storage.
-- ═══════════════════════════════════════════════════════════════════════════

create schema if not exists vemar;

-- ── trigger updated_at ──────────────────────────────────────────────────────
create or replace function vemar.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end $$;

-- ── Categorías ──────────────────────────────────────────────────────────────
create table if not exists vemar.categorias (
  key        text primary key,          -- 'anillos', 'aros', 'cadenas', 'pulseras'
  name       text not null,
  img_url    text        default '',
  img_pos    text        default 'center',
  orden      int         default 0,
  created_at timestamptz default now()
);

-- ── Productos ───────────────────────────────────────────────────────────────
create table if not exists vemar.productos (
  id            text primary key,        -- 've-01', 'vs-02', etc.
  sku           text        default '',
  name          text not null,
  line          text        default '',  -- 'Vemar Esencial' / 'Vemar Signature'
  cat           text        references vemar.categorias(key) on update cascade on delete set null,
  price         bigint      default 0,   -- guaraníes; 0 = "Consultar precio"
  img_url       text        default '',  -- portada (= images[0])
  images        text[]      default '{}',-- galería completa (portada primero)
  img_alt       text        default '',
  material      text        default '',
  color         text        default '',
  medidas       text        default '',
  variants      text[]      default '{}',
  stock         boolean     default true,
  is_new        boolean     default false,
  tag           text        default '',  -- 'Nuevo', 'Destacado', ''
  description   text        default '',
  curated       boolean     default false,  -- aparece en la selección de la home
  curated_orden int         default 0,
  orden         int         default 0,   -- orden en el catálogo
  created_at    timestamptz default now(),
  updated_at    timestamptz default now()
);

-- Si la tabla ya existía sin la columna de galería, agregarla:
alter table vemar.productos add column if not exists images text[] default '{}';

drop trigger if exists trg_productos_updated on vemar.productos;
create trigger trg_productos_updated before update on vemar.productos
  for each row execute function vemar.set_updated_at();

-- ── Conjuntos (sets que se venden como una sola pieza) ───────────────────────
create table if not exists vemar.conjuntos (
  id          text primary key,
  name        text not null,
  pieces      text        default '',    -- 'Cadena + Pulsera'
  line        text        default '',
  price       bigint      default 0,     -- precio del conjunto
  img_url     text        default '',
  img_pos     text        default 'center',
  material    text        default '',
  description text        default '',
  orden       int         default 0,
  created_at  timestamptz default now()
);

-- ── Piezas incluidas en cada conjunto (con su precio individual de referencia) ─
create table if not exists vemar.conjunto_items (
  id          bigint generated always as identity primary key,
  conjunto_id text        references vemar.conjuntos(id) on delete cascade,
  name        text not null,
  price       bigint      default 0,
  orden       int         default 0
);
create index if not exists idx_conjunto_items_conj on vemar.conjunto_items(conjunto_id);

-- ═══════════════════════════════════════════════════════════════════════════
--  GRANTS  (roles estándar de Supabase: anon, authenticated, service_role)
--  anon           → solo lectura (el sitio público)
--  authenticated  → CRUD completo (el panel de admin, logueado)
-- ═══════════════════════════════════════════════════════════════════════════
grant usage on schema vemar to anon, authenticated, service_role;

grant select on all tables in schema vemar to anon;
grant select, insert, update, delete on all tables in schema vemar to authenticated, service_role;

-- La identity column de conjunto_items usa una secuencia:
grant usage, select on all sequences in schema vemar to authenticated, service_role;

-- Que futuras tablas/secuencias hereden los mismos permisos:
alter default privileges in schema vemar grant select on tables to anon;
alter default privileges in schema vemar grant select, insert, update, delete on tables to authenticated, service_role;
alter default privileges in schema vemar grant usage, select on sequences to authenticated, service_role;

-- ═══════════════════════════════════════════════════════════════════════════
--  ROW LEVEL SECURITY
--  Lectura pública (anon) · escritura solo autenticados
-- ═══════════════════════════════════════════════════════════════════════════
alter table vemar.categorias      enable row level security;
alter table vemar.productos       enable row level security;
alter table vemar.conjuntos       enable row level security;
alter table vemar.conjunto_items  enable row level security;

-- categorias
drop policy if exists "vemar_cat_read"  on vemar.categorias;
drop policy if exists "vemar_cat_write" on vemar.categorias;
create policy "vemar_cat_read"  on vemar.categorias for select using (true);
create policy "vemar_cat_write" on vemar.categorias for all to authenticated using (true) with check (true);

-- productos
drop policy if exists "vemar_prod_read"  on vemar.productos;
drop policy if exists "vemar_prod_write" on vemar.productos;
create policy "vemar_prod_read"  on vemar.productos for select using (true);
create policy "vemar_prod_write" on vemar.productos for all to authenticated using (true) with check (true);

-- conjuntos
drop policy if exists "vemar_conj_read"  on vemar.conjuntos;
drop policy if exists "vemar_conj_write" on vemar.conjuntos;
create policy "vemar_conj_read"  on vemar.conjuntos for select using (true);
create policy "vemar_conj_write" on vemar.conjuntos for all to authenticated using (true) with check (true);

-- conjunto_items
drop policy if exists "vemar_conji_read"  on vemar.conjunto_items;
drop policy if exists "vemar_conji_write" on vemar.conjunto_items;
create policy "vemar_conji_read"  on vemar.conjunto_items for select using (true);
create policy "vemar_conji_write" on vemar.conjunto_items for all to authenticated using (true) with check (true);

-- ═══════════════════════════════════════════════════════════════════════════
--  STORAGE  (bucket público para imágenes de productos/conjuntos/categorías)
--  El bucket vive en el schema `storage` (del sistema), no en `public`.
-- ═══════════════════════════════════════════════════════════════════════════
insert into storage.buckets (id, name, public)
values ('vemar', 'vemar', true)
on conflict (id) do update set public = true;

-- Lectura pública del bucket · escritura solo autenticados
drop policy if exists "vemar_storage_read"   on storage.objects;
drop policy if exists "vemar_storage_insert" on storage.objects;
drop policy if exists "vemar_storage_update" on storage.objects;
drop policy if exists "vemar_storage_delete" on storage.objects;

create policy "vemar_storage_read"   on storage.objects for select using (bucket_id = 'vemar');
create policy "vemar_storage_insert" on storage.objects for insert to authenticated with check (bucket_id = 'vemar');
create policy "vemar_storage_update" on storage.objects for update to authenticated using (bucket_id = 'vemar') with check (bucket_id = 'vemar');
create policy "vemar_storage_delete" on storage.objects for delete to authenticated using (bucket_id = 'vemar');
