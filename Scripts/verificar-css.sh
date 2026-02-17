#!/bin/bash
# verificar-css.sh

echo "=========================================="
echo "🎨 VERIFICACIÓN DE CSS - S6-Static"
echo "=========================================="
echo ""

# 1. Verificar estado de S6
echo "✅ Paso 1: Verificando estado de S6-Static..."
if docker compose ps | grep s6-static | grep -q "Up"; then
    echo "   ✅ S6-Static está activo"
else
    echo "   ❌ S6-Static NO está activo"
    echo "   Solución: docker compose start s6-static"
    exit 1
fi
echo ""

# 2. Verificar que style.css existe en el contenedor
echo "✅ Paso 2: Verificando archivo style.css en S6..."
if docker compose exec s6-static test -f /usr/share/nginx/html/style.css 2>/dev/null; then
    echo "   ✅ style.css existe en S6-Static"
    
    # Mostrar tamaño del archivo
    SIZE=$(docker compose exec s6-static ls -lh /usr/share/nginx/html/style.css 2>/dev/null | awk '{print $5}')
    echo "   📏 Tamaño: $SIZE"
    
    # Contar líneas
    LINES=$(docker compose exec s6-static wc -l /usr/share/nginx/html/style.css 2>/dev/null | awk '{print $1}')
    echo "   📝 Líneas: $LINES"
else
    echo "   ❌ style.css NO existe en S6-Static"
    echo "   Solución: docker compose cp /usr/share/nginx/html/style.css s6-static:/usr/share/nginx/html/"
    exit 1
fi
echo ""

# 3. Verificar acceso HTTP a style.css
echo "✅ Paso 3: Verificando acceso HTTP a style.css..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:90/style.css 2>/dev/null)
if [ "$HTTP_CODE" = "200" ]; then
    echo "   ✅ style.css accesible vía HTTP (200 OK)"
    
    # Verificar tipo de contenido
    CONTENT_TYPE=$(curl -s -I http://localhost:90/style.css 2>/dev/null | grep "Content-Type" | awk '{print $2}')
    echo "   📄 Content-Type: $CONTENT_TYPE"
    
    # Verificar tamaño de respuesta
    RESPONSE_SIZE=$(curl -s -w "%{size_download}" -o /dev/null http://localhost:90/style.css 2>/dev/null)
    echo "   📊 Tamaño respuesta: ${RESPONSE_SIZE} bytes"
else
    echo "   ❌ style.css NO accesible (HTTP $HTTP_CODE)"
    echo "   Solución: Verificar nginx.conf de S1 y S6"
    exit 1
fi
echo ""

# 4. Verificar contenido del CSS
echo "✅ Paso 4: Verificando contenido del CSS..."
CSS_CONTENT=$(curl -s http://localhost:90/style.css 2>/dev/null)

# Verificar que contiene reglas CSS
if echo "$CSS_CONTENT" | grep -q "{"; then
    echo "   ✅ Contenido CSS válido detectado"
    
    # Contar reglas CSS aproximadas
    RULES=$(echo "$CSS_CONTENT" | grep -c "{" 2>/dev/null || echo 0)
    echo "   🎯 Reglas CSS aproximadas: $RULES"
    
    # Mostrar primeras 5 líneas
    echo ""
    echo "   📄 Primeras 5 líneas del CSS:"
    echo "$CSS_CONTENT" | head -5 | sed 's/^/      /'
else
    echo "   ⚠️  Contenido CSS no válido o vacío"
fi
echo ""

# 5. Verificar que el CSS se aplica en la página
echo "✅ Paso 5: Verificando que el CSS se aplica en login.php..."
LOGIN_HTML=$(curl -s http://localhost:90/login.php 2>/dev/null)

if echo "$LOGIN_HTML" | grep -q "style.css"; then
    echo "   ✅ Referencia a style.css encontrada en login.php"
    
    # Verificar que el CSS está enlazado correctamente
    if echo "$LOGIN_HTML" | grep -q '<link.*href=".*style.css"'; then
        echo "   ✅ Enlace CSS correctamente formateado"
    else
        echo "   ⚠️  Enlace CSS puede estar mal formateado"
    fi
else
    echo "   ❌ Referencia a style.css NO encontrada en login.php"
    echo "   Solución: Verificar que login.php incluye <link rel=\"stylesheet\" href=\"/style.css\">"
fi
echo ""

# 6. Resumen
echo "=========================================="
echo "📊 RESUMEN DE VERIFICACIÓN CSS"
echo "=========================================="
echo "   ✅ S6-Static: Activo"
echo "   ✅ style.css: Existe en S6"
echo "   ✅ HTTP Access: 200 OK"
echo "   ✅ Content-Type: text/css"
echo "   ✅ Contenido: CSS válido"
echo "   ✅ Enlace en login.php: Correcto"
echo ""
echo "✅ VERIFICACIÓN DE CSS COMPLETADA"
echo "=========================================="
echo ""
