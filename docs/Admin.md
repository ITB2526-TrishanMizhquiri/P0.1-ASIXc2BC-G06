# Intalación de php
> sudo yum install -y httpd php

[Texto](P0.1-ASIXc2BC-G06/img/image.png)

## Verificar configuración de PHP para subida de archivos
> sudo nano /etc/php.ini

Instalación de Mysl
>

## Instalación de Nginx
>sudo yum install -y nginx
![Texto](/img/nginx.png)

- Verificar instalacion
> sudo systemctl status nginx
![Texto](/img/status.png)

- Verificación con curl
> curl -I http://localhost
![Texto](/img/curl.png)

- Configuración de nginx para login
> sudo nano /etc/nginx/conf.d/site.conf
![Texto](/img/site.png)

- Recargar Nginx
> sudo nginx -t sudo systemctl reload nginx

- Crear una página de login simple en PHP
> sudo nano /usr/share/nginx/html/login.php




