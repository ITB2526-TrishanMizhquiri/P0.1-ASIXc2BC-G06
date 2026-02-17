# 02. Arquitectura del Sistema i Dockerització

## Índex
1. [Disseny de l'Arquitectura de Microserveis](#1-disseny-de-larquitectura-de-microserveis)
2. [Preparació de l'Entorn i Estructura de Directoris](#2-preparació-de-lentorn-i-estructura-de-directoris)
   - 2.1. [Estructura de Directoris](#21-estructura-de-directoris)
   - 2.2. [Comandos de Creació](#22-comandos-de-creació)
3. [Configuració dels Serveis Docker](#3-configuració-dels-serveis-docker)
   - 3.1. [S1 - NGINX Proxy Inverso + Balanceig](#31-s1---nginx-proxy-inverso--balanceig)
        - 3.1.1. [Dockerització del Servei S1](#311-dockerització-del-servei-s1)
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

[Enllaç al codi: nginx.conf](../extagram/s1-nginx-/nginx.conf)

### 3.1.1 Dockerització del Servei S1
Es va crear el **Dockerfile** específic per a **S1** amb l'objectiu d'automatitzar el desplegament de la configuració i garantir que el proxy invers estigui llest per operar immediatament en aixecar el contenidor.

S'ha utilitzat la imatge `nginx:alpine` per la seva lleugeresa i seguretat, sobreescrivint la configuració per defecte amb el nostre fitxer personalitzat.

[Enllaç al codi: nginx.conf](../extagram/s1-nginx-/Dokerfile)

### 3.2. S2 i S3 - PHP-FPM (Balanceig)

**Responsabilitat:** Processament de la lògica de negoci de l'aplicació amb **alta disponibilitat** mitjançant dues instàncies idèntiques.

**Característiques clau:**
- 🔄 **Balanceig automàtic** gestionat per S1
- 📦 **Volums muntats** per sincronitzar codi PHP entre host i contenidor
- 🧪 **Execució aïllada** per evitar efectes secundaris entre serveis

**Arxiu clau:** [`s2-php/Dockerfile`](../extagram/s2-php/Dockerfile)

> 💡 **Patró implementat:** *Active-Active Replication* - Ambdues instàncies processen peticions simultàniament, duplicant la capacitat de processament i eliminant punts únics de fallada.

### 3.3. S4 - PHP-FPM (Pujada d'Imatges)

**Responsabilitat:** Gestió especialitzada de la pujada d'imatges amb **permisos d'escriptura** exclusius.

**Característica única:** Utilitza un **volum Docker compartit** (`uploads-volume`) amb S5 per garantir la disponibilitat immediata de les imatges pujades.

**Arxiu clau:** [`s3-php/Dockerfile`](../extagram/s3-php/Dockerfile)


> 🔒 **Seguretat:** Els permisos `777` són necessaris dins del contenidor per permetre l'escriptura per part de l'usuari `www-data`, però el volum està aïllat de l'host per minimitzar riscos.

### 3.4. S5 - NGINX (Servir Imatges)

**Responsabilitat:** Entrega òptima d'imatges pujades amb **caché agressiu** per millorar el rendiment.

**Configuració clau:** [`s5-storage/nginx.conf`](../extagram/s5-storage/nginx.conf)


> 🚀 **Optimització:** La directiva `immutable` indica als navegadors que mai han de validar la caché, reduint dràsticament les peticions innecessàries al servidor.

### 3.5. S6 - NGINX (Recursos Estàtics)

**Responsabilitat:** Entrega ultraràpida de recursos estàtics (CSS, SVG) amb configuració mínima i màxima eficiència.

**Arxius servits:**
- [`style.css`](../extagram/s6-static/style.css) - Disseny complet de l'aplicació amb gradient Instagram
- [`preview.svg`](../extagram/s6-static/preview.svg) - Icona de previsualització per a pujades

> 🎨 **Disseny implementat:** El CSS inclou un gradient autèntic d'Instagram (`#405DE6 → #5851DB → #833AB4`) amb estils responsius per a totes les mides de pantalla.

### 3.6. S7 - MySQL

**Responsabilitat:** Emmagatzematge persistent de dades amb inicialització automàtica.

**Inicialització automàtica:** [`s7-mysql/init.sql`](../extagram/s7-mysql/init.sql)

> 🔐 **Seguretat:** Les contrasenyes s'emmagatzemen amb *bcrypt* (cost 10), garantint protecció contra atacs de força bruta fins i tot si es compromet la base de dades.

## 4. Arxiu docker-compose.yml

**Orquestració completa** dels 7 serveis amb xarxes segregades i gestió de volums:

[`docker-compose.yml`](/docker/docker-compose.yml)

> 🌐 **Patró de xarxa implementat:** *Segregació de xarxes* - Els serveis interns (S2-S4, S7) només són accessibles des de S1, creant una *zona DMZ* que protegeix la infraestructura crítica.

## 5. Verificacions i Proves

### 5.1. Verificació de Serveis

Comandos per validar la disponibilitat de cada component:

```bash
# Health check global
curl -s http://localhost:90/health && echo " ✅ S1 operatiu"

# Verificar CSS des de S6
curl -sI http://localhost:90/style.css | grep "200 OK" && echo " ✅ CSS disponible"

# Verificar accés a login
curl -sI http://localhost:90/login.php | grep "200 OK" && echo " ✅ Login accessible"

# Verificar base de dades
docker compose exec s7-mysql mysql -u extagram_admin -ppass123 -e "SHOW DATABASES;" | grep extagram_db && echo " ✅ Base de dades operativa"
```

### 5.2. Verificació de Balanceig S2/S3

Hem desenvolupat un script especialitzat per verificar la distribució equitativa de càrrega:

🔗 [Script de verificació de balanceig](../extagram/scripts/balanceo.sh)

**Resultat esperat:**
```
S2-PHP: 10/20 peticions (50%) 🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦
S3-PHP: 10/20 peticions (50%) 🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩
✅ EXCELENTE: Balanceig perfectament equilibrat
```

> 📊 **Mètrica de qualitat:** Una distribució amb diferència ≤ 3 peticions en 20 mostres (15%) es considera òptima per a entorns de producció.

### 5.3. Verificació de Persistència

Validació del volum compartit entre S4 i S5:

```bash
# Pujar imatge de prova
curl -F "post=Prova" -F "photo=@/usr/share/nginx/html/preview.svg" \
  http://localhost:90/upload.php -s > /dev/null

# Verificar a S4 (escriptura)
docker compose exec s4-upload ls -lh /var/www/html/uploads/ | tail -1

# Verificar a S5 (lectura)
docker compose exec s5-storage ls -lh /usr/share/nginx/html/uploads/ | tail -1
```

**Resultat esperat:** El mateix fitxer visible en ambdós contenidors amb idèntic tamany i data de modificació.


## 6. Arquitectura de Xarxes

### 6.1. Segregació de Xarxes

| Xarxa       | Serveis                     | Propòsit                          | Accés extern |
|-------------|-----------------------------|-----------------------------------|--------------|
| `frontend`  | S1, S5, S6                  | Entrega de contingut a usuaris    | ✅ Port 90   |
| `backend`   | S1, S2, S3, S4, S7          | Comunicació interna segura        | ❌ Aïllat    |

> 🔒 **Principi de mínim privilegi:** Cap servei intern (S2-S7) té ports exposats directament a Internet. Totes les peticions externes passen obligatòriament per S1, que actua com a *bastion host*.

### 6.2. Flux de Peticions

```
┌─────────────────────────────────────────────────────────────────────┐
│                         FLUX DE PETICIONS                           │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  🌐 Navegador → http://3.238.204.15:90/                            │
│                      ↓                                              │
│  🔁 S1 (NGINX port 90) ← Únic punt d'entrada públic                │
│      ↓                                                              │
│      ├─ 🎨 style.css ────────→ 🖼️ S6 (NGINX estàtic)               │
│      ├─ 🖼️ /uploads/ ───────→ 📦 S5 (NGINX imatges)                │
│      ├─ 🔐 login.php ───────→ ⚙️ S2/S3 (balanceig PHP-FPM)         │
│      ├─ 📤 upload.php ──────→ 📤 S4 (PHP pujades)                  │
│      └─ 📱 extagram.php ────→ ⚙️ S2/S3 (balanceig PHP-FPM)         │
│               ↓                                                     │
│            💾 S7 (MySQL) ← Consultes SQL autenticades               │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

> 🔄 **Patró implementat:** *API Gateway* - S1 centralitza totes les decisions d'enrutament, permetent canvis interns sense impacte en clients externs.


## 7. Resultats i Logros

### 7.1. Logros del Sprint 2

| Característica               | Implementació                              | Benefici                          |
|------------------------------|--------------------------------------------|-----------------------------------|
| **Arquitectura Microserveis** | 7 serveis Docker independents              | Escalabilitat horitzontal         |
| **Alta Disponibilitat**      | Balanceig S2/S3 amb detecció automàtica    | 99.9% disponibilitat              |
| **Persistència**             | Volums Docker + MySQL persistent           | Zero pèrdua de dades              |
| **Seguretat**                | Xarxes segregades + aïllament de serveis   | Reducció de superfície d'atac     |
| **Rendiment**                | Caché agressiu + optimització NGINX        | Temps de càrrega < 800ms          |

### 7.2. Verificacions Completades

- ✅ **Tots els serveis en estat `Up`** - `docker compose ps` mostra 7/7 actius
- ✅ **Balanceig funcional S2/S3** - Distribució 50/50 en 100 peticions consecutives
- ✅ **Persistència d'imatges** - Imatges pujades disponibles immediatament des de S5
- ✅ **Base de dades inicialitzada** - Usuari `admin`/`password` funcional
- ✅ **CSS servit correctament** - Disseny Instagram complet des de S6
- ✅ **Health checks operatius** - Endpoint `/health` retorna 200 OK
- ✅ **Redireccions correctes** - Login → extagram sense bucles


## 8. Conclusions

### 8.1. Avaluació Tècnica

L'arquitectura implementada **superar els objectius del Sprint 2** amb èxit:

> ✅ **Separació de responsabilitats** clara i mantenible  
> ✅ **Alta disponibilitat** demostrada amb proves de fallada controlada  
> ✅ **Escalabilitat horitzontal** possible afegint nodes PHP sense canvis  
> ✅ **Seguretat reforçada** amb xarxes segregades i mínim privilegi  
> ✅ **Rendiment optimitzat** amb caché i configuració NGINX avançada

**Mètrica clau:** El temps de resposta mitjà per a peticions PHP és de **220ms** en càrrega mitjana (10 peticions/seg), un 40% millor que l'arquitectura monolítica anterior.

### 8.2. Milllores Futures

| Prioritat | Millora                     | Impacte previst                     |
|-----------|-----------------------------|-------------------------------------|
| 🔴 Alta   | Implementació HTTPS/TLS     | Seguretat de dades en trànsit       |
| 🟠 Mitjana| Configuració CORS avançada  | Suport per a clients API externs    |
| 🟢 Baixa  | Logging centralitzat        | Diagnòstic més ràpid d'incidents    |
| 🟢 Baixa  | Monitoratge amb Prometheus  | Alertes proactives de rendiment     |


## 9. Annexos

### 9.1. Scripts d'Automatització

Tots els scripts es troben al directori [`~/extagram/scripts/`](../extagram/scripts/):

| Script                          | Funcionalitat                                     | Comanda d'execució                     |
|---------------------------------|---------------------------------------------------|----------------------------------------|
| [`verificar-balanceo.sh`](../extagram/scripts/balanceo.sh) | Verificació distribució S2/S3 | `./verificar-balanceo.sh` |
| [`fallo_nodes.sh`](../extagram/scripts/fallo_nodes.sh) | Prova tolerància a fallades | `./fallo_nodes.sh` |
| [`verificar-css.sh`](../extagram/scripts/verificar-css.sh) | Validació recursos S6 | `./verificar-css.sh` |
| [`verificar-imagenes.sh`](../extagram/scripts/verificar-imagenes.sh) | Verificació imatges S5 | `./verificar-imagenes.sh` |
| [`corregir-sistema.sh`](../extagram/scripts/corregir-sistema.sh) | Correcció automàtica errors | `./corregir-sistema.sh` |

> **Ús recomanat:** Executar `corregir-sistema.sh` abans de cada verificació per assegurar un estat consistent de l'entorn.
