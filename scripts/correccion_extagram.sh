#!/bin/bash
# corregir-extagram.sh

echo "=========================================="
echo "🔧 CORRECCIÓN DE EXTAGRAM.PHP"
echo "=========================================="
echo ""

# 1. Corregir conexión MySQL
echo "✅ Paso 1: Corrigiendo conexión MySQL..."
sed -i 's/localhost/s7-mysql/g' ~/extagram/s2-php/extagram.php
sed -i 's/localhost/s7-mysql/g' ~/extagram/s3-php/extagram.php
echo "   ✅ 'localhost' → 's7-mysql'"
echo ""

# 2. Corregir ruta de imágenes
echo "✅ Paso 2: Corrigiendo ruta de imágenes..."
sed -i "s|src='uploads/|src='/uploads/|g" ~/extagram/s2-php/extagram.php
sed -i "s|src='uploads/|src='/uploads/|g" ~/extagram/s3-php/extagram.php
echo "   ✅ 'uploads/' → '/uploads/'"
echo ""

# 3. Corregir ruta del CSS
echo "✅ Paso 3: Corrigiendo ruta del CSS..."
sed -i 's|href="style.css"|href="/style.css"|g' ~/extagram/s2-php/extagram.php
sed -i 's|href="style.css"|href="/style.css"|g' ~/extagram/s3-php/extagram.php
echo "   ✅ 'style.css' → '/style.css'"
echo ""

# 4. Verificar cambios
echo "✅ Paso 4: Verificando cambios..."
echo "   Conexión MySQL:"
grep "s7-mysql" ~/extagram/s2-php/extagram.php | head -1
echo ""
echo "   Ruta de imágenes:"
grep "src='/uploads/" ~/extagram/s2-php/extagram.php | head -1
echo ""
echo "   Ruta del CSS:"
grep 'href="/style.css"' ~/extagram/s2-php/extagram.php | head -1
echo ""

# 5. Reiniciar servicios
echo "✅ Paso 5: Reiniciando servicios..."
docker compose restart s2-php s3-php
sleep 3
echo "   ✅ Servicios reiniciados"
echo ""

echo "=========================================="
echo "✅ CORRECCIÓN COMPLETADA"
echo "=========================================="
echo ""
echo "💡 Ahora debes:"
echo "   1. Limpiar cookies del navegador"
echo "   2. Abrir http://98.93.180.196:90/login.php"
echo "   3. Iniciar sesión con admin/password"
echo ""
echo "📌 Si el error persiste:"
echo "   - Verifica logs: docker compose logs s2-php | tail -20"
echo "   - Prueba en modo incógnito del navegador"
echo ""
