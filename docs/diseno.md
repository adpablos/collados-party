# Diseño — A Pachas

Identidad y UI diseñadas con Claude Design a partir de la foto del monasterio
de Santa María de la Sierra (Collado Hermoso, Segovia), el monumento de la
peña. Proyecto de diseño (prototipo navegable, editable):
https://claude.ai/design/p/61c29d29-59f4-4f4d-8c5b-df04adba396e

## Concepto

El logo es el óculo/rosetón circular de piedra del monasterio, partido en
5 porciones iguales: pagar «a pachas» es repartir entre todos. Se pinta con
`currentColor` para heredar el color del contexto (nav, hero, favicon).

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" fill="none">
  <circle cx="24" cy="24" r="19" stroke="#2E6E9E" stroke-width="4.5"/>
  <g stroke="#2E6E9E" stroke-width="4.5" stroke-linecap="round">
    <line x1="24" y1="24" x2="24" y2="5"/>
    <line x1="24" y1="24" x2="42.1" y2="18.1"/>
    <line x1="24" y1="24" x2="35.2" y2="39.4"/>
    <line x1="24" y1="24" x2="12.8" y2="39.4"/>
    <line x1="24" y1="24" x2="5.9" y2="18.1"/>
  </g>
</svg>
```

## Tokens

Paleta sacada de la foto: piedra cálida/arena, azul cielo castellano, verde
encina, terracota.

| Token        | Claro     | Oscuro    | Uso |
| ------------ | --------- | --------- | --- |
| `--bg`       | `#EFE7D8` | `#1D1811` | fondo app (arena) |
| `--card`     | `#FBF7ED` | `#292219` | tarjetas, nav, sheet |
| `--ink`      | `#2B251C` | `#F0E8D6` | texto principal |
| `--muted`    | `#80735C` | `#A2947B` | texto secundario, iconos inactivos |
| `--line`     | `#E0D5BE` | `#3B3224` | bordes, divisores |
| `--sky`      | `#2E6E9E` | `#7FB0D9` | acento primario: botones, tab activa |
| `--onsky`    | `#FFFFFF` | `#14212C` | texto sobre sky y sobre green |
| `--skysoft`  | `#DCE7EE` | `#26333E` | chip «La trae X», botón «Me lo pido» |
| `--green`    | `#57704E` | `#98B089` | comprada, saldo positivo, confirmar |
| `--greensoft`| `#E3E9DA` | `#2B3524` | chip «Comprada», pill activa |
| `--terra`    | `#A64B2A` | `#D98F66` | saldo negativo (debe), borrar |
| `--terrasoft`| `#F1E0D3` | `#3B2A1E` | reservado (fondo suave terracota) |
| `--chip`     | `#E8DDC5` | `#352D1F` | chip neutro «Sin dueño», avatares |

Velo del sheet: `rgba(24,19,11,.45)`. Toast: fondo `--ink`, texto `--bg`.
Modo oscuro: automático por `prefers-color-scheme` + toggle manual (luna,
arriba a la derecha) persistido en `localStorage`.

## Tipografía

- Display: **Bricolage Grotesque** (Google Fonts) — wordmark 800/34px,
  títulos de pantalla 700/26px, total de cuentas 800/30px, títulos de
  card/sheet 700/20px, inicial de avatar 700/16px.
- Cuerpo: **Instrument Sans** — botones 600/15px, nombres 600/15px,
  cuerpo/inputs 400–500/14px, meta 400/13px, chips 600/12px, labels
  uppercase 600/12px con tracking 0.08em, tabs 600/11px.
- Fallback: pila de sistema (la app funciona sin red de fuentes).

## Voz del copy

Castellano de pueblo, con guasa pero sin pasarse:

- «Los gastos de la peña, a partes iguales. Ni pa ti ni pa mí.»
- «¿Qué falta? (garrafón no)» · «Me lo pido» · «Ya está comprada»
- «¿Quiénes la catan?» · «Sin dueño» · «La trae Marta»
- «Ponle precio, que gratis no fue.» · «Alguien la catará, digo yo.»
- «Todo comprado. Vaya máquinas.» · «Cuentas claras y el chocolate espeso.»
- Admin = «la llave» (icono de llave discreto, nada de "administrador").

## Pantallas

1. **Fiesta**: hero (logo + wordmark + lema) · card «TU FIESTA» con meta y
   «Invitar por enlace» · fila quién-eres · accesos (cambiar nombre/fecha si
   llave, empezar otra, ejemplo). Sin fiesta: unirse por enlace / crear.
2. **Lista**: sub «{n} cosas por resolver de {total}» · añadir · cards con
   chip de estado y acciones según rol; comprada muestra
   «{precio} · pagó {N} · entre {n}» y se edita tocándola.
3. **Peña**: filas avatar + nombre (+llave) + saldo («le deben»/«debe»/«en
   paz») · «Invitar por enlace» · añadir a mano. Ficha por persona al tocar.
4. **Cuentas**: total + por cabeza · bizums mínimos con check circular ·
   compartir al grupo.
