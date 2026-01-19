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

***Instalación de Mysl***
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
