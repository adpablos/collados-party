# A Pachas

Los gastos de la peña, a partes iguales. Ni pa ti ni pa mí.

**En producción:** https://collados.alexdepablos.es

Apuntáis la lista de la compra de la fiesta, cada uno se pide lo que trae,
se apunta lo que costó (o un gasto directo: «he pillado hielo, 6 €») y
quiénes lo catan, y A Pachas saca los bizums mínimos para quedar en paz.

Se comparte por enlace al grupo de WhatsApp, sin cuentas ni registros: la
fiesta vive en el servidor y todos los móviles ven y editan la misma. Sin
red, la app sigue funcionando en local y sube los cambios sola al volver.

Es un frontend de una sola página (`public/index.html`) y un API de un
solo fichero (`server/api.js`, Node sin dependencias). El logo y la
identidad salen del óculo del monasterio de Santa María de la Sierra, el
monumento de Collado Hermoso — ver [docs/diseno.md](docs/diseno.md). Qué
hace la app y por qué: [docs/producto.md](docs/producto.md).

## Desarrollo

No hay build ni dependencias:

```sh
node server/api.js         # app + API en http://localhost:8010
```

o solo el frontend en modo local:

```sh
python3 -m http.server -d public
```

## Despliegue

```sh
scripts/deploy.sh
```

Runbook completo (arquitectura, setup inicial, operación, rollback):
[docs/despliegue.md](docs/despliegue.md).
