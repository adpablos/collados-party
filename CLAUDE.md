# CLAUDE.md — A Pachas (collados-party)

App de una sola página para repartir los gastos de las fiestas de la peña
de Collado Hermoso. Sin build, sin backend, sin dependencias: todo el
producto es `public/index.html` (HTML + CSS + JS vanilla, estado en
`localStorage`; la fiesta se comparte por enlace con el estado en el hash).

## Mapa del repo

- `public/index.html` — la app entera. Cualquier cambio de producto va aquí.
- `docs/diseno.md` — identidad y UI: logo (óculo del monasterio), tokens
  claro/oscuro con hex exactos, tipografía, voz del copy y estructura de
  pantallas. Léelo ANTES de tocar estilos o copy; no inventes colores ni
  registro nuevos.
- `compose.yaml` — stack de servidor (nginx + cloudflared).
- `scripts/deploy.sh` — despliegue desde el Mac en un comando.
- `docs/despliegue.md` — runbook de infraestructura: arquitectura, setup,
  operación, rollback y guardarraíles. Léelo antes de tocar el servidor.

## Reglas

1. Mantener la app en un único fichero autocontenido; no introducir build,
   frameworks ni dependencias salvo que el usuario lo pida explícitamente
   (única excepción ya pactada: Google Fonts, con fallback de sistema).
2. Copy en español de España, registro de pueblo con guasa — ejemplos en
   docs/diseno.md. El rol admin se llama «la llave» en la interfaz.
3. Compatibilidad de datos: la clave de localStorage es `a-pachas-v1` (se
   migran las antiguas `el-bote-proto-*`); los enlaces de invitación usan
   el prefijo `AP1:` y se sigue aceptando el antiguo `EB1:`. No romper
   ninguna de las dos cosas sin migración.
4. El server de despliegue es compartido con la porra del Mundial
   (producción real). No tocar los stacks `current` y `staging`.
5. Las credenciales del túnel de Cloudflare nunca entran en el repo.
6. Verificar antes de dar por hecho: probar en local
   (`python3 -m http.server -d public`) el flujo completo — crear/unirse
   por enlace, lista, compra con precio y consumidores, bizums — y tras
   desplegar comprobar que https://collados.alexdepablos.es responde
   (scripts/deploy.sh ya lo hace).

## Cómo probar

Local: `python3 -m http.server -d public` y abrir `http://localhost:8000`.
Probar en viewport móvil (~390px): la app se usa desde el móvil en la
fiesta. «Ver una fiesta de ejemplo» carga datos de demo. No hay suite de
tests; la verificación es manual en el navegador.
