<?php
ob_start();
mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);
$upload_dir = '/var/www/html/uploads/';

if ($_SERVER['REQUEST_METHOD'] === 'POST' && !empty($_POST["post"])) {
    $photoid = null;
    
    if (isset($_FILES['photo']) && $_FILES['photo']['error'] === UPLOAD_ERR_OK) {
        $extension = pathinfo($_FILES['photo']['name'], PATHINFO_EXTENSION);
        $photoid = uniqid('extagram_') . "." . $extension;
        $target_path = $upload_dir . $photoid;
        
        if (!move_uploaded_file($_FILES['photo']['tmp_name'], $target_path)) {
            $error_info = error_get_last();
            die("Error al mover el archivo: " . print_r($error_info, true));
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
