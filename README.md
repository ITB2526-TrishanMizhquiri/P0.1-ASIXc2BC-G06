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


- [Acta Sprint Planning S4](docs/sprints/sprint4/sprint4_planning_acta.md)
- [Acta Sprint Retrospective S5](docs/sprints/sprint4/sprint4_review_acta.md)


- [Acta Sprint Planning S5](docs/sprints/sprint5/sprint5_planning_acta.md)
- [Acta Sprint Retrospective S5](docs/sprints/sprint5/sprint5_review_acta.md)
---

##  Código Fuente

###  Microservicios
| Servicio | Descripción | Archivos Clave |
|----------|-------------|----------------|
| **[S1 - Proxy/LB](/docs/extagram/s1-nginx/)** | Entrada única (puerto 90) + Balanceo | [`Dockerfile`](/docs/extagram/s1-nginx/Dockerfile) • [`nginx.conf`](/docs/extagram/s1-nginx/nginx.conf) |
| **[S2 - PHP Node](/docs/extagram/s2-php/)** | Procesamiento dinámico (login/feed) | [`extagram.php`](/docs/extagram/s2-php/extagram.php) • [`login.php`](/docs/extagram/s2-php/login.php) • [`logout.php`](/docs/extagram/s2-php/logout.php) |
| **[S3 - PHP Node](/docs/extagram/s3-php/)** | Réplica para balanceo (S2) | [`extagram.php`](/docs/extagram/s3-php/extagram.php) • [`login.php`](/docs/extagram/s3-php/login.php) |
| **[S4 - Upload](/docs/extagram/s4-upload/)** | Gestión de subidas de archivos | [`upload.php`](/docs/extagram/s4-upload/upload.php) • [`delete.php`](/docs/extagram/s4-upload/delete.php) |
| **[S5 - Storage](/docs/extagram/s5-storage/)** | Servicio de imágenes (`/uploads/`) | [`Dockerfile`](/docs/extagram/s5-storage/Dockerfile) • [`nginx.conf`](/docs/extagram/s5-storage/nginx.conf) |
| **[S6 - Static](/docs/extagram/s6-static/)** | Servicio de recursos estáticos | [`style.css`](/docs/extagram/s6-static/style.css) • [`preview.svg`](/docs/extagram/s6-static/preview.svg) |
| **[S7 - Database](/docs/extagram/s7-mysql/)** | MySQL persistente | [`init.sql`](/docs/extagram/s7-mysql/init.sql) |

###  Orquestación
- [`docker-compose.yml`](/docker/docker-compose.yml) - Definición completa de servicios y redes

### Scripts

- [`Carpeta de scripts`](/docs/extagram/scripts/)
---

##  Inicio Rápido
```bash
cd ~/extagram
./verificar-archivos.sh  # Configura y levanta todo automáticamente
```
 **Acceso web:** [`http://<IP-PÚBLICA>:90/`](http://98.92.25.14:90/)

---

##  Credenciales
| Servicio | Usuario | Contraseña |
|----------|---------|------------|
| **Web (login.php)** | `admin` | `password` |
| **Base de Datos** | `extagram_admin` | `pass123` |

---

##  Diagramas de Arquitectura
- [Diagrama de Redes Docker](img/Diagrama.png)
- [Flujo de Peticiones](img/flux_peticions.png)
- [Topología de Microservicios](docs/Topologia_red.md)

---

>  *"La simplicidad es la máxima sofisticación"* — Leonardo da Vinci  
> Este proyecto demuestra la evolución de una aplicación monolítica a una arquitectura de microservicios escalable y resiliente.
