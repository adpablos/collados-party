# A Pachas

Los gastos de la peña, a partes iguales. Ni pa ti ni pa mí.

**En producción:** https://collados.alexdepablos.es

Apuntáis la lista de la compra de la fiesta, cada uno se pide lo que trae,
se apunta lo que costó y quiénes lo catan, y A Pachas saca los bizums
mínimos para quedar en paz. Se comparte por enlace, sin cuentas ni registros:
todo vive en el navegador de cada uno.

Es una sola página (`public/index.html`), sin build ni base de datos. El
logo y la identidad salen del óculo del monasterio de Santa María de la
Sierra, el monumento de Collado Hermoso — ver [docs/diseno.md](docs/diseno.md).

## Desarrollo

No hay build ni dependencias. Abre `public/index.html` en el navegador o
sirve la carpeta:

```sh
python3 -m http.server -d public
```

## Despliegue

```sh
scripts/deploy.sh
```

Runbook completo (arquitectura, setup inicial, operación, rollback):
[docs/despliegue.md](docs/despliegue.md).
