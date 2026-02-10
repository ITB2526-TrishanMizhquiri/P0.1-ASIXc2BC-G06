# **03. Guia de Manteniment del Sistema**

Aquesta guia detalla les operacions habituals per garantir la continuïtat del servei d'Extagram i la integritat de les dades en l'entorn de microserveis Dockeritzat.

## **Índice**

1. [Gestió del Cicle de Vida dels Contenidors](#1-gestió-del-cicle-de-vida-dels-contenidors)
2. [Monitorització i Resolució d'Errors](#2-monitorització-i-resolució-derrors)
3. [Manteniment de la Base de Dades (S7)](#3-manteniment-de-la-base-de-dades-s7)
4. [Gestió d'Imatges i Volum de Pujades (S4-S5)](#4-gestió-dimatges-i-volum-de-pujades-s4-s5)
5. [Procediment d'Actualització (Update)](#5-procediment-dactualització-update)
6. [Resum de Ports i Accés](#6-resum-de-ports-i-accés)
7. [Comandos Útils Ràpids](#7-comandos-útils-ràpids)
8. [Troubleshooting Comú](#8-troubleshooting-comú)

## **1. Gestió del Cicle de Vida dels Contenidors**

Totes les operacions es realitzen des de l'arrel del projecte: `~/extagram/`

### **1.1. Aturada total del sistema**
```bash
cd ~/extagram
docker compose down
```

### **1.2. Inici del sistema en segon pla (recomanat)**
```bash
cd ~/extagram
docker compose up -d
```

### **1.3. Reinici d'un servei específic**
```bash
# Reiniciar S1 (NGINX Proxy)
docker compose restart s1-lb

# Reiniciar S2/S3 (PHP-FPM)
docker compose restart s2-php s3-php

# Reiniciar S4 (Upload)
docker compose restart s4-upload

# Reiniciar S5 (Storage)
docker compose restart s5-storage

# Reiniciar S6 (Static)
docker compose restart s6-static

# Reiniciar S7 (MySQL)
docker compose restart s7-mysql
```

### **1.4. Reinici ultra-ràpid (matar i iniciar)**
```bash
# Per a desenvolupament (més ràpid que restart)
docker kill s2-php s3-php s4-upload
docker start s2-php s3-php s4-upload
```

## **2. Monitorització i Resolució d'Errors**

### **2.1. Logs en temps real**
```bash
# Logs de tots els serveis simultàniament
docker compose logs -f

# Logs d'un servei específic
docker compose logs -f s1-lb      # NGINX Proxy
docker compose logs -f s2-php     # PHP-FPM S2
docker compose logs -f s7-mysql   # MySQL

# Últimes 50 línies d'un servei
docker compose logs --tail 50 s1-lb
```

### **2.2. Comprovació de l'estat dels serveis**
```bash
# Veure estat de tots els contenedores
docker compose ps

# Veure estat d'un servei específic
docker compose ps s1-lb

# Veure estadístiques de recursos (CPU/Memòria)
docker stats
```

### **2.3. Verificació de xarxes Docker**
```bash
# Veure xarxes del projecte
docker network ls | grep extagram

# Inspeccionar una xarxa específica
docker network inspect extagram_frontend
docker network inspect extagram_backend
```

### **2.4. Verificació de volums**
```bash
# Veure volums del projecte
docker volume ls | grep extagram

# Inspeccionar un volum específic
docker volume inspect extagram_uploads-volume
docker volume inspect extagram_mysql-data
```

## **3. Manteniment de la Base de Dades (S7)**

Les dades es guarden de forma persistent al volum `mysql-data`.

### **3.1. Exportar una còpia de seguretat (Backup)**
```bash
cd ~/extagram

# Backup complet de la base de dades
docker exec s7-mysql mysqldump -u extagram_admin -ppass123 extagram_db > backup_$(date +%Y%m%d_%H%M%S).sql

# Backup amb compressió
docker exec s7-mysql mysqldump -u extagram_admin -ppass123 extagram_db | gzip > backup_$(date +%Y%m%d_%H%M%S).sql.gz
```

### **3.2. Restaurar dades des d'un fitxer SQL**
```bash
cd ~/extagram

# Restaurar backup
docker exec -i s7-mysql mysql -u extagram_admin -ppass123 extagram_db < backup_20260209_173000.sql

# Restaurar backup comprimit
gunzip < backup_20260209_173000.sql.gz | docker exec -i s7-mysql mysql -u extagram_admin -ppass123 extagram_db
```

### **3.3. Accés directe a MySQL**
```bash
# Entrar a MySQL des del host
docker exec -it s7-mysql mysql -u extagram_admin -ppass123 extagram_db

# Executar consulta directament
docker exec s7-mysql mysql -u extagram_admin -ppass123 extagram_db -e "SELECT COUNT(*) FROM posts;"

# Veure taules
docker exec s7-mysql mysql -u extagram_admin -ppass123 extagram_db -e "SHOW TABLES;"

# Veure estructura d'una taula
docker exec s7-mysql mysql -u extagram_admin -ppass123 extagram_db -e "DESCRIBE posts;"
```

### **3.4. Optimització de la base de dades**
```bash
# Optimitzar totes les taules
docker exec s7-mysql mysqlcheck -u extagram_admin -ppass123 --optimize extagram_db

# Reparar taules
docker exec s7-mysql mysqlcheck -u extagram_admin -ppass123 --repair extagram_db
```

## **4. Gestió d'Imatges i Volum de Pujades (S4-S5)**

### **4.1. Verificar el volum compartit**
```bash
# Veure contingut del volum d'uploads
docker compose exec s4-upload ls -lh /var/www/html/uploads/

# Veure contingut des de S5
docker compose exec s5-storage ls -lh /usr/share/nginx/html/uploads/

# Comptar imatges pujades
docker compose exec s4-upload find /var/www/html/uploads/ -type f | wc -l
```

### **4.2. Netegem imatges antigues**
```bash
# Eliminar imatges més antigues de 30 dies
docker compose exec s4-upload find /var/www/html/uploads/ -type f -mtime +30 -delete

# Verificar espai lliure
docker compose exec s4-upload df -h /var/www/html/uploads/
```

### **4.3. Netegem d'imatges temporals de Docker**
```bash
# Eliminar contenidors aturats
docker container prune -f

# Eliminar imatges no utilitzades
docker image prune -f

# Eliminar tot (contenidors, imatges, volums, xarxes)
docker system prune -a -f --volumes
```

### **4.4. Backup de les imatges pujades**
```bash
cd ~/extagram

# Crear backup del volum d'uploads
docker run --rm -v extagram_uploads-volume:/source -v $(pwd):/backup alpine \
    tar czf /backup/uploads_backup_$(date +%Y%m%d_%H%M%S).tar.gz -C /source .

# Restaurar backup d'uploads
docker run --rm -v extagram_uploads-volume:/dest -v $(pwd):/backup alpine \
    tar xzf /backup/uploads_backup_20260209_173000.tar.gz -C /dest --strip 1
```

## **5. Procediment d'Actualització (Update)**

Quan es modifiqui el codi PHP a les carpetes `s2`, `s3` o `s4`, o es canviï la configuració de NGINX, cal reconstruir les imatges per aplicar els canvis.

### **5.1. Actualització ràpida (sense rebuild)**
```bash
cd ~/extagram

# Per canvis en arxius PHP (no cal rebuild)
docker compose restart s2-php s3-php s4-upload

# Per canvis en nginx.conf
docker compose restart s1-lb s5-storage s6-static
```

### **5.2. Rebuild complet**
```bash
cd ~/extagram

# 1. Aturar contenidors
docker compose down

# 2. Eliminar imatges antigues
docker compose down --rmi all

# 3. Reconstruir imatges sense fer servir la memòria cau
docker compose build --no-cache

# 4. Tornar a aixecar el servei
docker compose up -d

# 5. Esperar que MySQL s'iniciï (30 segons)
sleep 30

# 6. Verificar estat
docker compose ps
```

### **5.3. Actualització d'un servei específic**
```bash
cd ~/extagram

# Rebuild només S1 (NGINX)
docker compose up -d --build s1-lb

# Rebuild només S2 i S3 (PHP-FPM)
docker compose up -d --build s2-php s3-php

# Rebuild només S4 (Upload)
docker compose up -d --build s4-upload
```

## **6. Resum de Ports i Accés**

| Servei | Contenidor | Port Intern | Port Host | Descripció |
|--------|------------|-------------|-----------|------------|
| **S1-LB** | s1-lb | 90 | 90 | Punt d'entrada (Proxy Inverso + Balanceo) |
| **S2-PHP** | s2-php | 9000 | - | PHP-FPM (Backend S2) |
| **S3-PHP** | s3-php | 9000 | - | PHP-FPM (Backend S3 - Réplica) |
| **S4-Upload** | s4-upload | 9000 | - | PHP-FPM (Upload.php) |
| **S5-Storage** | s5-storage | 80 | - | NGINX (Servei d'imatges /uploads/) |
| **S6-Static** | s6-static | 80 | - | NGINX (Servei de CSS/SVG) |
| **S7-DB** | s7-mysql | 3306 | - | MySQL (Base de dades) |

### **Accés des de navegador**
```
http://<IP-PÚBLICA>:90/           → Pàgina principal (extagram.php)
http://<IP-PÚBLICA>:90/login.php   → Login
http://<IP-PÚBLICA>:90/upload.php  → Upload
http://<IP-PÚBLICA>:90/health      → Health check
```

### **Accés des del host (EC2)**
```bash
curl http://localhost:90/health      # Health check local
curl http://localhost:90/login.php   # Prova login
curl http://localhost:90/style.css   # Prova CSS
```

## **7. Comandos Útils Ràpids**

### **7.1. Verificació ràpida del sistema**
```bash
cd ~/extagram

# Verificar tots els serveis
echo "=== Estat dels serveis ==="
docker compose ps

echo ""
echo "=== Health check ==="
curl -s http://localhost:90/health && echo " ✅ OK" || echo " ❌ FAIL"

echo ""
echo "=== Login.php ==="
curl -s -o /dev/null -w "HTTP %{http_code}\n" http://localhost:90/login.php

echo ""
echo "=== CSS ==="
curl -s -o /dev/null -w "HTTP %{http_code}\n" http://localhost:90/style.css
```

### **7.2. Verificació de balanceig S2/S3**
```bash
# Provar balanceig (hauria d'alternar entre S2 i S3)
for i in {1..5}; do
    echo "Petició $i:"
    curl -s http://localhost:90/login.php | grep -o "S2\|S3" || echo "OK"
    sleep 0.5
done
```

### **7.3. Verificació de sessió PHP**
```bash
# Provar que les sessions funcionen
curl -c cookies.txt http://localhost:90/login.php > /dev/null
curl -b cookies.txt -I http://localhost:90/extagram.php | head -1
```

### **7.4. Verificació de connexió a MySQL**
```bash
# Provar connexió des de S2
docker compose exec s2-php php -r '
    $db = new mysqli("s7-mysql", "extagram_admin", "pass123", "extagram_db");
    echo $db->connect_error ?: "✅ Conexió exitosa";
'
```

### **7.5. Verificació de permisos de sessió**
```bash
# Verificar directori de sessions
docker compose exec s2-php ls -ld /var/lib/php/sessions
docker compose exec s3-php ls -ld /var/lib/php/sessions
```

## **8. Troubleshooting Comú**

### **8.1. Error 404 - Pàgina no trobada**
**Síntomes:** Accedir a `/` o `/login.php` retorna 404 Not Found

**Solució:**
```bash
# 1. Verificar que S1 està en ambdues xarxes
docker network inspect extagram_frontend | grep s1-lb
docker network inspect extagram_backend | grep s1-lb

# 2. Verificar nginx.conf
cat ~/extagram/s1-nginx/nginx.conf

# 3. Reiniciar S1
docker compose restart s1-lb
```

### **8.2. Error 502 Bad Gateway**
**Síntomes:** NGINX retorna 502 al intentar accedir a pàgines PHP

**Solució:**
```bash
# 1. Verificar que S2/S3 estan actius
docker compose ps | grep -E "s2-php|s3-php"

# 2. Verificar logs de S1
docker compose logs s1-lb | tail -30

# 3. Verificar connexió a S2/S3
docker compose exec s1-lb wget -qO- http://s2-php:9000 2>&1 | head -3

# 4. Reiniciar S2/S3
docker compose restart s2-php s3-php
```

### **8.3. Loop de redirecció infinita**
**Síntomes:** Navegador mostra "The page isn't redirecting properly"

**Causa:** Les sessions PHP no es guarden correctament

**Solució:**
```bash
# 1. Verificar directori de sessions
docker compose exec s2-php ls -ld /var/lib/php/sessions

# 2. Crear i donar permisos si no existeix
docker compose exec s2-php mkdir -p /var/lib/php/sessions
docker compose exec s2-php chown www-data:www-data /var/lib/php/sessions
docker compose exec s2-php chmod 777 /var/lib/php/sessions

# 3. Repetir per S3
docker compose exec s3-php mkdir -p /var/lib/php/sessions
docker compose exec s3-php chown www-data:www-data /var/lib/php/sessions
docker compose exec s3-php chmod 777 /var/lib/php/sessions

# 4. Reiniciar S2/S3
docker compose restart s2-php s3-php
```

### **8.4. Error al pujar imatges**
**Síntomes:** `move_uploaded_file(): Unable to move...`

**Solució:**
```bash
# 1. Verificar ruta en upload.php
grep "upload_dir" ~/extagram/s4-upload/upload.php
# Ha de ser: $upload_dir = '/var/www/html/uploads/';

# 2. Verificar carpeta uploads existeix
docker compose exec s4-upload ls -ld /var/www/html/uploads

# 3. Crear si no existeix
docker compose exec s4-upload mkdir -p /var/www/html/uploads
docker compose exec s4-upload chmod 777 /var/www/html/uploads

# 4. Reiniciar S4
docker compose restart s4-upload
```

### **8.5. Error de connexió a MySQL**
**Síntomes:** `mysqli_connect(): (HY000/2002): Connection refused`

**Solució:**
```bash
# 1. Verificar que S7 està actiu
docker compose ps s7-mysql

# 2. Verificar connexió des de S2
docker compose exec s2-php php -r '
    $db = new mysqli("s7-mysql", "extagram_admin", "pass123", "extagram_db");
    echo $db->connect_error ?: "✅ OK";
'

# 3. Verificar que S2 està a la xarxa backend
docker network inspect extagram_backend | grep s2-php

# 4. Reiniciar S7 i S2/S3
docker compose restart s7-mysql s2-php s3-php
```

### **8.6. CSS no carrega**
**Síntomes:** Pàgina sense estils, fons blanc

**Solució:**
```bash
# 1. Verificar que S6 està actiu
docker compose ps s6-static

# 2. Verificar accés al CSS
curl -I http://localhost:90/style.css

# 3. Verificar que style.css existeix en S6
docker compose exec s6-static ls -la /usr/share/nginx/html/style.css

# 4. Verificar nginx.conf de S1
grep "s6-static" ~/extagram/s1-nginx/nginx.conf

# 5. Reiniciar S6
docker compose restart s6-static
```

### **8.7. Imatges no es mostren**
**Síntomes:** Imatges pujades no es visualitzen a extagram.php

**Solució:**
```bash
# 1. Verificar que S5 està actiu
docker compose ps s5-storage

# 2. Verificar que el volum està muntat
docker compose exec s5-storage ls -la /usr/share/nginx/html/uploads/

# 3. Verificar URL de la imatge
curl -I http://localhost:90/uploads/extagram_xxx.jpg

# 4. Reiniciar S5
docker compose restart s5-storage
```

### **8.8. Contenidor es reinicia constantment**
**Síntomes:** `docker compose ps` mostra "Restarting" repetidament

**Solució:**
```bash
# 1. Veure logs per diagnosticar
docker compose logs s1-lb | tail -50

# 2. Causa comú: Error en nginx.conf
# Verificar sintaxi
docker compose exec s1-lb nginx -t

# 3. Corregir nginx.conf i reiniciar
nano ~/extagram/s1-nginx/nginx.conf
docker compose restart s1-lb
```

## **9. Scripts Automatitzats**

### **9.1. Script de verificació completa**
Guarda com `check-system.sh`:
```bash
#!/bin/bash
cd ~/extagram

echo "========================================"
echo "🔍 VERIFICACIÓ COMPLETA DEL SISTEMA"
echo "========================================"
echo ""

# 1. Estat dels serveis
echo "✅ Estat dels serveis:"
docker compose ps
echo ""

# 2. Health check
echo "✅ Health check:"
curl -s http://localhost:90/health && echo "OK" || echo "FAIL"
echo ""

# 3. Login.php
echo "✅ Login.php:"
curl -s -o /dev/null -w "HTTP %{http_code}\n" http://localhost:90/login.php
echo ""

# 4. CSS
echo "✅ CSS:"
curl -s -o /dev/null -w "HTTP %{http_code}\n" http://localhost:90/style.css
echo ""

# 5. Sessions
echo "✅ Sessions PHP:"
docker compose exec s2-php ls -ld /var/lib/php/sessions
echo ""

# 6. MySQL
echo "✅ MySQL:"
docker compose exec s2-php php -r '
    $db = new mysqli("s7-mysql", "extagram_admin", "pass123", "extagram_db");
    echo $db->connect_error ?: "OK";
'
echo ""

# 7. Uploads
echo "✅ Uploads:"
docker compose exec s4-upload ls -ld /var/www/html/uploads
echo ""

echo "========================================"
echo "✅ VERIFICACIÓ COMPLETA"
echo "========================================"
```

**Ús:**
```bash
chmod +x check-system.sh
./check-system.sh
```


### **9.2. Script de backup complet**
Guarda com `backup-all.sh`:
```bash
#!/bin/bash
cd ~/extagram

BACKUP_DIR="backups"
mkdir -p $BACKUP_DIR

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/full_backup_$TIMESTAMP.tar.gz"

echo "🔄 Iniciant backup complet..."

# 1. Backup de la base de dades
echo "💾 Backup de MySQL..."
docker exec s7-mysql mysqldump -u extagram_admin -ppass123 extagram_db > $BACKUP_DIR/db_$TIMESTAMP.sql

# 2. Backup del volum d'uploads
echo "💾 Backup d'uploads..."
docker run --rm -v extagram_uploads-volume:/source -v $(pwd)/$BACKUP_DIR:/backup alpine \
    tar czf /backup/uploads_$TIMESTAMP.tar.gz -C /source .

# 3. Backup del codi font
echo "💾 Backup del codi font..."
tar czf $BACKUP_DIR/code_$TIMESTAMP.tar.gz \
    s1-nginx/ s2-php/ s3-php/ s4-upload/ s5-storage/ s6-static/ s7-mysql/

# 4. Crear backup complet
echo "💾 Creant backup complet..."
tar czf $BACKUP_FILE \
    $BACKUP_DIR/db_$TIMESTAMP.sql \
    $BACKUP_DIR/uploads_$TIMESTAMP.tar.gz \
    $BACKUP_DIR/code_$TIMESTAMP.tar.gz

# 5. Netegem temporals
rm $BACKUP_DIR/db_$TIMESTAMP.sql
rm $BACKUP_DIR/uploads_$TIMESTAMP.tar.gz
rm $BACKUP_DIR/code_$TIMESTAMP.tar.gz

echo "✅ Backup complet creat: $BACKUP_FILE"
echo "📊 Mida: $(du -h $BACKUP_FILE | cut -f1)"
```

**Ús:**
```bash
chmod +x backup-all.sh
./backup-all.sh
```

## **10. Millors Pràctiques**

### **10.1. Per a desenvolupament**
- ✅ Utilitza `docker compose restart` en lloc de `build` per canvis en PHP
- ✅ Manté els logs activats per debug (`docker compose logs -f`)
- ✅ Utilitza `docker kill + docker start` per reinicis ràpids

### **10.2. Per a producció**
- ✅ Desactiva `display_errors` en PHP
- ✅ Configura backups automàtics diaris
- ✅ Monitoritza l'ús de disc i CPU
- ✅ Utilitza HTTPS en lloc de HTTP
- ✅ Canvia les contrasenyes per defecte

### **10.3. Seguretat**
- ✅ Canvia la contrasenya de MySQL (`pass123` → contrasenya forta)
- ✅ Restringeix l'accés al port 90 només a IPs autoritzades
- ✅ Manté Docker i les imatges actualitzades
- ✅ Revisa periòdicament els logs per detectar activitat sospitosa


## 📝 **Resum Executiu**

Aquesta guia proporciona tota la informació necessària per mantenir i operar l'aplicació Extagram en un entorn Dockeritzat amb microserveis. Inclou:

- ✅ Gestió completa del cicle de vida dels contenidors
- ✅ Monitorització i resolució d'errors
- ✅ Procediments de backup i restauració
- ✅ Troubleshooting per als errors més comuns
- ✅ Scripts automatitzats per tasques freqüents
- ✅ Millors pràctiques per desenvolupament i producció

**Per a més informació detallada sobre el desplegament inicial, veure la secció "01. Manual de Desplegament Natiu (Sprint 1)".**