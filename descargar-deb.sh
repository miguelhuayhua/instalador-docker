#!/bin/bash
# Script para descargar paquetes Docker offline
# Ejecutar en una máquina CON internet

echo "=== Descargador de Docker para instalación offline ==="

# Configuración
DEBIAN_VERSION="bookworm"  # Cambiar según tu versión: bullseye, bookworm, etc.
ARCH="amd64"               # Cambiar si es necesario: amd64, arm64, armhf
OUTPUT_DIR="docker-offline-$(date +%Y%m%d)"

# Crear directorio
mkdir -p "$OUTPUT_DIR"
cd "$OUTPUT_DIR"

echo "Descargando paquetes para Debian $DEBIAN_VERSION ($ARCH)..."
echo ""

# URLs base
BASE_URL="https://download.docker.com/linux/debian/dists/$DEBIAN_VERSION/pool/stable/$ARCH"

# Obtener últimas versiones disponibles
echo "Buscando versiones disponibles..."

# Función para descargar el archivo más reciente
download_latest() {
    local package=$1
    echo "Descargando $package..."
    
    # Lista archivos disponibles y descarga el más reciente
    local file=$(curl -s "$BASE_URL/" | grep -oP "href=\"\K${package}_[^\"]+\.deb" | sort -V | tail -1)
    
    if [ -n "$file" ]; then
        wget -q --show-progress "$BASE_URL/$file"
        echo "✓ $file"
    else
        echo "✗ No se encontró $package"
    fi
}

# Descargar paquetes
download_latest "containerd.io"
download_latest "docker-ce-cli"
download_latest "docker-ce"
download_latest "docker-buildx-plugin"
download_latest "docker-compose-plugin"

echo ""
echo "=== Descarga completada ==="
echo "Archivos guardados en: $(pwd)"
echo ""
ls -lh *.deb

# Copiar script de instalación
cat > instalar-docker.sh << 'INSTALLER'
#!/bin/bash
# Instalador Docker Offline - Auto-generado

if [ "$EUID" -ne 0 ]; then 
    echo "ERROR: Ejecuta como root: sudo bash instalar-docker.sh"
    exit 1
fi

echo "Instalando Docker..."
dpkg -i containerd.io_*.deb
dpkg -i docker-ce-cli_*.deb
dpkg -i docker-ce_*.deb
dpkg -i docker-buildx-plugin_*.deb
dpkg -i docker-compose-plugin_*.deb

apt-get install -f -y

if [ -n "$SUDO_USER" ]; then
    usermod -aG docker $SUDO_USER
fi

systemctl enable docker
systemctl start docker

echo ""
docker --version
docker compose version
echo ""
echo "✓ Docker instalado correctamente"
echo "IMPORTANTE: Cierra y reabre la terminal"
INSTALLER

chmod +x instalar-docker.sh

echo ""
echo "=== Instrucciones ==="
echo "1. Copia la carpeta '$OUTPUT_DIR' al cliente"
echo "2. En el cliente ejecuta: sudo bash instalar-docker.sh"
echo ""
echo "Para crear un ZIP:"
echo "  cd .."
echo "  zip -r $OUTPUT_DIR.zip $OUTPUT_DIR"