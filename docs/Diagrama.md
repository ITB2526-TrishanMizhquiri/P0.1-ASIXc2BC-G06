# Proyecto Extagram - Topología de Red

## 1. Diseño de la Infraestructura
Se ha diseñado una topología en Cisco Packet Tracer que segrega la aplicación en 7 servidores independientes (simulando contenedores Docker) para garantizar alta disponibilidad y escalabilidad.

### Esquema de Servidores (S1 - S7)

| ID | Servicio | Dirección IP | Función Técnica |
| :--- | :--- | :--- | :--- |
| **S1** | **Load Balancer** | `192.168.1.1` | Proxy inverso (Nginx).Recibe peticiones y balancea hacia S2/S3. |
| **S2** | **Extagram PHP A** | `192.168.1.10` |Nodo A: Ejecuta la parte dinámica `extagram.php`. |
| **S3** | **Extagram PHP B** | `192.168.1.11` |Nodo B: Ejecuta la parte dinámica `extagram.php`. |
| **S4** | **Upload PHP** | `192.168.1.20` |Gestiona subidas mediante `upload.php` hacia el directorio de imágenes. |
| **S5** | **Images Server** | `192.168.1.30` |Servidor Nginx dedicado a servir el contenido de `/uploads`. |
| **S6** | **Static Server** | `192.168.1.40` |Servidor Nginx para archivos fijos: `style.css` y `preview.svg`. |
| **S7** | **Database** | `192.168.1.50` | MySQL. Almacena posts y sirve de respaldo para las imágenes. |



<div align="center">
  <img src="/img/Diagrama.png" width="650px">
  <p><i>Topología de red</i></p>
</div>


---

## 2. Flujo de Funcionamiento
Para que la aplicación funcione correctamente, los servidores interactúan de la siguiente manera:

1.**Estética:** El navegador solicita el diseño al **S6 (Static Server)**.
2.**Carga:** El **S1** reparte las peticiones entre **S2/S3**, quienes consultan al **S7 (Database)** para mostrar los posts.
3.**Subida:** Cuando un usuario publica, el **S4** guarda la imagen físicamente.
4.**Visualización:** Las imágenes publicadas se muestran al usuario a través del **S5**.

---




