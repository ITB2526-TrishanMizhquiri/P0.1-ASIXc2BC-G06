# Sprint 3 Review: Failover y Segmentación de Microservicios
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
- **Resum:** S'ha finalitzat el desplegament amb una arquitectura d'alta seguretat. S'han segmentat els serveis en xarxes diferenciades i s'ha validat la capacitat del sistema per seguir operatiu davant la caiguda de nodes (Alta Disponibilitat).

## 2. Demostració de Resultats (MVP)
Durant aquesta fase final, s'han validat els punts crítics de la infraestructura:
- **Aïllament de Xarxa:** La base de dades (S7) ja no és accessible des de l'exterior; només rep peticions de la xarxa interna backend-net.
- **Proves de Failover:** S'ha simulat la caiguda del contenidor S2. El balancejador (S1) ha redirigit el trànsit a S3 de manera automàtica sense que l'usuari final detectés cap interrupció.
- **Optimització d'Estàtics:** S'ha comprovat mitjançant les eines de desenvolupador del navegador que el CSS es serveix exclusivament des de S6 i les fotos des de S5.
- **Documentació:** S'han lliurat els manuals ADMINISTRADOR.md i les actes de seguiment.

## 3. Incidències i Solucions Tècniques
En aquesta etapa final de poliment, hem resolt els darrers problemes:
- **Error de Resolució DNS entre xarxes:**
    - **Símptoma:** El servidor S4 (Uploads) no podia connectar amb S7 (BD) en separar-los en xarxes diferents.
    - **Solució:** Es va configurar S4 per pertànyer a ambdues xarxes (frontend i backend), actuant com a pont segur per a la pujada d'imatges.

- **Latència al detectar caiguda de nodes:**
    - **Símptoma:** Quan un node PHP queia, el Proxy tardava uns segons a redirigir el trànsit, donant un error 502 momentani.
    - **Solució:** S'han ajustat els paràmetres max_fails i fail_timeout en la configuració de l'upstream de NGINX (S1) per a una detecció gairebé instantània.

## 4. Conclusions i Propers Passos
L'Extagram ha passat d'una app monolítica a un sistema professional de microserveis. El projecte es tanca amb:
    1. **7 Serveis** totalment funcionals.
    2. **Zero pèrdua de dades** gràcies als volums compartits.
    3. **Seguretat per segmentació** de xarxa.

## 5. Evidència de tancament (ProofHub)
Afegeix aquí la captura final amb **totes** les tasques del projecte a la columna de **Done**. És la imatge que demostra l'èxit total del projecte.

![Tasques Finalitzat](/img/proofhub/tasques_finalizats_sprint3.png)
