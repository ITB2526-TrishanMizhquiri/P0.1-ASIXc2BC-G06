***Documentar topología: IPs, puertos, flujos de tráfico***


# Proyecto Extagram - Topología de Red (Sprint 2)

## 1. Diseño de la Infraestructura
[cite_start]Se ha diseñado una topología en Cisco Packet Tracer que segrega la aplicación en 7 servidores independientes (simulando contenedores Docker) para garantizar alta disponibilidad y escalabilidad[cite: 207, 254].

### Esquema de Servidores (S1 - S7)

| ID | Nombre en Red | Función Principal | Descripción Técnica |
| :--- | :--- | :--- | :--- |
| **S1** | **Load Balancer** | Proxy Inverso | [cite_start]Recibe todo el tráfico del navegador y lo reparte entre S2 y S3[cite: 228, 229]. |
| **S2** | **Extagram PHP (A)** | Web Dinámica | [cite_start]Procesa el código PHP de la página principal (Nodo redundante A)[cite: 230]. |
| **S3** | **Extagram PHP (B)** | Web Dinámica | [cite_start]Procesa el código PHP de la página principal (Nodo redundante B)[cite: 230]. |
| **S4** | **Upload PHP** | Gestor de Subidas | [cite_start]Ejecuta el script `upload.php` para procesar nuevas imágenes[cite: 231]. |
| **S5** | **Images Server** | Almacén de Fotos | [cite_start]Servidor Nginx que "enseña" las fotos guardadas en `/uploads`[cite: 233]. |
| **S6** | **Static Server** | Diseño y Estética | [cite_start]Sirve los archivos fijos: `style.css` y el logo `preview.svg`[cite: 235]. |
| **S7** | **Database** | Base de Datos | [cite_start]Servidor MySQL que almacena los textos y rutas de las imágenes[cite: 236]. |

---

## 2. Flujo de Funcionamiento
Para que la aplicación funcione correctamente, los servidores interactúan de la siguiente manera:

1.  [cite_start]**Estética:** El navegador solicita el diseño al **S6 (Static Server)**[cite: 235].
2.  [cite_start]**Carga:** El **S1** reparte las peticiones entre **S2/S3**, quienes consultan al **S7 (Database)** para mostrar los posts[cite: 229, 294].
3.  [cite_start]**Subida:** Cuando un usuario publica, el **S4** guarda la imagen físicamente[cite: 232].
4.  [cite_start]**Visualización:** Las imágenes publicadas se muestran al usuario a través del **S5**[cite: 233].

---

## 3. Captura de la Topología
![Topología de Red Extagram](./img/Diagrama.png)
*(Asegúrate de subir tu captura de Packet Tracer a la misma carpeta de GitHub y poner el nombre correcto del archivo aquí arriba)*
