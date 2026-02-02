<?php
// Habilitar visualización de errores y reporte completo
ini_set('display_errors', 'On');
error_reporting(E_ALL);

echo "DEBUG: Script upload.php iniciado.<br>"; // DEBUG 1

// Configuración de errores para MySQLi
mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);

// Definir la ruta de la carpeta de subidas
$upload_dir = '/usr/share/nginx/html/uploads/';

if ($_SERVER['REQUEST_METHOD'] === 'POST' && !empty($_POST["post"])) {
    
    echo "DEBUG: Entrando al bloque POST.<br>"; // DEBUG 2

    $photoid = null;

    if (isset($_FILES['photo']) && $_FILES['photo']['error'] === UPLOAD_ERR_OK) {
        echo "DEBUG: Archivo de foto detectado sin errores.<br>"; // DEBUG 3
        $extension = pathinfo($_FILES['photo']['name'], PATHINFO_EXTENSION);
        $photoid = uniqid('extagram_') . "." . $extension;
        $target_path = $upload_dir . $photoid;

        if (!move_uploaded_file($_FILES['photo']['tmp_name'], $target_path)) {
            $error_info = error_get_last();
            die("Error crítico al mover el archivo. Detalles: " . print_r($error_info, true));
        }
        echo "DEBUG: Archivo movido con éxito a $target_path.<br>"; // DEBUG 4
    } else {
        echo "DEBUG: No hay foto o hubo un error de subida.<br>";
        if (isset($_FILES['photo'])) {
            echo "DEBUG: Error code: " . $_FILES['photo']['error'] . "<br>";
        }
    }

    try {
        echo "DEBUG: Intentando conectar a la BD.<br>"; // DEBUG 5
        $db = new mysqli("localhost", "extagram_admin", "pass123", "extagram_db");
        
        $stmt = $db->prepare("INSERT INTO posts (post, photourl) VALUES (?, ?)");
        $stmt->bind_param("ss", $_POST["post"], $photoid);
        $stmt->execute();
        $stmt->close();
        $db->close();
        echo "DEBUG: Datos guardados en BD con éxito.<br>"; // DEBUG 6

    } catch (Exception $e) {
        die("Error al guardar en BD: " . $e->getMessage());
    }
}

// Redirigir solo si todo el script se completó sin 'die()'
header("Location: extagram.php");
exit;
?>