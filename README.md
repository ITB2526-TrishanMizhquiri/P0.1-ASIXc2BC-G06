#  EXTAGRAM: Sprint 1 & 2  
*De arquitectura monolítica a microservicios dockerizados*

---

##  Documentación Oficial

###  Guías Técnicas
- [01. Manual de Despliegue Nativo](/docs/Administrador/01-desplegament-natiu.md)
- [02. Arquitectura Docker](docs/Administrador/02-arquitectura-docker.md)
- [03. Guía de Mantenimiento del Sistema](docs/Administrador/03-guia-manteniment.md)

###  Actas de Sprint

- [Acta Sprint Planning S1](docs/sprints/sprint1/sprint1_planning_acta.md)
- [Acta Sprint Retrospective S1](docs/sprints/sprint1/sprint1_review_acta.md)


- [Acta Sprint Planning S2](docs/sprints/sprint2/sprint2_planning_acta.md)
- [Acta Sprint Retrospective S2](docs/sprints/sprint2/sprint2_review_acta.md)


- [Acta Sprint Planning S3](docs/sprints/sprint3/sprint3_planning_acta.md)
- [Acta Sprint Retrospective S3](docs/sprints/sprint3/sprint3_review_acta.md)
---

##  Código Fuente

###  Microservicios
| Servicio | Descripción | Archivos Clave |
|----------|-------------|----------------|
| **[S1 - Proxy/LB](s1-nginx/)** | Entrada única (puerto 90) + Balanceo | [`Dockerfile`](s1-nginx/Dockerfile) • [`nginx.conf`](s1-nginx/nginx.conf) |
| **[S2 - PHP Node](s2-php/)** | Procesamiento dinámico (login/feed) | [`extagram.php`](s2-php/extagram.php) • [`login.php`](s2-php/login.php) • [`logout.php`](s2-php/logout.php) |
| **[S3 - PHP Node](s3-php/)** | Réplica para balanceo (S2) | [`extagram.php`](s3-php/extagram.php) • [`login.php`](s3-php/login.php) |
| **[S4 - Upload](s4-upload/)** | Gestión de subidas de archivos | [`upload.php`](s4-upload/upload.php) • [`delete.php`](s4-upload/delete.php) |
| **[S5 - Storage](s5-storage/)** | Servicio de imágenes (`/uploads/`) | [`Dockerfile`](s5-storage/Dockerfile) • [`nginx.conf`](s5-storage/nginx.conf) |
| **[S6 - Static](s6-static/)** | Servicio de recursos estáticos | [`style.css`](s6-static/style.css) • [`preview.svg`](s6-static/preview.svg) |
| **[S7 - Database](s7-mysql/)** | MySQL persistente | [`init.sql`](s7-mysql/init.sql) |

###  Orquestación
- [`docker-compose.yml`](docker-compose.yml) - Definición completa de servicios y redes
- [`fix-s1-nginx.sh`](fix-s1-nginx.sh) - Script de corrección automática
- [`verificar-archivos.sh`](verificar-archivos.sh) - Script de verificación de estructura

---

##  Inicio Rápido
```bash
cd ~/extagram
./verificar-archivos.sh  # Configura y levanta todo automáticamente
```
 **Acceso web:** [`http://<IP-PÚBLICA>:90/`](http://3.238.204.15:90/)

---

##  Credenciales
| Servicio | Usuario | Contraseña |
|----------|---------|------------|
| **Web (login.php)** | `admin` | `password` |
| **Base de Datos** | `extagram_admin` | `pass123` |

---

##  Diagramas de Arquitectura
- [Diagrama de Redes Docker](img/diagrama-redes.png)
- [Flujo de Peticiones](img/flujo-peticiones.png)
- [Topología de Microservicios](img/topologia-microservicios.png)

---

>  *"La simplicidad es la máxima sofisticación"* — Leonardo da Vinci  
> Este proyecto demuestra la evolución de una aplicación monolítica a una arquitectura de microservicios escalable y resiliente.
