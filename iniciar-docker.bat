@echo off
wsl -d Debian -- sh -c "cd ~/instalador-docker && docker compose start"