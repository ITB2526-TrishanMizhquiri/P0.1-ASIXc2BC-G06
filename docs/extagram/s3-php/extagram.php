<?php
session_start();
// Si no tienes login.php aún, puedes comentar estas 4 líneas para probar
if (!isset($_SESSION['user_id'])) {
    header("Location: login.php");
    exit;
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Extagram 2026</title>
    <link rel="stylesheet" href="style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>
    <div class="container">
        <header class="header">
            <div class="logo">
                <i class="fas fa-camera"></i>
                <span>Extagram</span>
            </div>
            <div class="user-info">
                <span>👤 <?php echo htmlspecialchars($_SESSION['username'] ?? 'Usuario'); ?></span>
                <a href="logout.php" class="logout-btn">Cerrar sesión</a>
            </div>
        </header>

        <main class="main-content">
            <div class="create-post">
                <form method="POST" enctype="multipart/form-data" action="upload.php" class="post-form">
                    <div class="input-group">
                        <input type="text" name="post" placeholder="¿En qué piensas?" required>
                    </div>
                    
                    <div class="image-upload">
                        <input id="file" type="file" name="photo" accept="image/*" onchange="document.getElementById('preview').src=window.URL.createObjectURL(this.files[0])" hidden>
                        <label for="file" class="upload-label" style="cursor: pointer; color: blue;">
                            <i class="fas fa-image"></i> Seleccionar imagen
                        </label>
                    </div>
                    
                    <div class="preview-container">
                        <img id="preview" src="preview.svg" alt="Vista previa">
                    </div>
                    
                    <button type="submit" class="publish-btn">
                        <i class="fas fa-paper-plane"></i> Publicar
                    </button>
                </form>
            </div>

            <hr>

            <div class="posts-container">
                <?php
                // Configuración de errores para ver qué pasa si falla
                mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);
                try {
                    $db = new mysqli("s7-mysql", "extagram_admin", "pass123", "extagram_db");
                    
                    // ✅ CONSULTA CORREGIDA: Sin "ORDER BY id" porque no existe en tu DB
                    $result = $db->query("SELECT post, photourl FROM posts"); 
                    
                    // Convertimos a array para mostrar los últimos primero (inversión manual)
                    $rows = [];
                    while ($fila = $result->fetch_assoc()) {
                        $rows[] = $fila;
                    }
                    $rows = array_reverse($rows);

                    foreach ($rows as $fila) {
                        echo "<div class='post'>";
                        
                        // Botón de eliminar usando el texto y la imagen como referencia
                        echo "<button class='delete-btn' 
                            data-post='" . htmlspecialchars($fila['post'], ENT_QUOTES) . "' 
                            data-photourl='" . htmlspecialchars($fila['photourl'], ENT_QUOTES) . "'
                            onclick='deletePost(this)'>&times;</button>";
                        
                        echo "<div class='post-content'>";
                        echo "<p><strong>" . htmlspecialchars($fila['post']) . "</strong></p>";
                        
                        if (!empty($fila['photourl'])) {
                            echo "<div class='post-image'>";
                            // Buscamos en la carpeta uploads/
                            echo "<img src='uploads/" . htmlspecialchars($fila['photourl']) . "' alt='Post image'>";
                            echo "</div>";
                        }
                        echo "</div>";
                        
                        echo "<div class='post-footer' style='padding: 10px;'>";
                        echo "<span><i class='far fa-heart'></i> 0</span> ";
                        echo "<span><i class='far fa-comment'></i> 0</span>";
                        echo "</div>";
                        echo "</div>";
                    }
                    $db->close();
                } catch (Exception $e) {
                    echo "<div class='error-message' style='color: red;'>";
                    echo "<i class='fas fa-exclamation-triangle'></i>";
                    echo "<p>Error: " . htmlspecialchars($e->getMessage()) . "</p>";
                    echo "</div>";
                }
                ?>
            </div>
        </main>

        <footer class="footer" style="text-align: center; margin-top: 20px; color: #888;">
            <p>&copy; 2026 Extagram - Laboratorio EC2</p>
        </footer>
    </div>

    <script>
    function deletePost(button) {
        const post = button.getAttribute('data-post');
        const photourl = button.getAttribute('data-photourl');
        
        if (confirm('¿Quieres eliminar esta publicación?')) {
            fetch('delete.php', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ 
                    post: post,
                    photourl: photourl
                })
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    location.reload();
                } else {
                    alert('Error al eliminar: ' + (data.message || 'Inténtalo de nuevo'));
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert('Error de conexión');
            });
        }
    }
    </script>
</body>
</html>