# Sprint 1 Review: Validació del MVP
Data de la reunió: 20/01/2026
Equip: Trishan Mizhquiri i Joel Muñoz

## Índice
[1. Estat del Sprint](#1-estat-del-sprint) 

[2. Demostració de Resultats (MVP)](#2-demostració-de-resultats-mvp) 

[3. Incidències i Solucions Tècniques](#3-incidències-i-solucions-tècniques) 

[4. Conclusions i Propers Passos](#4-conclusions-i-propers-passos) 

[5. Evidència de tancament (ProofHub)](#5-evidència-de-tancament-proofhub)


## 1. Estat del Sprint
- **Objectiu:** Aconseguit ✅.
- **Resum:** S'ha desplegat amb èxit l'aplicació Extagram en una instància EC2 d'AWS Lab. L'aplicació és totalment funcional sota un stack LEMP monolític, servint com a prova de concepte positiva abans de la fase de dockerització.

## 2. Demostració de Resultats (MVP)
Durant la sessió de revisió, s'ha validat que el sistema compleix els següents punts:
- **Servidor Web:** NGINX respon correctament a les peticions HTTP.
- **Base de Dades:** Mariadb emmagatzema les dades dels "posts" (text i ruta de la imatge).
- **Funcionalitat:** El formulari puja fitxers al directori */var/www/html/uploads* i PHP-FPM els processa sense errors.
- **Persistència:** Les dades es mantenen després de reiniciar els serveis.

## 3. Incidències i Solucions Tècniques
Durant el desenvolupament (especialment en la Sessió 3), van sorgir problemes que van requerir intervenció:

- **Problema de Connexió a la BD:**
    - **Símptoma:** Error "Connection failed" al carregar el fitxer PHP.
    - **Solució:** Es va detectar que el mòdul *php-mysqli* no estava actiu i que l'usuari *extagram_admin* no tenia permisos per connectar des de localhost. Es van refrescar els privilegis amb *FLUSH PRIVILEGES*; i es va reinstal·lar el mòdul de PHP.

- **Error de Càrrega d'Imatges (Permisos):**
    - **Símptoma:** El fitxer PHP no podia escriure a la carpeta *uploads/*.
    - **Solució:** Es va ajustar el propietari de la carpeta a l'usuari de NGINX (*www-data*) i s'aplicaren permisos *775* per garantir que el servidor tingués permisos d'escriptura.

## 4. Conclusions i Propers Passos
L'MVP ha demostrat que l'aplicació és estable. No obstant això, l'arquitectura actual no és escalable ni fàcilment replicable.
- **Propers passos per al Sprint 2:**
    - **Migració a Docker:** Dividir els serveis en contenidors independents (S1-S7).
    - **Orquestració:** Crear el fitxer docker-compose.yml per automatitzar tot el desplegament.
    - **Aïllament:** Configurar xarxes Docker per separar la base de dades del trànsit públic.

## 5. Evidència de tancament (ProofHub)
Aquí podries incloure una captura del teu ProofHub on totes les tasques apareguin ja a la columna de **"Done"** o **"Completat"**.

![Tasques Finalitzat](/img/proofhub/tasques_finalizats.png)