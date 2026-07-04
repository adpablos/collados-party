# Despliegue

El Bote se sirve desde el server de Hetzner (`treasure-map-prod-01`), el mismo
que hospeda la porra del Mundial. SSH solo por tailnet (`100.83.154.97`,
usuario `adpablos`, clave `~/.ssh/personal_ed25519`).

## Arquitectura

Un proyecto Docker Compose aislado (`collados`) con dos contenedores:

```txt
Internet ── Cloudflare ── túnel "collados" ── cloudflared ── nginx (web)
                                                              └─ sirve public/
https://collados.alexdepablos.es
```

- `web`: nginx sirviendo `public/` en modo solo-lectura. Expuesto además en
  `127.0.0.1:3200` del server para smokes de operador.
- `cloudflared`: túnel propio de esta app (mismo patrón que producción y
  staging de la porra: un túnel por stack, cero acoplamiento entre apps).

No hay build, base de datos ni secretos de aplicación. El único material
sensible son las credenciales del túnel, que viven fuera del repo.

## Rutas en el server

| Qué                        | Dónde                                        |
| -------------------------- | -------------------------------------------- |
| Clon del repo (despliegue) | `/opt/collados-party`                        |
| Config y credenciales túnel| `/etc/collados-party/cloudflared/`           |
| Puerto de smoke local      | `127.0.0.1:3200`                             |
| Proyecto Compose           | `collados`                                   |

## Despliegue habitual

Commit + push a `main`, y desde el Mac:

```bash
scripts/deploy.sh
```

El script hace `git pull --ff-only` + `docker compose up -d --wait` en el
server y comprueba que `https://collados.alexdepablos.es` responde. Como
`public/` está montado directamente en nginx, un cambio de contenido ni
siquiera reinicia contenedores: el pull basta (el `up` solo actúa si cambió
`compose.yaml`).

Manual equivalente, desde el server:

```bash
cd /opt/collados-party
git pull --ff-only
sudo docker compose up -d --wait
curl -fsS http://127.0.0.1:3200/ >/dev/null && echo OK
```

## Setup inicial (una sola vez)

Hecho el 2026-07-05; queda documentado por si hay que recrearlo.

1. Clonar el repo:

   ```bash
   sudo git clone https://github.com/adpablos/collados-party.git /opt/collados-party
   sudo chown -R adpablos:adpablos /opt/collados-party
   ```

2. Crear el túnel y su ruta DNS (necesita el cert de cuenta de Cloudflare que
   ya existe en el server de los túneles de la porra):

   ```bash
   cloudflared tunnel create collados
   cloudflared tunnel route dns collados collados.alexdepablos.es
   ```

   `create` imprime el id del túnel y deja las credenciales en
   `~/.cloudflared/<tunnel-id>.json`.

3. Colocar la config del túnel:

   ```bash
   sudo mkdir -p /etc/collados-party/cloudflared
   sudo cp ~/.cloudflared/<tunnel-id>.json /etc/collados-party/cloudflared/
   sudo cp deployment/cloudflare/config.yml.example /etc/collados-party/cloudflared/config.yml
   sudo vi /etc/collados-party/cloudflared/config.yml  # poner el <tunnel-id> real
   sudo chmod 600 /etc/collados-party/cloudflared/*.json
   ```

4. Levantar y verificar:

   ```bash
   cd /opt/collados-party
   sudo docker compose up -d --wait
   curl -fsS https://collados.alexdepablos.es >/dev/null && echo OK
   ```

## Operación

Estado y logs:

```bash
sudo docker compose -p collados ps
sudo docker compose -p collados logs -f cloudflared
sudo docker compose -p collados logs -f web
```

Rollback (el contenido es el repo, así que rollback = git):

```bash
cd /opt/collados-party
git log --oneline -5          # elegir el commit bueno
git reset --hard <commit>     # o revert + push desde el Mac, preferible
sudo docker compose up -d --wait
```

Apagar todo (no borra el túnel ni el DNS):

```bash
cd /opt/collados-party
sudo docker compose down
```

Borrado completo del túnel, si algún día se retira la app:

```bash
cloudflared tunnel delete collados   # tras el down y borrar el DNS en Cloudflare
```

## Guardarraíles

- El server es compartido con la porra del Mundial: proyectos Compose
  `current` (producción) y `staging`. **No tocar nada de esos stacks** —
  contenedores, volúmenes, redes, `/opt/porra-mundial-2026*`,
  `/etc/porra-mundial-2026/*`.
- El puerto `3200` está reservado para esta app (la porra usa `3000` y
  `3100`). Si hay conflicto, cambiarlo en `compose.yaml`, no pisar el ajeno.
- Las credenciales del túnel no se commitean nunca; viven solo en
  `/etc/collados-party/cloudflared/`.
