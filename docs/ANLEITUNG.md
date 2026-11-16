# Anleitung: Obsidian-Vault als Gedächtnis für Claude

Zurück: [README](../README.md)

## Wie es funktioniert

Claude verbindet sich aus der Cloud von Anthropic, nicht von deinem PC. Der Server muss also über das Internet erreichbar sein. Deshalb gibt es zwei Schlösser hintereinander:

1. **Cloudflare Access** lässt nur Anfragen mit gültigem Service Token durch.
2. **Caddy-Proxy** lässt nur Anfragen mit richtigem `x-api-key` durch und setzt intern den Token für den MCP-Server.

Der MCP-Server ([obsidian-sync-mcp](https://github.com/es617/obsidian-sync-mcp)) liest und schreibt direkt den Vault-Ordner. Syncthing gleicht diesen Ordner mit Obsidian auf deinem PC ab.

Ehrliche Abwägung: Wer Zugriff auf dein Claude-Konto hat, kommt auch an den Vault. Claude-Konto also mit gutem Passwort und 2FA schützen.

## Schritt 0: Vorab prüfen

- claude.ai > Einstellungen > Connectors > Add custom connector. Gibt es einen Bereich **Request headers** (evtl. unter "Advanced")? Das ist Beta und nicht überall freigeschaltet. Ohne diesen Bereich funktioniert diese Anleitung so nicht, siehe Schritt 6 unten.
- Domain liegt bei Cloudflare (Nameserver umgestellt).

## Schritt 1: Ordner und Secrets auf dem Server

```bash
git clone https://github.com/johanawolle761-design/obsidian-claude-vault ~/obsidian-claude-vault
mkdir -p ~/vault-mcp
cp ~/obsidian-claude-vault/server/{docker-compose.yml,Caddyfile,.env.example} ~/vault-mcp/
cd ~/vault-mcp
mkdir -p vault mcp-data syncthing
cp .env.example .env
chmod 600 .env

# Zufallswerte erzeugen und in .env eintragen
openssl rand -hex 32   # für MCP_AUTH_TOKEN
openssl rand -hex 32   # für VAULT_AI_KEY
```

In `.env` außerdem `SYNC_BIND_IP` (LAN- oder VPN-IP des Servers) und `PUID`/`PGID` (`id -u`, `id -g`) eintragen. `TUNNEL_TOKEN` kommt in Schritt 2.

- `MCP_AUTH_TOKEN`: Passwort zwischen Proxy und MCP-Server. Verlässt den Server nie.
- `VAULT_AI_KEY`: kommt später als Header `x-api-key` in den Claude-Connector.

## Schritt 2: Cloudflare einrichten

### 2.1 Zero Trust
Im Cloudflare-Dashboard Zero Trust aktivieren, kostenlosen Plan wählen, Team-Namen festlegen.

### 2.2 Tunnel
- Zero Trust > Networks > Tunnels > Tunnel erstellen (Typ cloudflared), Name z. B. `vault`.
- Umgebung "Docker", den Token kopieren und in `.env` bei `TUNNEL_TOKEN=` eintragen.

### 2.3 Service Token
- Zero Trust > Access > Service Auth > Service Tokens > Create.
- Name z. B. `claude-ai-vault`, Laufzeit 1 Jahr.
- Client ID und Client Secret sofort in den Passwortmanager. Das Secret wird nur einmal angezeigt.
- **Ablaufdatum in den Kalender eintragen.**

### 2.4 Access-Anwendung
- Zero Trust > Access > Applications > Add > Self-hosted.
- Name `vault-ai`, Domain `vault.DEINEDOMAIN.de`.
- Policy: Action **Service Auth**, Include **Service Token** = `claude-ai-vault`. Sonst nichts. Kein Everyone, kein Bypass.

### 2.5 Token in einem einzigen Header erlauben
Claude schickt das Service Token als JSON im Header `authorization`. Cloudflare muss das erlauben, über das Feld `read_service_tokens_from_header` der Access-Anwendung. Dafür vorübergehend einen Cloudflare-API-Token mit dem Recht "Access: Apps and Policies Edit" anlegen.

```bash
ACCOUNT_ID=...   # steht im Dashboard
APP_ID=...       # ID der Anwendung vault-ai
read -rsp "CF API Token: " CF_API_TOKEN; echo

curl -s "https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/access/apps/$APP_ID" \
  -H "Authorization: Bearer $CF_API_TOKEN" \
  | jq '.result | .read_service_tokens_from_header = "Authorization"' > app.json

curl -s -X PUT "https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/access/apps/$APP_ID" \
  -H "Authorization: Bearer $CF_API_TOKEN" \
  -H "Content-Type: application/json" \
  --data @app.json

rm app.json
```

Falls der PUT einen Fehler bringt: reine Lesefelder (z. B. `id`, `aud`, `created_at`, `updated_at`) aus `app.json` entfernen und nochmal. Danach den API-Token in Cloudflare widerrufen. Doku: Cloudflare "Service tokens", Abschnitt "Authenticate with a single header".

### 2.6 Public Hostname
- Tunnel `vault` > Public Hostname hinzufügen: `vault.DEINEDOMAIN.de` -> Service `http://vault-ai-proxy:8080`.
- "Protect with Access" einschalten und Anwendung `vault-ai` wählen.

## Schritt 3: Starten

```bash
cd ~/vault-mcp
docker compose up -d
docker compose ps
```

Hinweise:
- Sobald alles läuft, statt `latest` feste Versionen eintragen und Updates bewusst machen.
- Kann Claude später nicht schreiben: Besitzer von `./vault` prüfen.

## Schritt 4: Testen, bevor Claude dran darf

```bash
bash ~/obsidian-claude-vault/scripts/test-zugang.sh
```

Erwartung: ohne Schlüssel 403, nur Service Token 401, beides kommt durch. Wenn 1) oder 2) schon durchkommen: sofort `docker compose down` und Fehler suchen.

## Schritt 5: Connector in Claude anlegen

- claude.ai > Einstellungen > Connectors > Add custom connector.
- Name `Vault`, URL `https://vault.DEINEDOMAIN.de/mcp`.
- Request headers:
  - `authorization` = `{"cf-access-client-id":"DEINE_CLIENT_ID","cf-access-client-secret":"DEIN_CLIENT_SECRET"}`
  - `x-api-key` = Wert von `VAULT_AI_KEY`
- Speichern, im Chat über das Tools-Menü einschalten.
- Header lassen sich später nicht ändern. Bei neuem Token: Connector löschen und neu anlegen.

Der Connector gilt dann in claude.ai, Handy-App, Claude Desktop und Claude Code (wenn dort per `/login` mit dem Abo angemeldet).

## Schritt 6: Falls es keine Request headers gibt

Dann ist die Beta im Konto noch nicht freigeschaltet. Möglichkeiten: abwarten, beim Anthropic-Support nachfragen, oder statt Service Token einen OAuth-Login über Cloudflare Access bauen (Managed OAuth, Login z. B. per Google, Policy nur die eigene E-Mail). Der OAuth-Weg ist mit anderen KIs erprobt, mit Claude in diesem Aufbau aber **nicht getestet**. Vorher selbst testen und auf keinen Fall Access abschalten, nur damit es läuft.

## Schritt 7: Syncthing und Obsidian auf dem PC

- Weboberfläche des Server-Syncthing per SSH-Tunnel öffnen: `ssh -L 8384:127.0.0.1:8384 user@server`, dann `http://127.0.0.1:8384`. Dort ein GUI-Passwort setzen.
- Syncthing auf dem PC installieren (syncthing.net). Geräte gegenseitig per Geräte-ID hinzufügen. Beim Server die Adresse fest eintragen: `tcp://SYNC_BIND_IP:22000`.
- Auf **beiden** Seiten ausschalten: Global Discovery, Relays, NAT-Traversal. Local Discovery optional.
- Ordner "Vault" (Server-Pfad `/var/syncthing/Vault`) teilen, Senden und Empfangen, Dateiversionierung "Papierkorb" 30 Tage.
- Obsidian > "Ordner als Vault öffnen" > Sync-Ordner wählen.
- **Windows-Falle:** Wird Syncthing aus der Claude-Desktop-App heraus eingerichtet, kann die Konfiguration in einem umgeleiteten AppData-Ordner landen. Besser mit eigenem Konfig-Ordner starten, z. B. `syncthing --home C:\Users\NAME\.syncthing-vault`, und eine Verknüpfung in den Autostart legen.

## Schritt 8: Grundgerüst im Vault

Inhalt von [`vault-vorlage/`](../vault-vorlage/) in den Vault kopieren und anpassen. Wichtig sind `Start.md` (Einstieg) und `Vorlieben/Arbeitsweise.md` (Regeln für jede KI).

## Schritt 9: Claude sagen, dass es den Vault nutzen soll

Text aus [`prompts/claude-praeferenzen.md`](../prompts/claude-praeferenzen.md) in claude.ai unter Einstellungen > Profil bei den persönlichen Präferenzen eintragen. Optional die eingebaute Memory ausschalten.

Erster Test im neuen Chat: "Lies Start.md aus meinem Vault und fasse zusammen." Danach: "Lege eine Testnotiz in Inbox/ an." Prüfen, ob sie in Obsidian auftaucht.

## Schritt 10: Abschluss-Tests (erst danach fertig)

- Server neu starten, `docker compose ps`: alle vier Container laufen.
- `scripts/test-zugang.sh` nochmal: 403 / 401 / durch.
- Claude im Browser und auf dem Handy: Notiz lesen und schreiben.
- PC neu starten: Syncthing läuft mit derselben Konfiguration, ohne Relays, Änderungen kommen in beide Richtungen an.
- Backup einrichten (z. B. nächtliche Kopie von `~/vault-mcp/vault` auf ein anderes Gerät). Sync ist kein Backup.

## Wartung

- Service Token vor Ablauf erneuern: neues Token anlegen, in die Access-Policy eintragen, Connector neu anlegen, altes Token löschen.
- Updates: `docker compose pull && docker compose up -d`, danach Test-Skript.
- Ist ein Key irgendwo gelandet, wo er nicht hingehört (Chat, Screenshot, Git): sofort neu erzeugen.
