# Obsidian-Vault als Gedächtnis für Claude

Claude bekommt ein eigenes Langzeitgedächtnis: einen Obsidian-Vault auf deinem eigenen Server. Claude liest und schreibt die Notizen über einen MCP-Server, du siehst und bearbeitest dieselben Notizen in Obsidian auf deinem PC. Du weißt also jederzeit, was Claude über dich gespeichert hat, und kannst alles korrigieren. Jede andere KI mit MCP-Unterstützung kann später denselben Vault nutzen.

```
Claude (Cloud von Anthropic)
  -> https://vault.DEINEDOMAIN.de/mcp
  -> Cloudflare Access (prüft Service Token)
  -> Cloudflare Tunnel (kein offener Router-Port)
  -> Caddy-Proxy (prüft x-api-key)
  -> obsidian-sync-mcp (liest/schreibt den Vault-Ordner)

Vault-Ordner auf dem Server  <-- Syncthing (nur Heimnetz/VPN) -->  Obsidian auf PC/Mac
```

## Was du brauchst

- Claude-Konto (Pro empfohlen; Free erlaubt nur einen eigenen Connector)
- **Request headers** beim Custom Connector. Ist bei Anthropic noch Beta und nicht in jedem Konto da. Vorher prüfen: claude.ai > Einstellungen > Connectors > Add custom connector > gibt es "Request headers" (evtl. unter "Advanced")?
- Rechner, der immer läuft, mit Linux, Docker und Docker Compose
- Eigene Domain mit DNS bei Cloudflare, Cloudflare Zero Trust (kostenloser Plan)
- Obsidian und Syncthing auf dem PC
- Grundkenntnisse Terminal, SSH, Docker

## Inhalt

| Pfad | Was |
|---|---|
| [`docs/ANLEITUNG.md`](docs/ANLEITUNG.md) | Komplette Schritt-für-Schritt-Anleitung |
| [`server/`](server/) | `docker-compose.yml`, `Caddyfile`, `.env.example` |
| [`scripts/test-zugang.sh`](scripts/test-zugang.sh) | Prüft, ob beide Schlösser greifen |
| [`vault-vorlage/`](vault-vorlage/) | Startgerüst für den Vault (`Start.md`, Regeln für KIs, Ordner) |
| [`prompts/einrichtung.md`](prompts/einrichtung.md) | Prompt, mit dem Claude dich durch die Einrichtung führt |
| [`prompts/claude-praeferenzen.md`](prompts/claude-praeferenzen.md) | Text für die Claude-Einstellungen, damit Claude den Vault nutzt |

## Schnellstart

1. Repo auf den Server klonen, `server/` nach `~/vault-mcp` kopieren.
2. `cp .env.example .env`, Secrets erzeugen (siehe Anleitung), `chmod 600 .env`.
3. Cloudflare einrichten: Tunnel, Service Token, Access-Anwendung, Single-Header-Einstellung, Public Hostname.
4. `docker compose up -d`, dann `scripts/test-zugang.sh`.
5. Connector in Claude anlegen, Syncthing und Obsidian auf dem PC einrichten.
6. Inhalt von `vault-vorlage/` in den Vault kopieren und anpassen.
7. Neustart-Tests machen. Erst danach ist es fertig.

Wer lieber geführt werden will: den Prompt aus [`prompts/einrichtung.md`](prompts/einrichtung.md) in einen neuen Claude-Chat kopieren.

## Sicherheitsregeln

- Keine Router-Ports öffnen, nur Cloudflare Tunnel.
- Nie ohne Cloudflare Access erreichbar. Kein Bypass, keine Policy mit "Everyone".
- Secrets nur in `.env` auf dem Server. Nie in den Vault, nie in einen Chat, nie in dieses Repo.
- Kein `mcp-remote`.
- Syncthing nur im Heimnetz oder über VPN, ohne Relays und Discovery.
- Nach jeder Einrichtung Neustart testen.

## Quellen

- obsidian-sync-mcp: https://github.com/es617/obsidian-sync-mcp
- Claude Custom Connectors: https://claude.com/docs/connectors/custom/remote-mcp
- Cloudflare Service Tokens: https://developers.cloudflare.com/cloudflare-one/access-controls/service-credentials/service-tokens/
- Syncthing: https://syncthing.net
