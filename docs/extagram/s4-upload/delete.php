<?php
header('Content-Type: application/json');

// Configuración de errores (temporal para depuración)
ini_set('display_errors', 1);
error_reporting(E_ALL);

// Verificar solicitud
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(['success' => false, 'message' => 'Método no permitido']);
    exit;
}

// Obtener datos
$data = json_decode(file_get_contents('php://input'), true);
$post = $data['post'] ?? '';
$photourl = $data['photourl'] ?? '';

// Log para depuración
error_log("DELETE REQUEST - Post: '$post', Photourl: '$photourl'");

if (empty($post) && empty($photourl)) {
    echo json_encode(['success' => false, 'message' => 'Parámetros inválidos']);
    exit;
}

$upload_dir = '/usr/share/nginx/html/uploads/';
$filepath = $upload_dir . $photourl;

try {
    // Eliminar archivo si existe
    if (!empty($photourl)) {
        if (file_exists($filepath)) {
            if (unlink($filepath)) {
                error_log("Archivo eliminado: $filepath");
            } else {
                error_log("ERROR: No se pudo eliminar $filepath");
            }
        } else {
            error_log("Archivo no existe: $filepath");
        }
    }

    // Eliminar de la base de datos
    $db = new mysqli("localhost", "extagram_admin", "pass123", "extagram_db");
    
    // Preparar consulta
    $stmt = $db->prepare("DELETE FROM posts WHERE post = ? AND (photourl = ? OR (photourl IS NULL AND ? = '') OR (photourl = '' AND ? = ''))");
    $stmt->bind_param("ssss", $post, $photourl, $photourl, $photourl);
    $stmt->execute();
    
    $affected_rows = $stmt->affected_rows;
    error_log("Filas afectadas: $affected_rows");
    
    $stmt->close();
    $db->close();

    if ($affected_rows > 0) {
        echo json_encode(['success' => true, 'message' => "Eliminado $affected_rows fila(s)"]);
    } else {
        echo json_encode(['success' => false, 'message' => 'No se encontró el post para eliminar']);
    }
    
} catch (Exception $e) {
    error_log("ERROR BD: " . $e->getMessage());
    echo json_encode(['success' => false, 'message' => 'Error: ' . $e->getMessage()]);
}
exit;
?>
