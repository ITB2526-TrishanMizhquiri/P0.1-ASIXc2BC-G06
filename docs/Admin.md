# Intalación de php
> sudo yum install -y httpd php
![Texto](/img/image.png)

- Verificar configuración de PHP para subida de archivos
> sudo nano /etc/php.ini
![Texto](/img/arxiuphp.png)
![Texto](/img/anterior.png)

- Cambiamos los datos segun nuestras necesidades
![Texto](/img/nuevo.png)

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


## Instalación de mariadb
> sudo dnf install -y nginx php-fpm php-mysqlnd mariadb105-server
![Texto](/img/install.png)

- Estado de mariadb
> sudo systemctl status nginx php-fpm mariadb
![Texto](/img/status2.png)

- Instalación BBDD
> sudo mysql_secure_installation
![Texto](/img/mysql_installation.png)

- Creando BBDD
> sudo mysql -u root
![Texto](/img/create_bbdd.png)

- BBDD creada
> SHOW DATABASES;
![Texto](/img/database.png)



