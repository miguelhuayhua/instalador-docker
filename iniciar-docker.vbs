Set ws = CreateObject("Wscript.Shell")
ws.run "wsl -d Debian -e sh -c 'docker-compose -f /ruta/a/tu/proyecto/docker-compose.yml up -d'", 0, True