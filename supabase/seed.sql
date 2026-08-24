-- ═══════════════════════════════════════════════════════════════════════════
--  VEMAR IMPORTADOS · Datos iniciales (migración del catálogo hardcodeado)
--  Correr DESPUÉS de schema.sql. Idempotente (upsert por id/key).
--  Las imágenes apuntan a las rutas relativas actuales del repo; al subir
--  fotos nuevas desde el panel se reemplazan por URLs de Storage.
-- ═══════════════════════════════════════════════════════════════════════════

-- ── Categorías ──────────────────────────────────────────────────────────────
insert into vemar.categorias (key, name, img_url, img_pos, orden) values
  ('anillos',  'Anillos',  'uploads/anillos.png',  'center 45%', 1),
  ('aros',     'Aros',     'uploads/aros.png',     'center 45%', 2),
  ('cadenas',  'Cadenas',  'Colecciones/Esencial/Cadena%20Sadusa%205mm%20mas%20cruz%20500%20mil.jpeg', 'center 66%', 3),
  ('pulseras', 'Pulseras', 'uploads/pulseras.png', 'center 50%', 4)
on conflict (key) do update set
  name = excluded.name, img_url = excluded.img_url, img_pos = excluded.img_pos, orden = excluded.orden;

-- ── Productos ───────────────────────────────────────────────────────────────
insert into vemar.productos
  (id, sku, name, line, cat, price, img_url, img_alt, material, color, medidas, variants, stock, is_new, tag, description, curated, curated_orden, orden)
values
  ('ve-01','VM-CAD-051','Cadena Sadusa 5 mm con Dije Cruz','Vemar Esencial','cadenas',500000,
   'Colecciones/Esencial/Cadena%20Sadusa%205mm%20mas%20cruz%20500%20mil.jpeg','','Oro laminado 18k','Dorado','5 mm',
   array['Única'], true, true, 'Nuevo',
   'Cadena Sadusa de 5 mm con dije cruz. Presencia marcada y terminación pulida a espejo.', true, 4, 1),

  ('ve-02','VM-PUL-021','Pulsera Sadusa 4 mm · 20 cm','Vemar Esencial','pulseras',255000,
   'Colecciones/Esencial/Pulsera%20Sadusa%2020%20cm%204%20mm%20255mil.jpeg','','Oro laminado 18k','Dorado','20 cm · 4 mm',
   array['20 cm'], true, false, '',
   'Pulsera Sadusa de 4 mm y 20 cm. Cómoda, flexible y versátil para todos los días.', true, 5, 2),

  ('vs-01','VM-CAD-061','Cadena Baiana 3 mm · 45 cm','Vemar Signature','cadenas',0,
   'Colecciones/Signature/Cadena%20Baiana%203mm%2045cm.jpeg','','Oro laminado 18k','Dorado','45 cm · 3 mm',
   array['45 cm'], true, true, 'Nuevo',
   'Cadena Baiana de 3 mm y 45 cm. Tejido elegante de caída fluida.', false, 0, 3),

  ('vs-02','VM-CAD-062','Rosario','Vemar Signature','cadenas',480000,
   'Colecciones/Signature/Rosario%20480.000%20gs.jpeg','','Oro laminado 18k','Dorado','Rosario',
   array['Única'], true, false, 'Destacado',
   'Rosario en oro laminado, pieza devocional de acabado delicado y presencia serena.', true, 0, 4),

  ('vs-03','VM-CAD-063','Cadena Sadusa 4 mm · 45 cm','Vemar Signature','cadenas',0,
   'Colecciones/Signature/Sadusa%204mm%2045%20cm.jpeg','','Oro laminado 18k','Dorado','45 cm · 4 mm',
   array['45 cm'], true, true, 'Nuevo',
   'Cadena Sadusa de 4 mm y 45 cm. Eslabón prolijo y brillo parejo.', false, 0, 5),

  ('vs-04','VM-ANI-021','Anillo Signature','Vemar Signature','anillos',250000,
   'Colecciones/Signature/Anillo%20250mil.jpeg','','Oro laminado 18k','Dorado','Aro estándar',
   array['Única'], true, true, 'Nuevo',
   'Anillo de terminación pulida y presencia refinada.', true, 2, 6),

  ('vs-05','VM-ARO-031','Aros Mariposa','Vemar Signature','aros',125000,
   'Colecciones/Signature/Aro%20mariposa%20125mil.jpeg','','Oro laminado 18k','Dorado','Mariposa',
   array['Única'], true, true, 'Nuevo',
   'Aros con diseño de mariposa, delicados y luminosos.', true, 3, 7),

  ('vs-06','VM-ARO-032','Aros Punto de Luz','Vemar Signature','aros',125000,
   'Colecciones/Signature/Aro%20punto%20luz%20125mil.jpeg','','Oro laminado 18k con circonia','Dorado','Punto de luz',
   array['Única'], true, true, 'Nuevo',
   'Aros punto de luz con piedra central que brilla al moverse.', false, 0, 8),

  ('vs-07','VM-CAD-071','Cadena Grummet 4 mm','Vemar Signature','cadenas',485000,
   'Colecciones/Signature/Cadena%20Grummet%204mm%20485mil%20Pulsera%20Grummet%204mm%20350mil.jpeg','','Oro laminado 18k','Dorado','4 mm',
   array['45 cm'], true, true, 'Nuevo',
   'Cadena Grummet de 4 mm, eslabón firme y brillo parejo.', true, 1, 9),

  ('vs-08','VM-PUL-031','Pulsera Grummet 4 mm','Vemar Signature','pulseras',350000,
   'Colecciones/Signature/Cadena%20Grummet%204mm%20485mil%20Pulsera%20Grummet%204mm%20350mil.jpeg','','Oro laminado 18k','Dorado','4 mm',
   array['Única'], true, false, '',
   'Pulsera Grummet de 4 mm, a juego con la cadena Grummet.', false, 0, 10)
on conflict (id) do update set
  sku=excluded.sku, name=excluded.name, line=excluded.line, cat=excluded.cat, price=excluded.price,
  img_url=excluded.img_url, material=excluded.material, color=excluded.color, medidas=excluded.medidas,
  variants=excluded.variants, stock=excluded.stock, is_new=excluded.is_new, tag=excluded.tag,
  description=excluded.description, curated=excluded.curated, curated_orden=excluded.curated_orden, orden=excluded.orden;

-- ── Conjuntos ───────────────────────────────────────────────────────────────
insert into vemar.conjuntos (id, name, pieces, line, price, img_url, img_pos, material, description, orden) values
  ('conj-grummet','Conjunto Grummet','Cadena + Pulsera','Vemar Signature',750000,
   'Colecciones/Signature/Cadena%20Grummet%204mm%20485mil%20Pulsera%20Grummet%204mm%20350mil.jpeg','center 45%','Oro laminado 18k',
   'Cadena y pulsera Grummet de 4 mm a juego, en oro laminado 18k. Un conjunto con presencia y terminación pareja, pensado para llevarse en dúo.', 1)
on conflict (id) do update set
  name=excluded.name, pieces=excluded.pieces, line=excluded.line, price=excluded.price,
  img_url=excluded.img_url, img_pos=excluded.img_pos, material=excluded.material, description=excluded.description, orden=excluded.orden;

-- Piezas del conjunto (se regeneran para evitar duplicados al re-correr)
delete from vemar.conjunto_items where conjunto_id = 'conj-grummet';
insert into vemar.conjunto_items (conjunto_id, name, price, orden) values
  ('conj-grummet','Cadena Grummet 4 mm', 485000, 1),
  ('conj-grummet','Pulsera Grummet 4 mm', 350000, 2);
