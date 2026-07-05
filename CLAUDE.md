# CLAUDE.md — A Pachas (collados-party)

App de una sola página para repartir los gastos de las fiestas de la peña
de Collado Hermoso. Sin build, sin frameworks, sin dependencias: el
frontend entero es `public/index.html` (HTML + CSS + JS vanilla, estado en
`localStorage`) y el backend entero es `server/api.js` (Node stdlib, un
JSON por fiesta). Las fiestas «en vivo» se comparten por enlace corto
(`#F:id:clave`) contra el API; sin red o sin servidor la app funciona
igual en modo local y los enlaces con el estado embebido (`AP1:`) siguen
sirviendo de copia.

## Mapa del repo

- `public/index.html` — el frontend entero. Cualquier cambio de producto
  va aquí.
- `server/api.js` — el API de fiestas compartidas (crear/leer/guardar con
  revisión). En local sirve también `public/`.
- `docs/producto.md` — LA especificación de producto: diagnóstico,
  decisiones (D1–D7), P0 con criterios de aceptación y backlog P1/P2.
  Léelo antes de añadir o cambiar funcionalidad.
- `docs/diseno.md` — identidad y UI: logo (óculo del monasterio), tokens
  claro/oscuro con hex exactos, tipografía, voz del copy y estructura de
  pantallas. Léelo ANTES de tocar estilos o copy; no inventes colores ni
  registro nuevos.
- `compose.yaml` — stack de servidor (nginx + api + cloudflared).
- `deployment/nginx/default.conf` — nginx: estático + proxy `/api/`.
- `scripts/deploy.sh` — despliegue desde el Mac en un comando.
- `docs/despliegue.md` — runbook de infraestructura: arquitectura, setup,
  operación, rollback y guardarraíles. Léelo antes de tocar el servidor.

## Reglas

1. Mantener frontend y backend en un único fichero autocontenido cada uno;
   no introducir build, frameworks ni dependencias (ni `npm install`)
   salvo que el usuario lo pida explícitamente (única excepción ya
   pactada: Google Fonts, con fallback de sistema).
2. Copy en español de España, registro de pueblo con guasa — ejemplos en
   docs/diseno.md. El rol admin se llama «la llave» en la interfaz.
3. Compatibilidad de datos: la clave de localStorage es `a-pachas-v1` (se
   migran las antiguas `el-bote-proto-*`); los enlaces vivos usan
   `#F:id:clave` (la clave va en el hash a propósito: no llega a logs);
   los enlaces `AP1:` se siguen generando en modo local y se aceptan los
   antiguos `EB1:`; el estado v3 migra a v4 con `migrar()`. No romper
   nada de esto sin migración.
4. El modo local no muere: si el API no responde, la app funciona como
   siempre (localStorage) y avisa sin lenguaje técnico. Nada de «sync»,
   «revisiones» ni «conflictos» en el copy.
5. El server de despliegue es compartido con la porra del Mundial
   (producción real). No tocar los stacks `current` y `staging`.
6. Las credenciales del túnel de Cloudflare nunca entran en el repo. Los
   datos de fiestas viven en el volumen `api-data` y no se loguean.
7. Verificar antes de dar por hecho: probar en local (`node server/api.js`)
   el flujo completo — crear (se pone en vivo), unirse por enlace desde
   «otro móvil», lista, gasto rápido, compra con precio y consumidores,
   bizums, mensajes de compartir — y tras desplegar comprobar que
   https://collados.alexdepablos.es responde (scripts/deploy.sh comprueba
   web y api).

## Cómo probar

Local con fiestas vivas: `node server/api.js` y abrir
`http://localhost:8010` (sirve `public/` y el API juntos; los datos van a
`server/data/`, que está en el gitignore). Solo frontend en modo local:
`python3 -m http.server -d public`. Probar en viewport móvil (~390px): la
app se usa desde el móvil en la fiesta. «Ver una fiesta de ejemplo» carga
la demo (nunca se sube al servidor). Un segundo cliente se simula con
curl contra `/api/fiestas/:id` o abriendo el enlace `#F:...` en otra
pestaña/perfil. No hay suite de tests; la verificación es manual.
