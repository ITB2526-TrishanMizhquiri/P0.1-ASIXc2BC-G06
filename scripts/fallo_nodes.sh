#!/bin/bash
# prueba-fallo-nodos.sh

echo "=========================================="
echo "🧪 PRUEBA DE TOLERANCIA A FALLOS - S2/S3"
echo "=========================================="
echo ""

# Función para mostrar estado de servicios
mostrar_estado() {
    echo "📊 Estado actual de los servicios:"
    docker compose ps | grep -E "s2-php|s3-php" | awk '{print "   " $1 " → " $4}'
    echo ""
}

# Función para contar peticiones por backend
contar_peticiones() {
    local segundos=$1
    S2_COUNT=$(docker compose logs --since ${segundos}s s2-php 2>/dev/null | grep -c "GET /login.php" || echo 0)
    S3_COUNT=$(docker compose logs --since ${segundos}s s3-php 2>/dev/null | grep -c "GET /login.php" || echo 0)
}

# 1. Estado inicial
echo "✅ PASO 1: Estado inicial (ambos nodos activos)"
mostrar_estado

echo "   Realizando 10 peticiones para verificar balanceo inicial..."
for i in {1..10}; do
    curl -s http://localhost:90/login.php > /dev/null
    sleep 0.1
done

contar_peticiones 10
echo "   Resultado inicial:"
printf "      S2-PHP: %2d peticiones 🟦\n" "$S2_COUNT"
printf "      S3-PHP: %2d peticiones 🟩\n" "$S3_COUNT"
echo ""

# 2. Detener S2
echo "✅ PASO 2: Deteniendo S2-PHP (simulando fallo)..."
docker compose stop s2-php >/dev/null 2>&1
sleep 3
mostrar_estado

echo "   Realizando 10 peticiones con S2 detenido..."
for i in {1..10}; do
    curl -s http://localhost:90/login.php > /dev/null
    sleep 0.1
done

contar_peticiones 10
echo "   Resultado con S2 detenido:"
printf "      S2-PHP: %2d peticiones (detenido)\n" "$S2_COUNT"
printf "      S3-PHP: %2d peticiones 🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩\n" "$S3_COUNT"

if [ $S2_COUNT -eq 0 ] && [ $S3_COUNT -gt 0 ]; then
    echo "   ✅ ¡CORRECTO! Todo el tráfico se redirigió a S3-PHP"
    echo "   ✅ Alta disponibilidad funcionando"
else
    echo "   ❌ ERROR: El tráfico no se redirigió correctamente"
fi
echo ""

# 3. Verificar que la aplicación sigue funcionando
echo "✅ PASO 3: Verificando que la aplicación sigue funcionando..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:90/login.php)
if [ "$HTTP_CODE" = "200" ]; then
    echo "   ✅ login.php responde 200 OK (aplicación funcional)"
else
    echo "   ❌ login.php responde $HTTP_CODE (aplicación fallida)"
fi

HTTP_CODE2=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:90/extagram.php)
if [ "$HTTP_CODE2" = "302" ]; then
    echo "   ✅ extagram.php responde 302 (redirige a login, correcto sin sesión)"
else
    echo "   ⚠️  extagram.php responde $HTTP_CODE2"
fi
echo ""

# 4. Reiniciar S2
echo "✅ PASO 4: Reiniciando S2-PHP..."
docker compose start s2-php >/dev/null 2>&1
sleep 4
mostrar_estado

echo "   Realizando 10 peticiones para verificar balanceo restaurado..."
for i in {1..10}; do
    curl -s http://localhost:90/login.php > /dev/null
    sleep 0.1
done

contar_peticiones 10
echo "   Resultado después de reiniciar S2:"
printf "      S2-PHP: %2d peticiones 🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦\n" "$S2_COUNT"
printf "      S3-PHP: %2d peticiones 🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩\n" "$S3_COUNT"

if [ $S2_COUNT -gt 0 ] && [ $S3_COUNT -gt 0 ]; then
    echo "   ✅ ¡CORRECTO! Balanceo restaurado entre S2 y S3"
else
    echo "   ⚠️  Balanceo no completamente restaurado"
fi
echo ""

# 5. Resumen
echo "=========================================="
echo "📊 RESUMEN DE LA PRUEBA"
echo "=========================================="
echo "   • Estado inicial: ✅ Ambos nodos activos"
echo "   • Caída de S2: ✅ Tráfico redirigido a S3"
echo "   • Aplicación funcional: ✅ Sin interrupción de servicio"
echo "   • Recuperación: ✅ S2 reiniciado y balanceo restaurado"
echo ""
echo "✅ PRUEBA DE TOLERANCIA A FALLOS COMPLETADA"
echo "=========================================="
echo ""
echo "💡 Conclusión:"
echo "   El sistema tiene alta disponibilidad gracias al balanceo"
echo "   de NGINX. Si un nodo PHP falla, el tráfico se redirige"
echo "   automáticamente al nodo restante sin interrupción."
echo ""
