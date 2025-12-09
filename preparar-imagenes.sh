#!/bin/bash
# Script para preparar imágenes Docker para instalación offline
# Ejecutar en máquina CON internet

echo "=== Preparación de imágenes Docker para modo offline ==="

OUTPUT_DIR="docker-images-offline"
mkdir -p "$OUTPUT_DIR"

echo ""
echo "Descargando imágenes..."

# Descargar imágenes
docker pull postgres:16-alpine
docker pull minio/minio:latest

# Si ya tienes el proyecto Next.js construido
# docker build -t nextjs-app:local ./proyecto-nextjs

echo ""
echo "Guardando imágenes como archivos..."

# Guardar imágenes a archivos .tar
docker save postgres:16-alpine -o "$OUTPUT_DIR/postgres-16-alpine.tar"
docker save minio/minio:latest -o "$OUTPUT_DIR/minio-latest.tar"

# Si construiste la imagen de Next.js
docker save nextjs-app:local -o "$OUTPUT_DIR/nextjs-app-local.tar"

echo ""
echo "Creando script de carga..."

# Crear script para cargar imágenes
cat > "$OUTPUT_DIR/cargar-imagenes.sh" << 'LOADER'
#!/bin/bash
# Script para cargar imágenes Docker offline

echo "=== Cargando imágenes Docker ==="

for file in *.tar; do
    if [ -f "$file" ]; then
        echo "Cargando: $file"
        docker load -i "$file"
    fi
done

echo ""
echo "✓ Imágenes cargadas exitosamente"
echo ""
echo "Verificar con: docker images"
LOADER

chmod +x "$OUTPUT_DIR/cargar-imagenes.sh"

# Crear README
cat > "$OUTPUT_DIR/README.txt" << 'README'
=== Instrucciones de instalación offline ===

1. Copiar esta carpeta al cliente (USB, red local, etc.)

2. Cargar imágenes Docker:
   cd docker-images-offline
   bash cargar-imagenes.sh

3. Verificar imágenes:
   docker images

4. Copiar proyecto Next.js si no está en las imágenes:
   - Extraer proyecto-nextjs.zip
   - Colocar en la carpeta donde está docker-compose.yml

5. Levantar servicios:
   docker-compose -f docker-compose-offline.yml up -d

6. Verificar:
   docker-compose ps
   
Acceso:
- Next.js:      http://localhost:3000
- MinIO:        http://localhost:9001
- PostgreSQL:   localhost:5432
README

echo ""
echo "=== Resumen ==="
echo "Carpeta creada: $OUTPUT_DIR/"
ls -lh "$OUTPUT_DIR/"

echo ""
echo "Tamaño total:"
du -sh "$OUTPUT_DIR/"

echo ""
echo "=== Siguientes pasos ==="
echo "1. Copiar la carpeta '$OUTPUT_DIR' al cliente"
echo "2. En el cliente ejecutar: bash cargar-imagenes.sh"
echo "3. Usar docker-compose-offline.yml"
echo ""
echo "Para comprimir todo:"
echo "  tar -czf docker-offline.tar.gz $OUTPUT_DIR/"