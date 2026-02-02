# PROJECTE 0.1 - Despliegue y Configuración en AWS
## Índice

1. [Despliegue en AWS](#1-despliegue-en-aws)
    - [Creación de Instancia EC2](#11-creación-de-instancia-ec2)
        - [Conexión mediante SSH](#111-conexión-mediante-ssh)
    - [Actualización del sistema](#12-actualización-del-sistema)
2. [Tecnologías utilizadas](#2-tecnologías-utilizadas)
    - [NGINX vs Apache](#21-nginx-vs-apache)
    - [PHP-FPM vs mod_php](#22-php-fpm-vs-mod_php)
    - [MariaDB vs MySQL](#23-mariadb-vs-mysql)
    - [Comparativa de Tecnologías](#24-comparativa-de-tecnologías)
3. [Instalación y Configuración](#3-instalación-y-configuración)
    - [Instalación de PHP](#31-instalación-de-php)
    - [Configuración de PHP](#32-configuración-de-php)
    - [Instalación de MariaDB](#33-instalación-de-mariadb)
    - [Configuración de MariaDB](#34-configuración-de-mariadb)
    - [Instalación de NGINX](#35-instalación-de-nginx)
    - [Configuración de NGINX](#36-configuración-de-nginx)
4. [Base de datos](#4-base-de-datos)
5. [Archivos del Proyecto](#5-archivos-del-proyecto)
6. [Permisos y Seguridad](#6-permisos-y-seguridad)
7. [Requisitos Funcionales](#7-requisitos-funcionales)
8. [Requisitos No Funcionales](#8-requisitos-no-funcionales)



## 1. Despliegue en AWS

### 1.1 Creación de Instancia EC2
- Lanzamiento del laboratorio de **AWS Academy**.  
- Abrir consola AWS y crear instancia EC2.  
- Selección de AMI: **Amazon Linux 2**.  
- Tipo de instancia: **t2.micro** (nivel gratuito).  
- Configuración de **grupo de seguridad**: puertos 22 (SSH), 80 (HTTP), 443 (HTTPS).  
- Generación de par de claves SSH.

![Instancia EC2](/img/instancia-ec2.png)

#### 1.1.1. Conexión mediante SSH
    ssh -i "clave.pem" ec2-user@tu-ip-publica

![Conexión SSH](/img/conexión-ssh.png)

### 1.2 Actualización del sistema
    sudo yum update -y

![Actualización Sistema](/img/actualización-sistema.png)


## 2. Tecnologías utilizadas
### 2.1. NGINX vs Apache

<p align="center">
  <img src="img/nginx-apache.png" alt="NGINX vs Apache" width="500" />
</p>


Se eligió **NGINX** como servidor web principal en lugar de **Apache** por varias razones:

- **Arquitectura basada en eventos:** NGINX maneja un gran número de conexiones concurrentes de manera más eficiente, mientras que Apache utiliza un modelo basado en procesos o hilos, que consume más memoria y CPU bajo carga alta.
- **Consumo de recursos:** NGINX es más ligero, lo que lo hace ideal para entornos cloud con recursos limitados (por ejemplo, **t2.micro** en AWS).
- **Rendimiento en contenido estático:** NGINX entrega archivos estáticos mucho más rápido que Apache, reduciendo tiempos de carga.
- **Estabilidad bajo carga:** Su diseño evita que el servidor se bloquee ante picos de tráfico, ofreciendo mayor confiabilidad para aplicaciones web modernas.

En resumen, **NGINX ofrece mayor eficiencia, estabilidad y escalabilidad** frente a Apache, especialmente en entornos con tráfico variable o alto número de conexiones simultáneas.

---

### 2.2. PHP-FPM vs mod_php

<p align="center">
  <img src="img/phpfpm-modphp.png" alt="PHP-FPM vs mod_php" width="500" />
</p

Se eligió **PHP-FPM (FastCGI Process Manager)** en lugar de **mod_php** por varias razones clave:

- **Separación de responsabilidades:** PHP-FPM ejecuta los scripts PHP de forma independiente del servidor web, mientras que mod_php ejecuta PHP dentro del mismo proceso de Apache. Esto significa que si un script falla, **NGINX sigue funcionando sin interrupciones**, garantizando mayor estabilidad.
- **Eficiencia y rendimiento:** PHP-FPM permite manejar múltiples procesos PHP de manera optimizada y controlada, ajustando memoria, número de procesos y tiempos de ejecución. Esto resulta más eficiente que mod_php, que consume más memoria y recursos al correr PHP dentro del servidor web.
- **Compatibilidad con NGINX:** NGINX no soporta módulos PHP como Apache, por lo que PHP-FPM es la opción natural y recomendada para esta combinación.
- **Escalabilidad y seguridad:** Al separar la ejecución de PHP del servidor web, se facilita el aislamiento de procesos, la gestión de usuarios y la implementación de entornos escalables o contenedores, mejorando tanto la seguridad como la capacidad de escalar la aplicación.

En resumen, **PHP-FPM ofrece estabilidad, rendimiento y compatibilidad con NGINX**, mientras que mod_php sería más limitado y pesado, especialmente en entornos cloud con recursos limitados.

---

### 2.3. MariaDB vs MySQL

<p align="center">
  <img src="img/mysql-mariadb.png" alt="MariaDB vs MySQL" width="500" />
</p>

Se optó por **MariaDB** como sistema gestor de bases de datos en lugar de **MySQL** por varias razones:

- **Ligereza y rendimiento:** MariaDB es más ligera que MySQL, lo que se traduce en un mejor rendimiento en instancias con recursos limitados.
- **Compatibilidad completa:** Mantiene **compatibilidad total con SQL y con las APIs de MySQL**, permitiendo migraciones sencillas y sin necesidad de cambiar el código de la aplicación.
- **Desarrollo activo y comunidad:** Al ser un proyecto de código abierto con desarrollo activo, MariaDB recibe mejoras constantes en rendimiento, seguridad y estabilidad, mientras que algunas versiones de MySQL tienen ciclos de actualización más conservadores.
- **Funciones avanzadas:** MariaDB ofrece características adicionales como motores de almacenamiento optimizados, mejoras en replicación y mejor soporte para entornos modernos.

En resumen, **MariaDB combina compatibilidad, eficiencia y soporte activo**, siendo una alternativa moderna y confiable frente a MySQL.

### 2.4. Comparativa de Tecnologías

| Tecnología | Opción 1 | Opción 2 | Justificación de la elección |
|------------|----------|----------|------------------------------|
| Servidor web | **NGINX** | Apache | NGINX consume menos recursos, maneja mejor conexiones concurrentes, entrega contenido estático más rápido y es más estable bajo carga, ideal para entornos cloud. |
| Procesamiento PHP | **PHP-FPM** | mod_php | PHP-FPM separa la ejecución de PHP del servidor web, permite mejor control de procesos y memoria, mejora la estabilidad y es compatible con NGINX, mientras que mod_php es más pesado y limitado. |
| Base de datos | **MariaDB** | MySQL | MariaDB es más ligera, mantiene compatibilidad total con MySQL, tiene desarrollo activo, mejor rendimiento y funciones avanzadas, siendo ideal para entornos modernos y con recursos limitados. |

## 3. Instalación y configuración

### 3.1 Instalación de PHP
    sudo yum install -y httpd php

![PHP FPM](/img/php-fpm.png)

Comprobación del estado de los servicios para garantizar que PHP FPM está operativo.

![Comprobación Servicios](/img/systemctl-php.png)

### 3.2 Configuración de PHP
#### 3.2.1. Edición del archivo php.ini

Modificación del archivo de configuración principal de PHP para optimizar la subida de archivos multimedia.

    sudo nano /etc/php.ini

![Archivo PHP](/img/arxiuphp.png)

#### 3.2.2. Parámetros de configuración modificados

| Directiva             | Valor Original | Valor Configurado | Justificación Técnica                                                                 |
|-----------------------|----------------|-----------------|--------------------------------------------------------------------------------------|
| upload_tmp_dir        | 2M             | 10M             | Permite la subida de imágenes de mayor resolución (hasta 10MB), necesario para contenido multimedia moderno |
| upload_max_filesize   | 8M             | 50M             | Debe ser superior a upload_max_filesize para incluir el payload completo del formulario (archivo + metadatos) |
| max_file_upload       | 20             | 300             | Incrementa el timeout de ejecución a 300 segundos para evitar interrupciones en subidas lentas o procesamiento de imágenes |

![Nuevo Archivo PHP](/img/nuevo.png)

### 3.3 Instalación de MariaDB
    sudo dnf install -y nginx php-fpm php-mysqlnd mariadb105-server

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


