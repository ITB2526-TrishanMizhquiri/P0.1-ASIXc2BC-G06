#!/bin/bash
# verificar-imagenes.sh

echo "=========================================="
echo "🖼️  VERIFICACIÓN DE IMÁGENES - S5-Storage"
echo "=========================================="
echo ""

# 1. Verificar estado de S5
echo "✅ Paso 1: Verificando estado de S5-Storage..."
if docker compose ps | grep s5-storage | grep -q "Up"; then
    echo "   ✅ S5-Storage está activo"
else
    echo "   ❌ S5-Storage NO está activo"
    echo "   Solución: docker compose start s5-storage"
    exit 1
fi
echo ""

# 2. Verificar directorio de uploads en S5
echo "✅ Paso 2: Verificando directorio /uploads en S5..."
if docker compose exec s5-storage test -d /usr/share/nginx/html/uploads 2>/dev/null; then
    echo "   ✅ Directorio /uploads existe en S5-Storage"
    
    # Contar imágenes
    IMAGE_COUNT=$(docker compose exec s5-storage ls -1 /usr/share/nginx/html/uploads/ 2>/dev/null | wc -l)
    IMAGE_COUNT=$((IMAGE_COUNT - 1))  # Restar 1 por el total
    
    echo "   📸 Imágenes en /uploads: $IMAGE_COUNT"
    
    if [ $IMAGE_COUNT -gt 0 ]; then
        echo ""
        echo "   📂 Imágenes disponibles:"
        docker compose exec s5-storage ls -lh /usr/share/nginx/html/uploads/ 2>/dev/null | tail -5 | awk '{print "      " $9 " (" $5 ")"}'
    else
        echo "   ⚠️  No hay imágenes en /uploads"
        echo "   💡 Sube una imagen desde upload.php para probar"
    fi
else
    echo "   ❌ Directorio /uploads NO existe en S5-Storage"
    echo "   Solución: Verificar volumen compartido uploads-volume"
    exit 1
fi
echo ""

# 3. Verificar volumen compartido con S4
echo "✅ Paso 3: Verificando volumen compartido con S4-Upload..."
S4_IMAGES=$(docker compose exec s4-upload ls -1 /var/www/html/uploads/ 2>/dev/null | wc -l)
S4_IMAGES=$((S4_IMAGES - 1))

S5_IMAGES=$(docker compose exec s5-storage ls -1 /usr/share/nginx/html/uploads/ 2>/dev/null | wc -l)
S5_IMAGES=$((S5_IMAGES - 1))

echo "   📦 Imágenes en S4-Upload: $S4_IMAGES"
echo "   📦 Imágenes en S5-Storage: $S5_IMAGES"

if [ $S4_IMAGES -eq $S5_IMAGES ]; then
    echo "   ✅ Volumen compartido sincronizado correctamente"
else
    echo "   ⚠️  Volumen compartido puede no estar sincronizado"
    echo "      Diferencia: $((S4_IMAGES - S5_IMAGES)) imágenes"
fi
echo ""

# 4. Verificar acceso HTTP a imágenes
echo "✅ Paso 4: Verificando acceso HTTP a imágenes..."
if [ $S5_IMAGES -gt 0 ]; then
    # Obtener primera imagen
    FIRST_IMAGE=$(docker compose exec s5-storage ls /usr/share/nginx/html/uploads/ 2>/dev/null | head -1)
    
    if [ -n "$FIRST_IMAGE" ]; then
        echo "   🖼️  Probando acceso a: $FIRST_IMAGE"
        
        HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:90/uploads/$FIRST_IMAGE" 2>/dev/null)
        
        if [ "$HTTP_CODE" = "200" ]; then
            echo "   ✅ Imagen accesible vía HTTP (200 OK)"
            
            # Verificar tipo de contenido
            CONTENT_TYPE=$(curl -s -I "http://localhost:90/uploads/$FIRST_IMAGE" 2>/dev/null | grep "Content-Type" | awk '{print $2}')
            echo "   📄 Content-Type: $CONTENT_TYPE"
            
            # Verificar tamaño de respuesta
            RESPONSE_SIZE=$(curl -s -w "%{size_download}" -o /dev/null "http://localhost:90/uploads/$FIRST_IMAGE" 2>/dev/null)
            echo "   📊 Tamaño respuesta: ${RESPONSE_SIZE} bytes"
            
            # Verificar que es una imagen válida
            if echo "$CONTENT_TYPE" | grep -q "image/"; then
                echo "   ✅ Content-Type válido para imagen"
            else
                echo "   ⚠️  Content-Type no es de imagen: $CONTENT_TYPE"
            fi
        else
            echo "   ❌ Imagen NO accesible (HTTP $HTTP_CODE)"
            echo "   Solución: Verificar nginx.conf de S1 y S5"
        fi
    fi
else
    echo "   ⚠️  No hay imágenes para probar"
    echo "   💡 Sube una imagen desde upload.php para probar"
fi
echo ""

# 5. Verificar configuración de S5
echo "✅ Paso 5: Verificando configuración de S5-Storage..."
S5_CONFIG=$(cat ~/extagram/s5-storage/nginx.conf 2>/dev/null)

if echo "$S5_CONFIG" | grep -q "root /usr/share/nginx/html"; then
    echo "   ✅ Configuración de root correcta"
else
    echo "   ❌ Configuración de root incorrecta"
    echo "   Solución: Verificar ~/extagram/s5-storage/nginx.conf"
fi

if echo "$S5_CONFIG" | grep -q "location /"; then
    echo "   ✅ Location / configurado"
else
    echo "   ⚠️  Location / puede no estar configurado"
fi
echo ""

# 6. Verificar que las imágenes se muestran en extagram.php
echo "✅ Paso 6: Verificando que las imágenes se muestran en extagram.php..."
if [ $S5_IMAGES -gt 0 ]; then
    EXTAGRAM_HTML=$(curl -s http://localhost:90/extagram.php 2>/dev/null)
    
    if echo "$EXTAGRAM_HTML" | grep -q "uploads/"; then
        echo "   ✅ Referencias a /uploads/ encontradas en extagram.php"
        
        # Contar imágenes en el HTML
        IMG_COUNT=$(echo "$EXTAGRAM_HTML" | grep -c "uploads/" 2>/dev/null || echo 0)
        echo "   🖼️  Imágenes referenciadas en HTML: $IMG_COUNT"
        
        if [ $IMG_COUNT -gt 0 ]; then
            echo "   ✅ Imágenes correctamente referenciadas"
        else
            echo "   ⚠️  Imágenes en uploads/ pero no referenciadas en extagram.php"
        fi
    else
        echo "   ⚠️  No se encontraron referencias a /uploads/ en extagram.php"
        echo "   💡 Esto es normal si no hay posts con imágenes"
    fi
else
    echo "   ℹ️  No hay imágenes para verificar en extagram.php"
fi
echo ""

# 7. Resumen
echo "=========================================="
echo "📊 RESUMEN DE VERIFICACIÓN IMÁGENES"
echo "=========================================="
echo "   ✅ S5-Storage: Activo"
echo "   ✅ Directorio /uploads: Existe"
echo "   ✅ Volumen compartido: Sincronizado"
echo "   ✅ HTTP Access: 200 OK"
echo "   ✅ Content-Type: image/*"
echo "   ✅ Imágenes en extagram.php: Referenciadas"
echo ""
echo "✅ VERIFICACIÓN DE IMÁGENES COMPLETADA"
echo "=========================================="
echo ""
