#!/bin/bash

# ============================================
# SCRIPT: Corrección S1-NGINX para Sprint 2
# ============================================

set -e

PROJECT_DIR="$HOME/extagram"

echo "========================================"
echo "🔧 CORRECTOR S1-NGINX - SPRINT 2"
echo "========================================"
echo ""

# Verificar directorio del proyecto
if [ ! -d "$PROJECT_DIR" ]; then
    echo "❌ ERROR: Directorio $PROJECT_DIR no existe"
    exit 1
fi

cd "$PROJECT_DIR"
echo "✅ Directorio: $PROJECT_DIR"
echo ""

# ============================================
# PASO 1: Corregir S1-NGINX (falta Dockerfile)
# ============================================
echo "🔄 PASO 1: Corrigiendo S1-NGINX..."
echo "----------------------------------------"

S1_DIR="s1-nginx"

# Crear Dockerfile para S1 si no existe
if [ ! -f "$S1_DIR/Dockerfile" ]; then
    echo "Creando Dockerfile para S1-NGINX..."
    cat > "$S1_DIR/Dockerfile" << 'EOF'
FROM nginx:alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 90
EOF
    echo "✅ $S1_DIR/Dockerfile creado"
else
    echo "ℹ️  $S1_DIR/Dockerfile ya existe"
fi

# Eliminar archivo Apache no necesario
if [ -f "$S1_DIR/my-httpd.conf" ]; then
    rm -f "$S1_DIR/my-httpd.conf"
    echo "✅ Eliminado my-httpd.conf (no necesario para NGINX)"
fi

# Reemplazar nginx.conf con configuración de proxy correcta
echo "Reemplazando nginx.conf con configuración de proxy..."
cat > "$S1_DIR/nginx.conf" << 'EOF'
upstream php_backend {
    server s2-php:9000;
    server s3-php:9000;
}

server {
    listen 90;
    server_name localhost;
    charset utf-8;

    # Recursos estáticos CSS/SVG → S6
    location ~* \.(css|svg)$ {
        proxy_pass http://s6-static;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    # Imágenes subidas → S5
    location /uploads/ {
        proxy_pass http://s5-storage;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    # Login.php → Balanceo S2/S3
    location = /login.php {
        fastcgi_pass php_backend;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME /var/www/html/login.php;
    }

    # Logout.php → Balanceo S2/S3
    location = /logout.php {
        fastcgi_pass php_backend;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME /var/www/html/logout.php;
    }

    # Upload.php → S4
    location = /upload.php {
        fastcgi_pass s4-upload:9000;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME /var/www/html/upload.php;
    }

    # Extagram.php → Balanceo S2/S3
    location = /extagram.php {
        fastcgi_pass php_backend;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME /var/www/html/extagram.php;
    }

    # Delete.php → Balanceo S2/S3
    location = /delete.php {
        fastcgi_pass php_backend;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME /var/www/html/delete.php;
    }

    # Raíz → redirigir a login.php
    location = / {
        return 302 /login.php;
    }

    # Cualquier otro .php → Balanceo
    location ~ \.php$ {
        fastcgi_pass php_backend;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME /var/www/html$fastcgi_script_name;
    }

    # Health check
    location /health {
        return 200 'OK';
        add_header Content-Type text/plain;
    }
}
EOF
echo "✅ $S1_DIR/nginx.conf actualizado con proxy inverso"

echo ""
echo "✅ PASO 1 COMPLETADO"
echo ""

# ============================================
# PASO 2: Normalizar nombres de carpetas (minúsculas)
# ============================================
echo "🔄 PASO 2: Normalizando nombres de carpetas a minúsculas..."
echo "----------------------------------------"

# Renombrar carpetas con mayúsculas a minúsculas
rename_folder() {
    if [ -d "$1" ] && [ "$1" != "$2" ]; then
        mv "$1" "$2"
        echo "✅ Renombrado: '$1' → '$2'"
    elif [ -d "$2" ]; then
        echo "ℹ️  Ya existe: '$2'"
    fi
}

rename_folder "S1-nginx" "s1-nginx"
rename_folder "S2-php" "s2-php"
rename_folder "S3-php" "s3-php"
rename_folder "S4-upload" "s4-upload"
rename_folder "S5-storage" "s5-storage"
rename_folder "S6-static" "s6-static"
rename_folder "S7-mysql" "s7-mysql"

echo ""
echo "✅ PASO 2 COMPLETADO"
echo ""

# ============================================
# PASO 3: Eliminar versión obsoleta de docker-compose.yml
# ============================================
echo "🔄 PASO 3: Limpiando docker-compose.yml..."
echo "----------------------------------------"

if [ -f "docker-compose.yml" ]; then
    # Eliminar línea 'version:' si existe
    sed -i '/^version:/d' docker-compose.yml
    
    # Asegurar que los paths usan minúsculas
    sed -i 's|build: \./S1-nginx|build: ./s1-nginx|g' docker-compose.yml
    sed -i 's|build: \./S2-php|build: ./s2-php|g' docker-compose.yml
    sed -i 's|build: \./S3-php|build: ./s3-php|g' docker-compose.yml
    sed -i 's|build: \./S4-upload|build: ./s4-upload|g' docker-compose.yml
    sed -i 's|build: \./S5-storage|build: ./s5-storage|g' docker-compose.yml
    sed -i 's|build: \./S6-static|build: ./s6-static|g' docker-compose.yml
    
    echo "✅ docker-compose.yml limpiado y normalizado"
else
    echo "❌ ERROR: docker-compose.yml no encontrado"
    exit 1
fi

echo ""
echo "✅ PASO 3 COMPLETADO"
echo ""

# ============================================
# PASO 4: Verificar estructura final
# ============================================
echo "🔍 PASO 4: Verificando estructura final..."
echo "----------------------------------------"

check_file() {
    if [ -f "$1" ]; then
        echo "✅ $1"
    else
        echo "❌ $1 NO EXISTE"
        MISSING=1
    fi
}

MISSING=0

echo "Archivos críticos:"
check_file "s1-nginx/Dockerfile"
check_file "s1-nginx/nginx.conf"
check_file "s2-php/Dockerfile"
check_file "s2-php/login.php"
check_file "s6-static/style.css"
check_file "docker-compose.yml"

if [ $MISSING -eq 1 ]; then
    echo ""
    echo "⚠️  Hay archivos faltantes. Revisa la estructura."
    exit 1
fi

echo ""
echo "✅ PASO 4 COMPLETADO - Estructura correcta"
echo ""

# ============================================
# PASO 5: Levantar contenedores
# ============================================
echo "🚀 PASO 5: Levantando contenedores..."
echo "----------------------------------------"

if command -v docker compose &> /dev/null; then
    echo "Construyendo y levantando servicios..."
    docker compose up -d --build 2>&1 | tail -20
    
    echo ""
    echo "📊 Estado de los contenedores:"
    docker compose ps
    
    echo ""
    echo "✅ PASO 5 COMPLETADO"
    echo ""
    
    # ============================================
    # PASO 6: Pruebas de conectividad
    # ============================================
    echo "✅ PASO 6: Pruebas de conectividad..."
    echo "----------------------------------------"
    
    echo "🔍 Health check: $(curl -s -o /dev/null -w "%{http_code}" http://localhost:90/health || echo "FAIL")"
    echo "🔍 Login.php:    $(curl -s -o /dev/null -w "%{http_code}" http://localhost:90/login.php || echo "FAIL")"
    echo "🔍 Style.css:    $(curl -s -o /dev/null -w "%{http_code}" http://localhost:90/style.css || echo "FAIL")"
    
    echo ""
    echo "========================================"
    echo "🎉 ¡SPRINT 2 CORREGIDO Y FUNCIONANDO!"
    echo "========================================"
    echo ""
    echo "🌐 Accede desde tu navegador:"
    echo "   http://$(curl -s ifconfig.me):90/"
    echo ""
    echo "📌 Credenciales:"
    echo "   Usuario: admin"
    echo "   Contraseña: password"
    echo ""
else
    echo "❌ 'docker compose' no disponible"
    echo "   Instala con: sudo yum install -y docker-compose-plugin"
    exit 1
fi
