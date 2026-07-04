# El Bote

Las cuentas de la peña, sin líos. Apuntad lo que trae cada uno, quién lo paga,
y El Bote os dice quién le debe cuánto a quién para quedar en paz.

**En producción:** https://collados.alexdepablos.es

Es una sola página (`public/index.html`), sin build ni base de datos: todo se
guarda en el propio navegador.

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
