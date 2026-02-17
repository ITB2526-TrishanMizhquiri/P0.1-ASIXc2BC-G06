#!/bin/bash
# fix-y-verificar.sh

# 1. Eliminar identificadores problemáticos
sed -i '/echo "<!-- BACKEND: S[23] -->";/d' ~/extagram/s2-php/login.php ~/extagram/s3-php/login.php
echo "✅ Identificadores problemáticos eliminados"

# 2. Reiniciar servicios
cd ~/extagram
docker compose restart s2-php s3-php >/dev/null 2>&1
sleep 3
echo "✅ Servicios reiniciados"

# 3. Verificar que no hay errores
echo ""
echo "✅ Verificando que login.php funciona sin errores..."
RESPONSE=$(curl -s -w "\n%{http_code}" http://localhost:90/login.php)
HTTP_CODE=$(echo "$RESPONSE" | tail -1)

if [ "$HTTP_CODE" = "200" ]; then
    echo "   ✅ login.php responde 200 OK (sin errores de headers)"
else
    echo "   ⚠️  login.php responde $HTTP_CODE"
fi

# 4. Verificar balanceo mediante logs
echo ""
echo "✅ Verificando balanceo mediante logs..."
S2_COUNT=0
S3_COUNT=0

for i in {1..10}; do
    curl -s http://localhost:90/login.php > /dev/null
    sleep 0.1
done

S2_COUNT=$(docker compose logs --since 15s s2-php 2>/dev/null | grep -c "GET /login.php" || echo 0)
S3_COUNT=$(docker compose logs --since 15s s3-php 2>/dev/null | grep -c "GET /login.php" || echo 0)

echo ""
echo "=========================================="
echo "📈 BALANCEO: S2=$S2_COUNT | S3=$S3_COUNT"
echo "=========================================="

if [ $S2_COUNT -gt 0 ] && [ $S3_COUNT -gt 0 ]; then
    echo "✅ ¡BALANCEO FUNCIONANDO CORRECTAMENTE!"
else
    echo "❌ Balanceo fallido - solo un backend responde"
fi
