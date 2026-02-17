#!/bin/bash
# corregir-upload-definitivo.sh

echo "=========================================="
echo "🔧 CORRECCIÓN DEFINITIVA DE UPLOAD.PHP"
echo "=========================================="
echo ""

# 1. Corregir upload.php
echo "✅ Paso 1: Corrigiendo upload.php..."
cat > ~/extagram/s4-upload/upload.php << 'EOF'
<?php
mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);
$upload_dir = '/var/www/html/uploads/';

if ($_SERVER['REQUEST_METHOD'] === 'POST' && !empty($_POST["post"])) {
    $photoid = null;
    
    if (isset($_FILES['photo']) && $_FILES['photo']['error'] === UPLOAD_ERR_OK) {
        $extension = pathinfo($_FILES['photo']['name'], PATHINFO_EXTENSION);
        $photoid = uniqid('extagram_') . "." . $extension;
        $target_path = $upload_dir . $photoid;
        
        if (!move_uploaded_file($_FILES['photo']['tmp_name'], $target_path)) {
            die("Error al mover el archivo");
        }
    }
    
    try {
        $db = new mysqli("s7-mysql", "extagram_admin", "pass123", "extagram_db");
        $stmt = $db->prepare("INSERT INTO posts (post, photourl) VALUES (?, ?)");
        $stmt->bind_param("ss", $_POST["post"], $photoid);
        $stmt->execute();
        $stmt->close();
        $db->close();
    } catch (Exception $e) {
        die("Error en BD: " . $e->getMessage());
    }
}

header("Location: extagram.php");
exit;
?>
EOF

echo "   ✅ upload.php corregido"
echo ""

# 2. Reiniciar S4
echo "✅ Paso 2: Reiniciando S4-Upload..."
docker compose restart s4-upload
sleep 4
echo "   ✅ S4-Upload reiniciado"
echo ""

# 3. Verificar estructura de la tabla
echo "✅ Paso 3: Verificando estructura de la tabla..."
docker compose exec s7-mysql mysql -u extagram_admin -ppass123 extagram_db -e "DESCRIBE posts;"
echo ""

# 4. Probar subida
echo "✅ Paso 4: Probando subida de imagen..."
curl -F "post=Prueba Upload" -F "photo=@/usr/share/nginx/html/preview.svg" http://localhost:90/upload.php > /dev/null 2>&1
sleep 2

# 5. Verificar registro
echo "✅ Paso 5: Verificando registro en base de datos..."
docker compose exec s7-mysql mysql -u extagram_admin -ppass123 extagram_db -e "SELECT * FROM posts WHERE post='Prueba Upload';"
echo ""

# 6. Verificar imagen
echo "✅ Paso 6: Verificando imagen en S5..."
docker compose exec s5-storage ls -la /usr/share/nginx/html/uploads/ | tail -3
echo ""

echo "=========================================="
echo "✅ CORRECCIÓN COMPLETA"
echo "=========================================="
echo ""
echo "⚠️  AHORA:"
echo "   1. Abre http://98.93.180.196:90/upload.php"
echo "   2. Sube una imagen con texto"
echo "   3. Verifica que aparezca en extagram.php"
echo ""
