
# PROJECTE 0.1 – Extagram (Guía para el cliente)

Esta guía explica **cómo acceder** a la aplicación Extagram y **qué deberías ver** en cada página.

---

## 1) Acceso a la web

1. Abre el navegador (Chrome/Firefox).
2. En la barra de direcciones escribe:

> http://<IP-PÚBLICA-DE-LA-EC2>/


### Qué vas a ver
- Una página web de Extagram.
- Un formulario para escribir un mensaje (post) y, si quieres, adjuntar una imagen.

---

## 2) Publicar un post (texto)

1. En el campo de texto, escribe tu mensaje.
2. Pulsa el botón **Publish** (o el botón de publicar).

### Qué va a pasar
- El post se guardará.
- Al recargar o volver a entrar en la web, el post seguirá apareciendo.

---

## 3) Publicar un post con imagen

1. Escribe un mensaje.
2. Pulsa el icono/área de subir archivo para elegir una imagen.
3. Selecciona una imagen desde tu ordenador.
4. Pulsa **Publish**.

### Qué vas a ver
- Antes de publicar, puede aparecer una **previsualización** de la imagen.
- Tras publicar, el post aparecerá en la lista con:
  - El texto del post.
  - La imagen subida (si se adjuntó).

---

## 4) Ver publicaciones anteriores

1. Baja por la página (scroll).
2. Verás una lista de posts publicados.

### Qué vas a ver
- Publicaciones en formato “post”.
- Algunas con imagen y otras solo con texto (según cómo se hayan publicado).

---

## 5) Página de login (si está activada)

Accede a: 
> http://<IP-PÚBLICA-DE-LA-EC2>/login.php


### Qué vas a ver
- Un formulario de login con usuario y contraseña.

### Qué debe hacer el cliente
- Introducir el usuario y contraseña proporcionados por el equipo.

> Nota: Si el login está configurado como demo, puede usarse:
> - Usuario: Admin  
> - Contraseña: 123456

---

## 6) Pantalla de bienvenida (después del login)

Si el login es correcto, se redirige a:

> http://<IP-PÚBLICA-DE-LA-EC2>/welcome.php


### Qué vas a ver
- Un mensaje de bienvenida.
- Un botón/enlace para cerrar sesión.

---

## 7) Cerrar sesión

Accede a:

> http://<IP-PÚBLICA-DE-LA-EC2>/logout.php


### Qué va a pasar
- La sesión se cierra y vuelve al login o a la página principal.

---

## 8) Qué hacer si algo falla

- Si al publicar no aparece el post, prueba a recargar (F5).
- Si no sube la imagen, prueba con otra (JPG/PNG) o una más pequeña.
- Si sale un error, haz una captura de pantalla y envíala al equipo indicando:
  - La URL donde estabas.
  - Qué estabas intentando hacer (post con foto, login, etc.).

---


