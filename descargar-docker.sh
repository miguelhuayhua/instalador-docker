#!/bin/bash
# Script de instalación Docker offline
# Uso: sudo bash instalar-docker-offline.sh

echo "=== Instalador Docker Offline ==="

# Verificar que se ejecute como root
if [ "$EUID" -ne 0 ]; then 
    echo "ERROR: Ejecuta este script como root (sudo)"
    exit 1
fi

# Directorio actual donde están los .deb
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Buscando paquetes .deb en: $DIR"

# Verificar que existan los archivos
if ! ls $DIR/*.deb 1> /dev/null 2>&1; then
    echo "ERROR: No se encontraron archivos .deb en este directorio"
    exit 1
fi

echo "Archivos encontrados:"
ls -lh $DIR/*.deb

echo ""
read -p "¿Continuar con la instalación? (s/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    echo "Instalación cancelada"
    exit 0
fi

# Instalar paquetes en orden correcto
echo ""
echo "=== Instalando Docker... ==="

dpkg -i $DIR/containerd.io_*.deb
dpkg -i $DIR/docker-ce-cli_*.deb
dpkg -i $DIR/docker-ce_*.deb
dpkg -i $DIR/docker-buildx-plugin_*.deb
dpkg -i $DIR/docker-compose-plugin_*.deb

# Resolver dependencias si faltan
echo ""
echo "=== Resolviendo dependencias... ==="
apt-get install -f -y

# Agregar usuario actual al grupo docker
if [ -n "$SUDO_USER" ]; then
    echo ""
    echo "=== Agregando usuario $SUDO_USER al grupo docker ==="
    usermod -aG docker $SUDO_USER
fi

# Habilitar e iniciar Docker
echo ""
echo "=== Configurando Docker... ==="
systemctl enable docker
systemctl start docker

# Verificar instalación
echo ""
echo "=== Verificando instalación ==="
docker --version
docker compose version

echo ""
if systemctl is-active --quiet docker; then
    echo "✓ Docker instalado y ejecutándose correctamente"
    echo ""
    echo "IMPORTANTE: Cierra la terminal y ábrela de nuevo para usar docker sin sudo"
else
    echo "✗ Docker instalado pero no está ejecutándose"
    echo "Intenta: sudo systemctl start docker"
fi

echo ""
echo "=== Instalación completada ==="