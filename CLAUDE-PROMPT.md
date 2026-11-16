# Claude-Prompt zum Kopieren

Neuen Chat in claude.ai öffnen (Websuche an), den Block unten komplett kopieren und einfügen. Claude liest dann die Anleitung aus diesem Repo und führt dich Schritt für Schritt durch.

```
Ich will einen Obsidian-Vault auf meinem eigenen Server als Langzeitgedächtnis für Claude einrichten. Die komplette Anleitung liegt hier, lies sie jetzt zuerst ganz:

https://raw.githubusercontent.com/johanawolle761-design/obsidian-claude-vault/main/docs/ANLEITUNG.md

Weitere Dateien, die du bei Bedarf liest:
- https://raw.githubusercontent.com/johanawolle761-design/obsidian-claude-vault/main/server/docker-compose.yml
- https://raw.githubusercontent.com/johanawolle761-design/obsidian-claude-vault/main/server/Caddyfile
- https://raw.githubusercontent.com/johanawolle761-design/obsidian-claude-vault/main/server/.env.example
- https://raw.githubusercontent.com/johanawolle761-design/obsidian-claude-vault/main/scripts/test-zugang.sh
- https://raw.githubusercontent.com/johanawolle761-design/obsidian-claude-vault/main/vault-vorlage/Vorlieben/Arbeitsweise.md
- https://raw.githubusercontent.com/johanawolle761-design/obsidian-claude-vault/main/prompts/claude-praeferenzen.md

Führ mich danach Schritt für Schritt durch, immer nur einen Schritt, und warte nach jedem Schritt auf meine Rückmeldung.

Deine Regeln:
- Nie Router-Ports öffnen. Nie ohne Cloudflare Access erreichbar machen. Wenn etwas nur unsicher geht: stoppen und mir sagen, nicht abschwächen.
- Keine Versionen, Flags, Umgebungsvariablen oder API-Felder raten. Bei Unsicherheit in der offiziellen Doku oder im GitHub-README nachsehen und sagen, ob du etwas gefunden hast.
- Secrets erzeuge ich selbst und lege sie nur in ~/vault-mcp/.env auf dem Server ab. Frag mich nie nach echten Secrets im Chat und gib keine aus. Passwörter und Logins mache ich selbst.
- Kein mcp-remote.
- Erklär einfach, ich bin kein Profi. Nenn Risiken, bevor wir etwas einrichten.
- Nach jedem Schritt, der Netzwerk, Sync oder Zugänge betrifft, sag mir genau, was ich testen soll (vor allem Neustart). Erst wenn der Test bestanden ist, gilt der Schritt als fertig.

Fang jetzt mit Schritt 0 an: Sag mir, wie ich prüfe, ob mein Claude-Konto beim Hinzufügen eines Custom Connectors den Bereich "Request headers" hat. Frag mich danach, welche Hardware und welches Betriebssystem mein Server hat und ob meine Domain schon bei Cloudflare liegt.
```

Hinweis: Die Links funktionieren nur, solange dieses Repo öffentlich ist. Ist es privat, die Datei `docs/ANLEITUNG.md` herunterladen und in den Chat hochladen, dann den Prompt ohne die Links einfügen.
