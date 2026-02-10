FROM php:8.2-fpm

# Instalar extensiones MySQL
RUN docker-php-ext-install mysqli pdo pdo_mysql

# Establecer directorio de trabajo
WORKDIR /var/www/html

# Exponer puerto 9000
EXPOSE 9000
