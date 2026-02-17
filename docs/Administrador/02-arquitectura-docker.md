# 02. Arquitectura del Sistema i Dockerització

## Índex
1. [Disseny de l'Arquitectura de Microserveis](#1-disseny-de-larquitectura-de-microserveis)
2. [Preparació de l'Entorn i Estructura de Directoris](#2-preparació-de-lentorn-i-estructura-de-directoris)
   - 2.1. [Estructura de Directoris](#21-estructura-de-directoris)
   - 2.2. [Comandos de Creació](#22-comandos-de-creació)
3. [Configuració dels Serveis Docker](#3-configuració-dels-serveis-docker)
   - 3.1. [S1 - NGINX Proxy Inverso + Balanceig](#31-s1---nginx-proxy-inverso--balanceig)
   - 3.2. [S2 i S3 - PHP-FPM (Balanceig)](#32-s2-i-s3---php-fpm-balanceig)
   - 3.3. [S4 - PHP-FPM (Pujada d'Imatges)](#33-s4---php-fpm-pujada-dimatges)
   - 3.4. [S5 - NGINX (Servir Imatges)](#34-s5---nginx-servir-imatges)
   - 3.5. [S6 - NGINX (Recursos Estàtics)](#35-s6---nginx-recursos-estàtics)
   - 3.6. [S7 - MySQL](#36-s7---mysql)
4. [Arxiu docker-compose.yml](#4-arxiu-docker-composeyml)
5. [Verificacions i Proves](#5-verificacions-i-proves)
   - 5.1. [Verificació de Serveis](#51-verificació-de-serveis)
   - 5.2. [Verificació de Balanceig S2/S3](#52-verificació-de-balanceig-s2s3)
   - 5.3. [Verificació de Persistència](#53-verificació-de-persistència)
6. [Arquitectura de Xarxes](#6-arquitectura-de-xarxes)
   - 6.1. [Segregació de Xarxes](#61-segregació-de-xarxes)
   - 6.2. [Flux de Peticions](#62-flux-de-peticions)
7. [Resultats i Logros](#7-resultats-i-logros)
   - 7.1. [Logros del Sprint 2](#71-logros-del-sprint-2)
   - 7.2. [Verificacions Completades](#72-verificacions-completades)
8. [Conclusions](#8-conclusions)
   - 8.1. [Avaluació Tècnica](#81-avaluació-tècnica)
   - 8.2. [Milllores Futures](#82-milllores-futures)
9. [Annexos](#9-annexos)
   - 9.1. [Scripts d'Automatització](#91-scripts-dautomatització)

## 1. Disseny de l'Arquitectura de Microserveis
L'aplicació s'ha dissenyat seguint un model de microserveis desacoblats. En aquesta fase (Sprint 2), hem evolucionat d'un stack simple a una infraestructura d'alta disponibilitat dividida en 7 serveis especialitzats (S1-S7) per garantir que cada component pugui escalar de forma independent.

![Arquitectura de contenidors distribuïda](/img/Diagrama.png)

## 2. Preparació de l'Entorn i Estructura de Directoris
El primer pas va ser la creació de la jerarquia de treball. Es van separar els rols en 7 carpetes específiques per gestionar el context de cada contenidor.

### 2.1. Estructura de Directoris

Estructura organitzada per als 7 serveis Docker del Sprint 2:

```
/home/ec2-user/extagram/
├── s1-nginx/      # S1: NGINX Proxy Inverso + Balanceo
├── s2-php/        # S2: PHP-FPM (extagram.php, login.php, logout.php)
├── s3-php/        # S3: PHP-FPM (réplica per balanceig)
├── s4-upload/     # S4: PHP-FPM (upload.php + gestió d'imatges)
├── s5-storage/    # S5: NGINX (servir imatges pujades)
├── s6-static/     # S6: NGINX (servir CSS/SVG)
├── s7-mysql/      # S7: MySQL (base de dades)
├── docker-compose.yml  # Orquestració de serveis
└── docs/          # Documentació
```

![Estructura de la carpeta extagram](/img/diagrama_extagram.png)

### 2.2. Comandos de Creació

```bash
# Crear estructura completa
mkdir -p ~/extagram/{s1-nginx,s2-php,s3-php,s4-upload,s5-storage,s6-static,s7-mysql,docs}

# Verificar estructura
ls -la ~/extagram/
```

![Carpetas creadas](/img/extagram_directori.png)

## 3. Configuració dels Serveis Docker

### 3.1. S1 - NGINX Proxy Inverso + Balanceig
Dins de `s1-nginx/nginx.conf`, es va definir la lògica de balanceig i segmentació de trànsit. Aquesta configuració permet que el servidor funcioni com a proxy invers, delegant cada petició al contenidor especialitzat corresponent.

**Arxiu clau:** `s1-nginx/nginx.conf`  
**Codi de configuració aplicat:**

[Enllaç al codi: nginx.conf](../extagram/s1-nginx-/nginx.conf)

### 3.1.2 Dockerització del Servei S1
Es va crear el **Dockerfile** específic per a **S1** amb l'objectiu d'automatitzar el desplegament de la configuració i garantir que el proxy invers estigui llest per operar immediatament en aixecar el contenidor.

S'ha utilitzat la imatge `nginx:alpine` per la seva lleugeresa i seguretat, sobreescrivint la configuració per defecte amb el nostre fitxer personalitzat.

**Contingut del Dockerfile (s1-nginx/Dockerfile):**

[Enllaç al codi: nginx.conf](../extagram/s1-nginx-/Dokerfile)

### 3.2. S2 i S3 - PHP-FPM (Balanceig)

**Responsabilitat:** Dues instàncies idèntiques de PHP-FPM per distribuir la càrrega i garantir alta disponibilitat.

**Arxiu clau:** `s2-php/Dockerfile`  
```dockerfile
FROM php:8.2-fpm
RUN docker-php-ext-install mysqli pdo pdo_mysql
WORKDIR /var/www/html
EXPOSE 9000
```

### 3.3. S4 - PHP-FPM (Pujada d'Imatges)

**Responsabilitat:** Servei PHP dedicat exclusivament al processament de pujades d'imatges amb permisos d'escriptura especials.

**Característica clau:** Volum compartit `uploads-volume` amb S5 per sincronització d'imatges.

### 3.4. S5 - NGINX (Servir Imatges)

**Responsabilitat:** Servir imatges pujades amb optimitzacions de caché (30 dies).

**Configuració clau:**  
```nginx
location /uploads/ {
    alias /usr/share/nginx/html/uploads/;
    expires 30d;
    add_header Cache-Control "public, immutable";
}
```

### 3.5. S6 - NGINX (Recursos Estàtics)

**Responsabilitat:** Servir CSS i SVG amb màxima eficiència.

**Arxius servits:**  
- `style.css` (disseny complet de l'aplicació)
- `preview.svg` (imatge de previsualització)

### 3.6. S7 - MySQL

**Responsabilitat:** Base de dades amb inicialització automàtica.

**Inicialització:**  
- Base de dades `extagram_db`
- Usuari `extagram_admin` amb contrasenya `pass123`
- Taules `posts` i `users`
- Usuari admin preconfigurat (`admin` / `password`)

---

## 4. Arxiu docker-compose.yml

**Orquestració completa dels 7 serveis** amb xarxes segregades:

```yaml
version: '3.8'
services:
  s1-lb:
    build: ./s1-nginx
    ports:
      - "90:90"
    networks:
      - frontend
      - backend  # ← CRÍTIC: Ha d'estar a AMB DUES xarxes
  
  s2-php:
    build: ./s2-php
    networks:
      - backend
  
  s3-php:
    build: ./s3-php
    networks:
      - backend
  
  s4-upload:
    build: ./s4-upload
    volumes:
      - ./s4-upload:/var/www/html
      - uploads-volume:/var/www/html/uploads
    networks:
      - backend
  
  s5-storage:
    build: ./s5-storage
    volumes:
      - uploads-volume:/usr/share/nginx/html/uploads:ro
    networks:
      - frontend
  
  s6-static:
    build: ./s6-static
    networks:
      - frontend
  
  s7-mysql:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: rootpass123
      MYSQL_DATABASE: extagram_db
      MYSQL_USER: extagram_admin
      MYSQL_PASSWORD: pass123
    volumes:
      - mysql-data:/var/lib/mysql
      - ./s7-mysql/init.sql:/docker-entrypoint-initdb.d/init.sql
    networks:
      - backend

volumes:
  uploads-volume:
  mysql-data:

networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
```

---

## 5. Verificacions i Proves

### 5.1. Verificació de Serveis

```bash
# Health check
curl http://localhost:90/health

# Accés a recursos
curl -I http://localhost:90/login.php
curl -I http://localhost:90/style.css
curl -I http://localhost:90/uploads/test.jpg
```

### 5.2. Verificació de Balanceig S2/S3

✅ **Mètode recomanat:** Scripts automatitzats per verificar distribució de càrrega  
🔗 [Script de verificació de balanceig](scripts/verificar-balanceo.sh)

### 5.3. Verificació de Persistència

```bash
# Verificar volum compartit
docker compose exec s4-upload ls -la /var/www/html/uploads/
docker compose exec s5-storage ls -la /usr/share/nginx/html/uploads/
```

---

## 6. Arquitectura de Xarxes

### 6.1. Segregació de Xarxes

| Xarxa       | Serveis                     | Propòsit                          |
|-------------|-----------------------------|-----------------------------------|
| `frontend`  | S1, S5, S6                  | Accés des d'Internet (port 90)    |
| `backend`   | S1, S2, S3, S4, S7          | Comunicació interna segura        |

> ⚠️ **CRÍTIC:** S1 **ha d'estar connectat a AMB DUES xarxes** per actuar com a pont entre el món exterior i els serveis interns.

### 6.2. Flux de Peticions

```
Navegador → http://IP:90/
    ↓
S1 (NGINX port 90) ← Proxy invers + balanceig
    ↓
    ├─ CSS/SVG ───────→ S6 (NGINX estàtic)
    ├─ /uploads/ ─────→ S5 (NGINX imatges)
    ├─ login.php ─────→ S2/S3 (balanceig PHP-FPM)
    ├─ upload.php ────→ S4 (PHP-FPM)
    └─ extagram.php ──→ S2/S3 (balanceig PHP-FPM)
          ↓
        S7 (MySQL) ← Base de dades
```

---

## 7. Resultats i Logros

### 7.1. Logros del Sprint 2

| Característica               | Implementació                              |
|------------------------------|--------------------------------------------|
| **Arquitectura Microserveis** | 7 serveis Docker independents              |
| **Alta Disponibilitat**      | Balanceig S2/S3 amb NGINX                  |
| **Persistència**             | Volums compartits + MySQL persistent       |
| **Seguretat**                | Xarxes segregades (frontend/backend)       |
| **Rendiment**                | Caché d'estàtics + optimització NGINX      |

### 7.2. Verificacions Completades

- [x] Tots els serveis en estat `Up`
- [x] Balanceig funcional S2/S3 (distribució 50/50)
- [x] Persistència d'imatges entre S4 i S5
- [x] Base de dades inicialitzada amb usuari admin
- [x] CSS servit correctament des de S6
- [x] Health checks operatius
- [x] Redireccions correctes (login → extagram)

---

## 8. Conclusions

### 8.1. Avaluació Tècnica

L'arquitectura implementada **compleix tots els objectius del Sprint 2**:
- ✅ Separació clara de responsabilitats per servei
- ✅ Alta disponibilitat mitjançant balanceig de càrrega
- ✅ Escalabilitat horitzontal (afegir més nodes PHP fàcilment)
- ✅ Seguretat millorada amb xarxes segregades
- ✅ Rendiment optimitzat amb caché d'estàtics

### 8.2. Milllores Futures

| Prioritat | Millora                     | Impacte |
|-----------|-----------------------------|---------|
| Alta      | Implementació HTTPS         | 🔒 Seguretat |
| Mitjana   | Configuració CORS           | 🌐 API externes |
| Baixa     | Logging centralitzat        | 📊 Monitoratge |

---

## 9. Annexos

### 9.1. Scripts d'Automatització

Tots els scripts es troben al directori `~/extagram/scripts/`:

- [`verificar-balanceo.sh`](scripts/verificar-balanceo.sh) - Verificació de distribució de càrrega S2/S3
- [`fallo_nodes.sh`](scripts/fallo_nodes.sh) - Prova de tolerància a fallades
- [`verificar-css.sh`](scripts/verificar-css.sh) - Verificació de recursos CSS/S6
- [`verificar-imagenes.sh`](scripts/verificar-imagenes.sh) - Verificació d'imatges/S5
- [`corregir-sistema.sh`](scripts/corregir-sistema.sh) - Correcció automàtica de problemes comuns

> 💡 **Nota:** Cada script inclou instruccions d'ús detallades al seu interior. Per executar qualsevol script:
> ```bash
> chmod +x ~/extagram/scripts/nom_script.sh
> ~/extagram/scripts/nom_script.sh
> ```
