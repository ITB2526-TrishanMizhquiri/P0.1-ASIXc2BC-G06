# Sprint 2 Review: Dockerització i Microserveis
Data de la reunió: 27/01/2026
Equip: Trishan Mizhquiri i Joel Muñoz

## Índice
[1. Estat del Sprint](#1-estat-del-sprint) 

[2. Demostració de Resultats (MVP)](#2-demostració-de-resultats-mvp) 

[3. Incidències i Solucions Tècniques](#3-incidències-i-solucions-tècniques) 

[4. Conclusions i Propers Passos](#4-conclusions-i-propers-passos) 

[5. Evidència de tancament (ProofHub)](#5-evidència-de-tancament-proofhub)


## 1. Estat del Sprint
- **Objectiu:** Aconseguit ✅.
- **Resum:** S'ha migrat amb èxit tota l'aplicació Extagram a un entorn de contenidors. S'ha passat d'un model monolític a una infraestructura de 7 serveis (S1-S7) orquestrats amb *docker-compose*, garantint la persistència de dades i el balanceig de càrrega.

## 2. Demostració de Resultats (MVP)
Durant la revisió, s'ha validat el funcionament de cada component:
- **S1 (Proxy/Balancejador):** Rep el trànsit i el distribueix correctament.
- **S2 i S3 (Execució):** Funcionen com a rèpliques, processant la web de manera alternada.
- **S4 (Uploads):** Gestiona les pujades de fitxers de forma independent.
- **S5 i S6 (Estàtics):** Serveixen imatges i CSS/SVG respectivament, descarregant de feina als servidors PHP.
- **S7 (Base de Dades):** MySQL funciona amb persistència gràcies a l'script init.sql.

## 3. Incidències i Solucions Tècniques
Durant la dockerització han sorgit reptes que hem solucionat conjuntament:
- **Problema de Persistència d'Imatges:**
    - **Símptoma:** Les imatges pujades a S4 no apareixien a la web (S2/S3) ni al servidor d'estàtics (S5).
    - **Solució:** Es va implementar un **volum compartit de Docker** (*uploads-volume*) que connecta els quatre contenidors, permetent que el fitxer escrit per un sigui llegit pels altres.

- **Error de Connexió a la BD des dels Contenidors:**
    - **Símptoma:** PHP no trobava la base de dades utilitzant localhost.
    - **Solució:** Es va modificar la configuració de PHP per apuntar al nom del servei Docker (s7-db) en lloc de localhost, aprofitant el DNS intern de Docker.

## 4. Conclusions i Propers Passos
L'arquitectura és ara molt més professional i escalable. Tot i això, tots els contenidors estan en una mateixa xarxa per defecte, cosa que volem millorar.
**Propers passos per al Sprint 3:**
    1. Seguretat de Xarxa: Crear xarxes frontend i backend per aïllar la base de dades.
    2. Topologia: Dissenyar el mapa de xarxa detallat (IPs i ports).
    3. Proves de Resiliència: Verificar que si apaguem el contenidor S2, l'aplicació segueix funcionant a través del S3.

## 5. Evidència de tancament (ProofHub)
Aquí és on has de posar la captura de la teva columna **"Done"** del Sprint 2 amb totes les tasques de Docker que hem llistat abans.

![Tasques Finalitzat](/img/proofhub/tasques_finalizats_sprint2.png)