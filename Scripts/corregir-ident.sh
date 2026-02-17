#!/bin/bash
# corregir-identificadores.sh

echo "=========================================="
echo "🔧 CORRECCIÓN DE IDENTIFICADORES DE BACKEND"
echo "=========================================="
echo ""

# 1. Añadir identificadores
echo "✅ Paso 1: Añadiendo identificadores..."
sed -i '2 a echo "<!-- BACKEND: S2 -->";' ~/extagram/s2-php/login.php
sed -i '2 a echo "<!-- BACKEND: S3 -->";' ~/extagram/s3-php/login.php
echo "   ✅ Identificadores añadidos a login.php"
echo ""

# 2. Reiniciar servicios
echo "✅ Paso 2: Reiniciando servicios..."
docker compose restart s2-php s3-php
sleep 4
echo "   ✅ Servicios reiniciados"
echo ""

# 3. Verificar identificadores
echo "✅ Paso 3: Verificando identificadores..."
S2_CHECK=$(curl -s http://localhost:90/login.php | grep -c "BACKEND: S2")
S3_CHECK=$(curl -s http://localhost:90/login.php | grep -c "BACKEND: S3")

if [ $S2_CHECK -gt 0 ] && [ $S3_CHECK -gt 0 ]; then
    echo "   ✅ Identificadores visibles en las respuestas HTML"
else
    echo "   ❌ Identificadores NO visibles (reinicia servicios)"
fi
echo ""

# 4. Verificar balanceo
echo "✅ Paso 4: Verificando balanceo..."
echo ""
for i in {1..10}; do
    RESPONSE=$(curl -s http://localhost:90/login.php | grep -o "BACKEND: S[23]")
    if [ "$RESPONSE" = "BACKEND: S2" ]; then
        echo "   [${i}/10] → 🟦 S2-PHP"
    elif [ "$RESPONSE" = "BACKEND: S3" ]; then
        echo "   [${i}/10] → 🟩 S3-PHP"
    else
        echo "   [${i}/10] → ⚠️  Sin identificar"
    fi
    sleep 0.1
done

echo ""
echo "=========================================="
echo "✅ CORRECCIÓN COMPLETA"
echo "=========================================="
echo ""
echo "💡 Ahora ejecuta: ./verificar-balanceo.sh"
echo ""
