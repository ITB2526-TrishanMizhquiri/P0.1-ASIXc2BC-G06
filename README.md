# PROJECTE 0.1 - Desplegament extagram

## Lanzamiento de la máquina AWS
- Lanzamiento del Laboratorio para el alumnado de AWS Academy

![Texto Alternativo](/img/image.png)

- Abro la consola AWS para cerar instancia

![Texto Alternativo](/img/image1.png)

- Termino creando la instancia

![Texto Alternativo](/img/image2.png)

- Ya la ejecuto y los datos

![Texto Alternativo](/img/image3.png)


## Conexión de la máquina AWS con ssh

![Texto Alternativo](/img/image4.png)

- Actualización de sistema

![Texto Alternativo](/img/image5.png)

## Tecnologias implicadas
- NGINX / Apache
- PHP-FPM
- MySQL

### Instalacion de cada servicio
***Intalación de php***
> sudo yum install -y httpd php

![Texto](/img/image.png)

**Verificar configuración de PHP para subida de archivos**
> sudo nano /etc/php.ini

![Texto](/img/arxiuphp.png)

![Texto](/img/anterior.png)

Cambiamos los datos segun nuestras necesidades
![Texto](/img/nuevo.png)

***Instalación de Mysql***
> sudo dnf install -y nginx php-fpm php-mysqlnd mariadb105-server
![Texto](/img/install.png)

***Estado de Mysql***
> sudo systemctl status nginx php-fpm mariadb
![Texto](/img/status2.png)

***Instalación BBDD***
> sudo mysql_secure_installation
![Texto](/img/mysql_installation.png)

***Creando BBDD***
> sudo mysql -u root
![Texto](/img/create_bbdd.png)

***BBDD creada***
> SHOW DATABASES;
![Texto](/img/database.png)

***Intalación de Nginx***
> sudo yum install -y nginx
![Texto](/img/nginx.png)

**Verificar instalación con systemctl**
> sudo systemctl status nginx
![Texto](/img/status.png)

**Verificar instalación con curl**
> curl -I http://localhost
![Texto](/img/curl.png)

***Configuración de nginx para login***

Crear un nuevo archivo de sitio
> sudo nano /etc/nginx/conf.d/site.conf

![Texto](/img/site.png)

Verificar que PHP-FPM escucha en 127.0.0.1:9000
> Verificar que PHP-FPM escucha en 127.0.0.1:9000

![Texto](/img/antesphp.png)

![Texto](/img/nuevophp.png)

Recargar Nginx
> sudo nginx -t
> sudo systemctl reload nginx

Crear una página de login simple en PHP
> sudo nano /usr/share/nginx/html/login.php

![Texto](/img/login.png)

Crea el archivo auth.php

![Texto](/img/auth.png)

Crea la página de bienvenida welcome.php

![Texto](/img/welcome.png)

Crea el archivo logout.php

![Texto](/img/logout.png)

Verifica permisos
> sudo chown -R nginx:nginx /usr/share/nginx/html/
> sudo chmod -R 755 /usr/share/nginx/html/

Prueba 
> http://<tu-ip-publica>/login.php

![Texto](/img/loginphp.png)

![Texto](/img/inicio.png)

usuario: Admin
contraseña: 123456
