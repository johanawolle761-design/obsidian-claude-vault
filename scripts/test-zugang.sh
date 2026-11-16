#!/usr/bin/env bash
# Prüft, ob Cloudflare Access und der Proxy richtig sperren.
# Werte NICHT als Argumente übergeben (landen sonst in der Shell-History),
# sondern abfragen lassen.
set -euo pipefail

read -rp "URL (z. B. https://vault.DEINEDOMAIN.de/mcp): " URL
read -rsp "Cloudflare Client ID: " CID; echo
read -rsp "Cloudflare Client Secret: " CSEC; echo
read -rsp "VAULT_AI_KEY: " KEY; echo

CF_HEADER="Authorization: {\"cf-access-client-id\":\"$CID\",\"cf-access-client-secret\":\"$CSEC\"}"

code() { curl -s -o /dev/null -w "%{http_code}" "$@"; }

c1=$(code "$URL")
c2=$(code "$URL" -H "$CF_HEADER")
c3=$(code "$URL" -H "$CF_HEADER" -H "x-api-key: $KEY")

echo "1) ohne Schlüssel:        $c1  (erwartet 403)"
echo "2) nur Service Token:     $c2  (erwartet 401)"
echo "3) Token + x-api-key:     $c3  (erwartet NICHT 401/403)"

ok=1
[[ "$c1" == "403" ]] || { echo "FEHLER: Cloudflare Access sperrt nicht."; ok=0; }
[[ "$c2" == "401" ]] || { echo "FEHLER: Proxy sperrt nicht."; ok=0; }
[[ "$c3" != "401" && "$c3" != "403" ]] || { echo "FEHLER: Mit beiden Schlüsseln kein Zugang."; ok=0; }

if [[ $ok == 1 ]]; then
  echo "Alles ok."
else
  echo "Bei Fehler 1) oder 2): sofort 'docker compose down' und Einstellungen prüfen."
  exit 1
fi
