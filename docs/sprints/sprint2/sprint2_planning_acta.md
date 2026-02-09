# SPRINT 2: PLANNING (Dockerització i Orquestració)
Període: 20/01/2026 – 27/01/2026

## Índice
[1. Objetivo del Sprint](#1-objetivo-del-sprint)  

[1.1. Estat inicial de la planificació (ProofHub)](#1-estat-inicial-de-la-planificació-proofhub)

[2. Full de Ruta Detallat](#2-full-de-ruta-detallat)

[2.1. Sessió 1: 20/01/2026 – 21/01/2026 (Estructura i Base de Dades)](#21-sessió-1-20012026--21012026-estrucutura-i-base-de-dades)

[2.2. Sessió 2: 22/01/2026 – 23/01/2026 (Backend i Contingut Estàtic](#22-sessió-2-22012026--23012026-backend-i-contingut-estàtic)

[2.3. Sessió 3: 26/01/2026 – 27/01/2026 (Proxy Invers i Validació)](#23-sessió-3-26012026--27012026-proxy-invers-i-validació)

[3. Resum de Responsabilitats (Equitat)](#3-resum-de-responsabilitats-equitat)

## 1. Objetivo del sprint:

Migrar la aplicación del entorno monolítico (una sola máquina) a una arquitectura microsegmentada utilizando Docker. El reto es separar la aplicación en 7 servicios independientes (S1-S7) orquestados con docker-compose para mejorar la escalabilidad y el mantenimiento.

### 1.1. Estat inicial de la planificació (ProofHub)
A continuació es mostra el tauler de gestió amb totes les tasques creades i assignades abans de l'inici de les execucions:

![Captura ProofHub - Tasques inicials](/img/proofhub/tasques_inicials_sprint2.png)

## 2. Full de Ruta Detallat

### Sessió 1: 20/01/2026 – 21/01/2026 (Estructura i Base de Dades)

#### Tasques a realitzar:
- Crear l'estructura de directoris Docker per a cada servei (S1-S7).
- Configurar el servei S7 (MySQL) utilitzant un fitxer init.sql per automatitzar la creació de la base de dades.
- Crear el fitxer docker-compose.yml base amb la definició dels primers contenidors.
- Configurar el volum compartit (uploads-volume) per a la persistència de les imatges.

#### Assignació de tasques:
- **Estructura de carpetes** Joel Muñoz
- **Configurar el volum compartit:** Trishan Mizhquiri.
- **Crear fitxer Docker-compose:** Joel Muñoz.
- **Configuració de MySQL (S7)** Trishan Mizhquiri i Joel Muñoz.

#### Dubtes inicials o riscos:
- **Risc de seguretat:** Exposició accidental de claus privades o credencials de la base de dades si no es configura correctament el fitxer .gitignore per als fitxers de configuració Docker.
- **Dubte tècnic:** Incertesa sobre la persistència de dades en el volum compartit si es reinicia el contenidor de MySQL sense els flags adequats.

### 2.2. Sessió 2: 22/01/2026 – 23/01/2026 (Backend i Contingut Estàtic)

#### Tasques a realitzar:
- Configurar els serveis S2 i S3 (PHP-FPM) com a rèpliques de processament.
- Configurar el servei S4 (PHP-FPM upload) dedicat a la gestió de fitxers.
- Configurar S5 (NGINX) per servir el contingut de uploads/.
- Configurar S6 (NGINX) per servir fitxers estàtics (CSS/SVG).

#### Assignació de tasques:
- **Configurar els serveis S2 i S3 (PHP-FPM)**  Trishan Mizhquiri.
- **Configurar el servei S4 (PHP-FPM upload)**  Joel Muñoz.
- **Configurar S5 (NGINX)**  Trishan Mizhquiri.
- **Configurar S6 (NGINX)**  Joel Muñoz.

#### Dubtes inicials o riscos:
- **Risc de seguretat:** Possible filtració de rutes internes del servidor si la configuració de NGINX als serveis S5 i S6 no restringeix l'accés a fitxers sensibles.
- **Dubte tècnic:** Incertesa sobre quina versió de PHP-FPM és la més adequada per als scripts de processament d'imatges sense perdre funcionalitats.

### 2.3. Sessió 3: 26/01/2026 – 27/01/2026 (Proxy Invers i Validació)

#### Tasques a realitzar:
- Configurar el servei S1 (NGINX) com a Proxy Invers i Balancejador de càrrega.
- Executar docker-compose up -d i verificar l'estat dels 7 contenidors.
- Proves funcionals de pujada de fotos i llistat de publicacions en l'entorn distribuït.
- Redactar l'Acta de Review del Sprint 2 i finalitzar la documentació.

#### Assignació de tasques:
- **Configurar el servei S1 (NGINX)** Trishan Mizhquiri.
- **Proves funcionals de pujada de fotos** Trishan Mizhquiri.
- **Executar docker-compose up -d** Joel Muñoz.
- **Redactar l'Acta de Review del Sprint 2** Trishan Mizhquiri i Joel Muñoz.

#### Dubtes inicials o riscos:
- **Risc de seguretat:** Exposició de ports interns cap a l'exterior si la configuració del Proxy Invers (S1) no aïlla correctament els serveis de backend i base de dades.

- **Dubte tècnic:** Incertesa sobre l'estabilitat de la connexió entre el balancejador i les instàncies de PHP sota càrrega continuada d'imatges.

## 3. Resum de Responsabilitats (Equitat)
Totes les tasques s'han distribuït per assegurar que cada bloc setmanal tingués una càrrega de treball equilibrada, cobrint tant la part d'administració de sistemes com la de documentació.