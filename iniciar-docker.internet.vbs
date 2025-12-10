Set ws = CreateObject("Wscript.Shell")

' Comando 1: Cambiar al directorio del proyecto y ejecutar docker-compose
ws.run "wsl -d Debian -e sh -c 'cd ~/instalador-docker && docker compose -f docker-compose.internet.yml up -d'", 0, True