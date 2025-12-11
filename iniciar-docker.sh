#!/bin/bash

# Esperar a que Docker esté listo
until docker info >/dev/null 2>&1; do
    sleep 1
done

# Ir al directorio home
cd ~

# Iniciar los contenedores ya creados (más rápido)
docker compose start