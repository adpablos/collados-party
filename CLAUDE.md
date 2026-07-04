# CLAUDE.md — El Bote (collados-party)

App de una sola página para repartir gastos de fiestas entre la peña. Sin
build, sin backend, sin dependencias: todo el producto es `public/index.html`
(HTML + CSS + JS vanilla, estado en `localStorage` del navegador).

## Mapa del repo

- `public/index.html` — la app entera. Cualquier cambio de producto va aquí.
- `compose.yaml` — stack de servidor (nginx + cloudflared).
- `scripts/deploy.sh` — despliegue desde el Mac en un comando.
- `docs/despliegue.md` — runbook completo: arquitectura, setup, operación,
  rollback y guardarraíles. Léelo antes de tocar nada de infraestructura.

## Reglas

1. Mantener la app en un único fichero autocontenido; no introducir build,
   frameworks ni dependencias salvo que el usuario lo pida explícitamente.
2. Copy de cara al usuario en español de España, registro cercano (es una
   app entre amigos, no un producto corporativo).
3. El server de despliegue es compartido con la porra del Mundial (producción
   real). No tocar los stacks `current` y `staging` ni sus ficheros. Detalle
   en docs/despliegue.md.
4. Las credenciales del túnel de Cloudflare nunca entran en el repo.
5. Verificar antes de dar por hecho: tras desplegar, comprobar que
   `https://collados.alexdepablos.es` responde (scripts/deploy.sh ya lo hace).

## Cómo probar

Local: abrir `public/index.html` en el navegador, o
`python3 -m http.server -d public` y visitar `http://localhost:8000`.
No hay suite de tests; la verificación es manual en el navegador (probar en
viewport móvil: la app se usa desde el móvil en la fiesta).
