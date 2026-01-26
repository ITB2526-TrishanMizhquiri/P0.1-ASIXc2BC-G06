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
- NGINX vs Apache
  > Nginx consume menos recursos y maneja mejor conexiones concurrentes que Apache 
- PHP FPM
  > Usamos PHP-FPM porque separa PHP del webserver: si un script falla o se cuelga, nginx sigue sirviendo imágenes/CSS sin caerse. Con mod_php todo el Apache se satura.
- MariaDB vs MySql
  > MariaDB porque su imagen Docker Alpine es 4x más pequeña y ligera que MySQL oficial, mismo SQL pero menos RAM

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

***Instalación de Mariadb***
> sudo dnf install -y nginx php-fpm php-mysqlnd mariadb105-server
![Texto](/img/install.png)

***Estado de Mariadb***
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

***Conexion entre php y BBDD***
Verificar que l’extensió estigui carregada
> echo "<?php phpinfo(); ?>" | sudo tee /usr/share/nginx/html/phpinfo.php
> http://localhost/phpinfo.php

![Texto](/img/busca.png)

Provar la connexió amb un script PHP

![Texto](/img/script.png)

***Directorio Uploads y permisos***

Buscamos los archivos upload.php y extragram.php en todos los archivos del servidor para ver si esta creada
> sudo find / -type f \( -name "upload.php" -o -name "extagram.php" \) 2>/dev/null | head

![Texto](/img/buscando_archivos_upload.php.png)

Nos metemos dentro de la carpeta donde encontramos el archivo upload y ya estaba creada
> cd /usr/share/nginx/html

![Texto](/img/Upload_ya_creada.png)

Le damos los permisos a uploads para poder modificar el archivo 
> sudo chmod 775 uploads
> ls -ld updoats

![Texto](/img/permisos_uploads.png)

Comprobamos que si se puede enviar archivos y mensajes a la carpeta enviando una prueba en la que sale el resultado OK
> sudo -u nginx sh -c 'touch /usr/share/nginx/html/uploads/prueba.txt && rm /usr/share/nginx/html/uploads/prueba.txt' && echo OK

![Texto](/img/comprobando_permisos.png)


## Requisitos funcionales (lo que la web permite hacer)

- Entrar a la página y que se vea correctamente.
- Escribir un mensaje y enviarlo.
- Subir una foto junto al mensaje (o publicar solo texto).
- Que lo que envías se guarde y no se pierda al recargar.
- Ver una lista con las publicaciones que ya se han hecho.
- Que en cada publicación se vea el texto y, si hay foto, también la foto.
- Que los botones y la web respondan bien (que no se quede bloqueado al darle a publicar).
- Si algo sale mal, que la web lo indique de alguna manera.

## Requisitos no funcionales (cómo debe ir la web)

- Que no se caiga fácilmente y, si algo falla, se recupere rápido.
- Que cargue a una velocidad razonable.
- Que, con varias personas entrando a la vez, siga funcionando bien.
- Que las fotos se guarden en un sitio preparado para eso y con permisos correctos 
- Que sea fácil de volver a montar en otro servidor siguiendo los pasos.
- Que quede claro qué se ha cambiado y cuándo.
- Que sea fácil encontrar errores si pasa algo.


