# 02. Arquitectura del Sistema i Dockerització

## 2.1. Disseny de l'Arquitectura de Microserveis
L'aplicació s'ha dissenyat seguint un model de microserveis desacoblats. En aquesta fase (Sprint 2), hem evolucionat d'un stack simple a una infraestructura d'alta disponibilitat dividida en 7 serveis especialitzats (S1-S7) per garantir que cada component pugui escalar de forma independent.

![Arquitectura de contenidors distribuïda](/img/arch_diagram_92j.png)

## 2.2. Preparació de l'Entorn i Estructura de Directoris
El primer pas va ser la creació de la jerarquia de treball. Es van separar els rols en 7 carpetes específiques per gestionar el context de cada contenidor.

![Estructura de la carpeta extagram](/img/diagrama_extagram.png)

Estructura creada:
* **s1-nginx:** Proxy invers i balancejador.
* **s2-php / s3-php:** Backend redundat per a l'aplicació.
* **s4-upload:** Servei dedicat al processament de pujades.
* **s5-storage:** Servidor optimitzat per a fitxers multimèdia.
* **s6-static:** Servei de recursos CSS i SVG.
* **s7-mysql:** Base de dades relacional.

## 2.3. Configuració del Proxy Invers i Balanceig (S1)
El servei S1-nginx actua com el "cervell" de la xarxa. La seva funció principal no és servir fitxers directament, sinó actuar com a punt d'entrada únic que redirigeix les peticions segons la ruta, optimitzant la càrrega del sistema.

### 2.3.1. Preparació de l'Entorn S1
Primer, es va establir l'estructura de directoris necessària per al projecte i es van assignar els permisos corresponents:

Es van crear les 7 carpetes per als microserveis:
```bash
mkdir -p ~/extagram-sprint2/{s1-nginx,s2-php,s3-php,s4-upload,s5-storage,s6-static,s7-mysql,docs}
```

![Carpetas creadas](/img/extagram_directori.png)

### 2.3.2. Configuració de Nginx (nginx.conf)
Dins de `s1-nginx/nginx.conf`, es va definir la lògica de balanceig i segmentació de trànsit. Aquesta configuració permet que el servidor funcioni com a proxy invers, delegant cada petició al contenidor especialitzat corresponent.

**Codi de configuració aplicat:**

[Enllaç al codi: nginx.conf](../extagram/s1-nginx-/nginx.conf)

### 2.3.3. Dockerització del Servei S1
Es va crear el **Dockerfile** específic per a **S1** amb l'objectiu d'automatitzar el desplegament de la configuració i garantir que el proxy invers estigui llest per operar immediatament en aixecar el contenidor.

S'ha utilitzat la imatge `nginx:alpine` per la seva lleugeresa i seguretat, sobreescrivint la configuració per defecte amb el nostre fitxer personalitzat.

**Contingut del Dockerfile (s1-nginx/Dockerfile):**

[Enllaç al codi: nginx.conf](../extagram/s1-nginx-/Dokerfile)

### 2.3.4. Automatització i Correcció del Proxy
Es va implementar un script de correcció en Bash per assegurar la integritat del sistema. Aquest script automatitza tasques crítiques per garantir que el fitxer `nginx.conf` i el `Dockerfile` estiguin correctament vinculats i operatius.

**Accions clau de l'script:**
* **Normalització:** Conversió de tots els noms de les carpetes a minúscules per evitar errors de rutes en sistemes Linux.
* **Neteja:** Eliminació de configuracions obsoletes o residuals d'altres servidors (com Apache/httpd) que podrien causar conflictes amb NGINX.
* **Sincronització:** Verificació que cada servei (S1-S7) tingui els seus fitxers de configuració actualitzats abans de l'aixecament.

![Verificació del desplegament S1](/img/verificacio_s1_77x)

### 2.3.5. Funcions del Sistema i Seguretat (Funcions "Invisibles")
Més enllà de la redirecció de trànsit, el servei **S1** executa tasques crítiques que garanteixen l'estabilitat i la seguretat de tota l'arquitectura:

* **Health Check (Control de Salut):** Implementa una ruta específica `/health` que retorna un codi `200 OK`. Això permet monitorar si el servidor web està actiu sense necessitat d'interactuar amb la base de dades o el motor PHP.
* **Gestió de Ports i Exposició:** És l'únic punt de contacte amb l'exterior. Obre exclusivament el port **90** (`90:90`), mantenint la resta de contenidors (S2-S7) totalment aïllats d'internet.
* **Seguretat i Aïllament de Xarxes:** Actua com a mur de contenció entre la xarxa `frontend` (pública) i la xarxa `backend` (privada). Això evita que un usuari pugui intentar connectar-se directament a la base de dades MySQL (S7).
* **Redirecció Automàtica d'Usuaris:** Gestió del flux d'entrada; si un usuari accedeix a l'arrel (`/`), el servidor executa una instrucció `return 302` cap a `/login.php`, assegurant que ningú accedeixi a l'aplicació sense autenticar-se.

> **En resum:** Si l'arquitectura fóra un edifici, la **S1** és simultàniament el **Vigilant de seguretat**, el **Policia de trànsit** que reparteix els cotxes i el **Recepcionista** que et diu on has d'anar.

### Resum de responsabilitats de S1
El contenidor **S1-lb** (Load Balancer) actua com l'únic punt d'entrada al sistema, gestionant les peticions de la següent manera:

* **Balanceig de càrrega:** Reparteix de forma dinàmica el trànsit de PHP entre els nodes **S2** i **S3**, millorant la disponibilitat del servei.
* **Segmentació de trànsit:**
    * **Recursos estàtics:** El CSS i SVG es deleguen al servidor **S6-static**.
    * **Emmagatzematge:** Les imatges contingudes a `/uploads/` es demanen directament a **S5-storage**.
    * **Gestió de fitxers:** Les pujades de fitxers (Uploads) es tramiten exclusivament a través del node especialitzat **S4-upload**.


## 2.4.Implementació i Configuració del Sistema (Sprint 2)
 



Dockerització i Optimització d'Imatges
S'han utilitzat imatges basades en **Alpine Linux** i **PHP-FPM** per reduir el pes total del projecte i millorar la seguretat. Cada servei té el seu propi `Dockerfile` per instal·lar les extensions necessàries (com `pdo_mysql` per al backend).

![Build de les imatges del sistema](/img/docker_build_r55.png)

## 2.5. Gestió de Volums i Persistència
Per evitar la pèrdua de dades, s'han definit volums gestionats per Docker que vinculen el sistema de fitxers de l'host amb els contenidors:
* **uploads-volume:** Compartit entre S4 (escriptura) i S5 (lectura).
* **mysql-data:** Per garantir la persistència de la base de dades MariaDB/MySQL.

![Configuració de volums i persistència](/img/volumes_setup_p12.png)

## 2.6. Orquestració amb Docker Compose
Mitjançant un fitxer `docker-compose.yml`, s'orquestren els 7 serveis simultàniament. Es defineixen dues xarxes virtuals (`frontend` i `backend`) per aïllar el trànsit de la base de dades del trànsit públic.

![Estat dels serveis aixecats amb Compose](/img/docker_services_status.png)

## 2.7. Variables d'Entorn i Seguretat
Es gestionen les credencials de la base de dades i els paràmetres de configuració mitjançant variables d'entorn, assegurant que la informació sensible no estigui exposada directament en els scripts de configuració.

![Gestió de configuració i variables](/img/env_vars_z44.png)