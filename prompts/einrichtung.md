# Prompt: Claude führt dich durch die Einrichtung

In einen neuen Claude-Chat kopieren (am besten mit Websuche an):

```
Ich möchte meinen eigenen Obsidian-Vault als Langzeitgedächtnis für Claude einrichten. Grundlage ist dieses Repo: https://github.com/johanawolle761-design/obsidian-claude-vault (vor allem docs/ANLEITUNG.md). Hilf mir Schritt für Schritt, einen Schritt nach dem anderen, und warte nach jedem Schritt auf meine Rückmeldung.

Ziel-Aufbau:
- Vault-Ordner auf meinem Linux-Server mit Docker.
- MCP-Server: obsidian-sync-mcp (github.com/es617/obsidian-sync-mcp) im Dateisystem-Modus (VAULT_PATH), mit MCP_AUTH_TOKEN, ohne offene Ports.
- Davor ein Caddy-Proxy, der nur Anfragen mit richtigem Header x-api-key durchlässt und intern den Bearer-Token für den MCP-Server setzt. Alles andere 401.
- Erreichbar nur über Cloudflare Tunnel (cloudflared im Docker) mit "Protect with Access".
- Cloudflare Access: Self-hosted-Anwendung, Policy "Service Auth" nur mit einem Service Token, read_service_tokens_from_header = "Authorization", damit Claude das Token als JSON im Header authorization schicken kann.
- Claude-Connector "Vault" in claude.ai mit zwei Request-Headern: authorization (Service Token als JSON) und x-api-key.
- Syncthing zwischen Server und meinem PC, nur Heimnetz oder VPN, ohne Relays, Discovery und NAT, Papierkorb 30 Tage.

Meine Regeln für dich:
- Nie Router-Ports öffnen. Nie ohne Cloudflare Access erreichbar machen. Wenn etwas nur unsicher geht: stoppen und mir sagen, nicht abschwächen.
- Keine Versionen, Flags, Umgebungsvariablen oder API-Felder raten. Vorher in der offiziellen Doku oder im GitHub-README nachsehen und sagen, ob du etwas gefunden hast.
- Secrets erzeuge ich selbst (openssl rand -hex 32) und lege sie nur in ~/vault-mcp/.env ab. Frag mich nie nach echten Secrets im Chat und gib keine aus.
- Kein mcp-remote.
- Erkläre einfach, ich bin kein Profi. Nenne Risiken, bevor wir etwas einrichten.
- Nach jedem Schritt, der Netzwerk, Sync oder Zugänge betrifft, sag mir genau, was ich testen soll (vor allem Neustart). Erst wenn der Test bestanden ist, gilt der Schritt als fertig.
- Zum Schluss Tests: ohne Schlüssel 403, nur Service Token 401, beides kommt durch. Danach Server- und PC-Neustart testen.

Fang an mit: Prüfen, ob mein Claude-Konto beim Hinzufügen eines Custom Connectors den Bereich "Request headers" anbietet. Dann frag mich, welche Hardware und welches Betriebssystem ich habe und ob meine Domain schon bei Cloudflare liegt.
```
