#!/bin/bash
# verificar-balanceo.sh

echo "=========================================="
echo "📊 VERIFICACIÓN DE BALANCEO S2/S3"
echo "=========================================="
echo ""

# Realizar 20 peticiones
echo "✅ Realizando 20 peticiones a login.php..."
for i in {1..20}; do
    curl -s http://localhost:90/login.php > /dev/null
    printf "."
    sleep 0.1
done
echo ""
echo ""

# Contar peticiones por backend (últimos 15 segundos)
S2_COUNT=$(docker compose logs --since 15s s2-php 2>/dev/null | grep -c "GET /login.php" || echo 0)
S3_COUNT=$(docker compose logs --since 15s s3-php 2>/dev/null | grep -c "GET /login.php" || echo 0)

# Mostrar resultados
echo "=========================================="
echo "📈 RESULTADOS"
echo "=========================================="
printf "   S2-PHP: %2d peticiones " "$S2_COUNT"
printf '🟦%.0s' $(seq 1 $S2_COUNT)
echo ""
printf "   S3-PHP: %2d peticiones " "$S3_COUNT"
printf '🟩%.0s' $(seq 1 $S3_COUNT)
echo ""
echo "=========================================="
echo ""

# Evaluación
if [ $S2_COUNT -gt 0 ] && [ $S3_COUNT -gt 0 ]; then
    TOTAL=$((S2_COUNT + S3_COUNT))
    PCT_S2=$((S2_COUNT * 100 / TOTAL))
    PCT_S3=$((S3_COUNT * 100 / TOTAL))
    DIFF=$((S2_COUNT > S3_COUNT ? S2_COUNT - S3_COUNT : S3_COUNT - S2_COUNT))
    
    echo "✅ BALANCEO FUNCIONANDO CORRECTAMENTE"
    echo "   Distribución: S2=${PCT_S2}% | S3=${PCT_S3}%"
    
    if [ $DIFF -le 3 ]; then
        echo "   🌟 Excelente equilibrio"
    elif [ $DIFF -le 6 ]; then
        echo "   👍 Buen equilibrio"
    else
        echo "   ⚠️  Desequilibrio aceptable"
    fi
else
    echo "❌ BALANCEO FALLIDO"
    if [ $S2_COUNT -eq 0 ]; then
        echo "   • S3-PHP está activo pero S2-PHP no responde"
    fi
    if [ $S3_COUNT -eq 0 ]; then
        echo "   • S2-PHP está activo pero S3-PHP no responde"
    fi
fi

echo ""
echo "=========================================="
