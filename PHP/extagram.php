<?php
session_start();
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
                        <input type="text" name="post" placeholder="Write something..." required>
                    </div>
                    
                    <div class="image-upload">
                        <input id="file" type="file" name="photo" accept="image/*" onchange="document.getElementById('preview').src=window.URL.createObjectURL(this.files[0])" hidden>
                        <label for="file" class="upload-label">
                            <i class="fas fa-image"></i> Seleccionar imagen
                        </label>
                    </div>
                    
                    <div class="preview-container">
                        <img id="preview" src="preview.svg" alt="Preview">
                    </div>
                    
                    <button type="submit" class="publish-btn">
                        <i class="fas fa-paper-plane"></i> Publish
                    </button>
                </form>
            </div>

            <div class="posts-container">
                <?php
                mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);
                try {
                    $db = new mysqli("localhost", "extagram_admin", "pass123", "extagram_db");
                    
                    // ✅ ORDENAR DE MÁS RECIENTE A MÁS ANTIGUO
                    $result = $db->query("SELECT * FROM posts ORDER BY id DESC"); 
                    
                    while ($fila = $result->fetch_assoc()) {
                        echo "<div class='post'>";
                        
                        echo "<button class='delete-btn' 
                            data-post='" . htmlspecialchars($fila['post'], ENT_QUOTES) . "' 
                            data-photourl='" . htmlspecialchars($fila['photourl'], ENT_QUOTES) . "'
                            onclick='deletePost(this)'>&times;</button>";
                        
                        echo "<div class='post-content'>";
                        echo "<p>" . htmlspecialchars($fila['post']) . "</p>";
                        if (!empty($fila['photourl'])) {
                            echo "<div class='post-image'>";
                            echo "<img src='uploads/" . htmlspecialchars($fila['photourl']) . "' alt='Post image'>";
                            echo "</div>";
                        }
                        echo "</div>";
                        echo "<div class='post-footer'>";
                        echo "<span><i class='far fa-heart'></i> 0</span>";
                        echo "<span><i class='far fa-comment'></i> 0</span>";
                        echo "</div>";
                        echo "</div>";
                    }
                    $db->close();
                } catch (Exception $e) {
                    echo "<div class='error-message'>";
                    echo "<i class='fas fa-exclamation-triangle'></i>";
                    echo "<p>Error de conexión: " . htmlspecialchars($e->getMessage()) . "</p>";
                    echo "</div>";
                }
                ?>
            </div>
        </main>

        <footer class="footer">
            <p>&copy; 2026 Extagram - Todos los derechos reservados</p>
        </footer>
    </div>

    <script>
    function deletePost(button) {
        const post = button.getAttribute('data-post');
        const photourl = button.getAttribute('data-photourl');
        
        if (confirm('¿Eliminar este post?')) {
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
                    window.location.reload();
                } else {
                    alert('Error: ' + (data.message || 'No se pudo eliminar'));
                }
            })
            .catch(error => {
                alert('Error de conexión con el servidor');
                console.error('Error:', error);
            });
        }
    }
    </script>
</body>
</html>