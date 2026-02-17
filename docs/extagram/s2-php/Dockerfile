FROM php:8.2-fpm

# Instalar extensiones MySQL
RUN docker-php-ext-install mysqli pdo pdo_mysql

# Establecer directorio de trabajo
WORKDIR /var/www/html

# Exponer puerto 9000
EXPOSE 9000

# Configurar directorio de sesiones
RUN mkdir -p /var/lib/php/sessions && \
    chown -R www-data:www-data /var/lib/php/sessions && \
    chmod -R 777 /var/lib/php/sessions

# Añadir configuración personalizada
COPY php-sessions.ini /usr/local/etc/php/conf.d/
COPY php-cookies.ini /usr/local/etc/php/conf.d/

# Configuración de cookies
COPY php-cookies.ini /usr/local/etc/php/conf.d/

# Configuración de cookies
COPY php-cookies.ini /usr/local/etc/php/conf.d/

# Configuración de cookies
COPY php-cookies.ini /usr/local/etc/php/conf.d/

