Set ws = CreateObject("Wscript.Shell")

' Usar comillas dobles escapadas con ""
ws.run "wsl -d Debian -e sh -c ""cd ~/instalador-docker && docker compose -f docker-compose.local.yml up -d""", 0, True