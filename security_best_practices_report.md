# Security Best Practices Review

Review date: 2026-07-07
Reviewed PR: https://github.com/adpablos/apachas/pull/1
Reviewed stack: vanilla browser JavaScript in `public/index.html`, Node.js
`node:http` API in `server/api.js`, nginx plus Docker Compose deployment.

## Executive Summary

No Critical or High security issues were found in this pass.

The PR is in good shape for the current product risk model: party IDs and write
keys are cryptographically random, API bodies are bounded, shared state is
deeply validated and rebuilt by allowlist before storage, capability-bearing API
URLs are redacted or not logged, and path traversal is blocked in local static
serving.

Three defense-in-depth gaps remain:

- S-001: no strict Content Security Policy is configured yet. This is the main
  remaining hardening item because the frontend uses `innerHTML` templating.
- S-002: Google Fonts is loaded as a third-party stylesheet without self-hosting
  or CSP pinning.
- S-003: deployment containers run with default/root privileges; impact is
  limited by read-only mounts and network exposure, but it is not the most
  hardened container posture.

During this review, two safe improvements were made before writing this report:
basic nginx security headers were added, and a non-security dataset bug from the
previous naming cleanup was fixed.

## Scope and Method

The review used the local PR branch and the `security-best-practices` guidance
for vanilla frontend JavaScript. There is no exact reference file for the custom
Node.js `node:http` backend, so backend review used general Node/web security
practice and direct code inspection.

Primary checks:

- DOM XSS sinks and data sources: `innerHTML`, localStorage, URL hash, API data.
- Dynamic code execution: `eval`, `new Function`, string timers.
- URL navigation and third-party resources.
- Storage of secrets or bearer capabilities.
- API body size, validation, rate limiting, path traversal, entropy, logging.
- nginx headers, API proxy behavior, and Docker Compose deployment posture.

## Critical Findings

None.

## High Findings

None.

## Medium Findings

### S-001: No strict CSP is configured for a template-heavy frontend

- Severity: Medium
- Location:
  - `deployment/nginx/default.conf:9-12`
  - `deployment/nginx/default.conf:37-49`
  - `public/index.html:1087-1088`
  - `public/index.html:1916-1930`
- Evidence:
  - nginx now sends basic hardening headers, but no `Content-Security-Policy`
    header is present in the repo.
  - The frontend renders whole view templates with `innerHTML` in `openSheet()`
    and `render()`.
  - `public/index.html` contains one inline `<style>` block and one inline
    `<script>` block, which means a strict CSP would need hashes/nonces or a
    small file layout change.
- Impact: If a future escaping mistake lets attacker-controlled party data reach
  an HTML sink, the absence of CSP/Trusted Types gives the browser no strong
  second line of defense.
- Fix: Add a strict CSP at nginx level. For the current one-file app, either:
  - externalize CSS/JS into same-origin files and use `script-src 'self'`;
  - or keep the one-file design and maintain `sha256-...` hashes for the inline
    style/script blocks.
- Suggested baseline:
  - `default-src 'self'`
  - `script-src 'self' 'sha256-...'`
  - `style-src 'self' 'sha256-...' https://fonts.googleapis.com`
  - `font-src https://fonts.gstatic.com`
  - `img-src 'self' data:`
  - `connect-src 'self'`
  - `object-src 'none'`
  - `base-uri 'none'`
  - `frame-ancestors 'none'`
- Mitigation already present:
  - Shared state is validated on the server and client.
  - IDs are constrained to `[A-Za-z0-9_-]{1,40}`.
  - User-controlled strings are routed through `escapeHtml()` before HTML
    insertion in reviewed paths.
  - Basic headers were added in this pass: `X-Content-Type-Options`,
    `Referrer-Policy`, `Permissions-Policy`, and `X-Frame-Options`, factored
    into `deployment/nginx/security-headers.conf`. Because nginx does not
    inherit parent `add_header` directives into locations that define their
    own `add_header`, this file is `include`d again on `/` and `/index.html`,
    where `Cache-Control` is also set.
- False positive notes: This is not an exploitable XSS finding by itself; it is
  a hardening gap around a frontend style that relies heavily on disciplined
  escaping.

## Low Findings

### S-002: Third-party Google Fonts stylesheet is not pinned by SRI or isolated by CSP

- Severity: Low
- Location:
  - `public/index.html:9-11`
- Evidence:
  - The app loads Google Fonts from `fonts.googleapis.com` / `fonts.gstatic.com`.
  - No CSP currently limits external resource loading.
  - SRI is not used for the stylesheet.
- Impact: A third-party stylesheet dependency can affect rendering and creates a
  small supply-chain/privacy dependency. This is lower risk than third-party
  JavaScript because it is not script execution.
- Fix: Prefer self-hosting the selected font files, or add CSP once S-001 is
  addressed so only the required font origins are allowed.
- Mitigation: The app has system font fallbacks and should continue working if
  font network access fails.
- False positive notes: SRI on Google Fonts CSS is often impractical because the
  CSS can vary by client. Self-hosting is the cleaner secure-by-default option.

### S-003: Containers are not configured with least-privilege users

- Severity: Low
- Location:
  - `compose.yaml:30-38`
  - `compose.yaml:46-52`
- Evidence:
  - The API service uses `node:22-alpine` without an explicit non-root user.
  - The `cloudflared` service explicitly runs as `user: "0:0"`.
- Impact: If a container process is compromised, root inside the container gives
  the attacker more room to modify mounted data or abuse container runtime
  boundaries. The blast radius is still constrained by Compose isolation and
  read-only code/config mounts.
- Fix: Consider running the API as the image's `node` user and making the
  `api-data` volume writable by that user. Consider a non-root `cloudflared`
  user if credential file ownership can be made compatible.
- Mitigation already present:
  - Source and tunnel config mounts are read-only.
  - The web port is bound to loopback only.
  - Shared-party data is isolated to the `api-data` volume.
- False positive notes: This may require a server-side volume permission
  migration, so it is not a merge blocker for the current PR.

## Accepted Product-Security Tradeoffs

### A-001: Party ID and write key are bearer capabilities

- Location:
  - `server/api.js:39-47`
  - `server/api.js:395-399`
  - `public/index.html:617-636`
- Evidence:
  - A random party ID grants read access.
  - A random write key in the URL hash grants edit access.
- Why accepted:
  - The product intentionally has no accounts or sign-in.
  - The write key lives in the hash so nginx and Cloudflare do not receive it.
  - API logs redact party IDs.
- Security note:
  - This is not equivalent to authenticated authorization. Anyone with the link
    can read/edit according to the product model.

## Positive Controls Observed

- Cryptographic randomness:
  - Party IDs and write keys use `crypto.randomBytes()` in `server/api.js:39-43`.
  - IDs are non-incrementing and not enumerable in practice.
- Server-side input validation:
  - Deep state validation covers IDs, names, enum values, price bounds,
    dates, timestamps, consumers, settlements, and tombstones in
    `server/api.js:215-260`.
  - Stored documents are rebuilt by allowlist in `server/api.js:263-309`.
- Request and storage guardrails:
  - Body size is capped in `server/api.js:25` and enforced in
    `server/api.js:95-116`.
  - Rate limiting is present in `server/api.js:311-329`.
  - Party count is capped by `MAX_PARTIES`.
- Logging hygiene:
  - API route logs redact party IDs in `server/api.js:482-489`.
  - nginx disables `/api/` access and error logs in
    `deployment/nginx/default.conf:24-29`.
- Static file safety:
  - Local static serving resolves paths under `STATIC_DIR` and rejects paths
    outside it.
- Frontend escaping:
  - `escapeHtml()` exists at `public/index.html:473`.
  - Reviewed template insertions escape party, person, item, and attribute text
    in high-risk sinks.
- External navigation:
  - WhatsApp sharing uses a fixed `https://wa.me/` URL with
    `encodeURIComponent()` and `noopener` in `public/index.html:1492-1494`.

## Verification Commands

```bash
node --check server/api.js
python3 - <<'PY'
from pathlib import Path
html = Path('public/index.html').read_text()
start = html.index('<script>') + len('<script>')
end = html.index('</script>', start)
Path('/tmp/apachas-index-script.js').write_text(html[start:end])
PY
node --check /tmp/apachas-index-script.js
bash -n scripts/deploy.sh
git diff --check
```
