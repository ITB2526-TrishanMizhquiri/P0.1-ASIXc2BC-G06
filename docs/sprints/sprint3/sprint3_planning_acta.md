# SPRINT 3: PLANNING (Xarxes, Seguretat i Validació Final)
Període: 02/02/2026 – 10/02/2026

## Índice
[1. Objetivo del Sprint](#1-objetivo-del-sprint)  

[1.1. Estat inicial de la planificació (ProofHub)](#1-estat-inicial-de-la-planificació-proofhub)

[2. Full de Ruta Detallat](#2-full-de-ruta-detallat)

[2.1. Sessió 1: 02/02/2026 – 03/02/2026 (Seguretat de Xarxa i Topologia)](#21-sessió-1-02022026--03022026-seguretat-de-xarxa-i-topologia)

[2.2. Sessió 2: 05/02/2026 – 06/02/2026 (Proves de Càrrega i Resiliència)](#22-sessió-2-05022026--06022026-proves-de-càrrega-i-resiliència)

[2.3. Sessió 3: 09/02/2026 – 10/02/2026 (Documentació Final i Tancament)](#23-sessió-3-09022026--10022026-documentació-final-i-tancament)

[3. Resum de Responsabilitats (Equitat)](#3-resum-de-responsabilitats-equitat)

## 1. Objetivo del sprint:

Finalitzar el projecte optimitzant la seguretat de la infraestructura Docker mitjançant l'aïllament de xarxes (frontend/backend). Es realitzaran proves d'alta disponibilitat i es lliurarà tota la documentació tècnica i manuals d'usuari per al tancament del projecte dia 10.

### 1.1. Estat inicial de la planificació (ProofHub)
A continuació es mostra el tauler de gestió amb totes les tasques creades i assignades abans de l'inici de les execucions:

![Captura ProofHub - Tasques inicials](/img/proofhub/tasques_inicials_sprint3.png)

## 2. Full de Ruta Detallat

### 2.1. Sessió 1: 02/02/2026 – 03/02/2026 (Seguretat de Xarxa i Topologia)

#### Tasques a realitzar:
- Definir xarxes Docker personalitzades (frontend-net i backend-net) per aïllar la base de dades (S7) de l'accés extern.
- Dissenyar el diagrama de xarxa detallat (Topologia) amb IPs, ports i fluxos de dades.
- Configurar el fitxer docker-compose.yml final amb les noves directives de xarxa.

#### Assignació de tasques:
- **Dissenyar el diagrama de xarxa** Joel Muñoz
- **Configurar el fitxer docker-compose.yml** Trishan Mizhquiri.
- **Definir xarxes Docker** Trishan Mizhquiri i Joel Muñoz.

#### Dubtes inicials o riscos:
- **Risc de seguretat:** Exposició accidental de claus privades o credencials si la segmentació de xarxes no restringeix correctament el trànsit extern cap a la BD.
- **Dubte tècnic:** Incertesa sobre quina versió de les directives de xarxa a Docker-compose és la més compatible amb l'aïllament de contenidors heretats.

### 2.2. Sessió 2: 05/02/2026 – 06/02/2026 (Proves de Càrrega i Resiliència)

#### Tasques a realitzar:
- Realitzar proves de "failover": apagar S2 i verificar que S3 assumeix tot el trànsit sense interrupció.
- Verificar que els fitxers estàtics es serveixen correctament des de S5 (uploads) i S6 (assets).
- Comprovar que el balancejador (S1) reparteix la càrrega de manera equitativa.

#### Assignació de tasques:
- **Comprovar que el balancejador (S1):**  Trishan Mizhquiri.
- **Realitzar proves de "failover":**  Joel Muñoz.
- **Verificar que els fitxers estàtics S5:**  Trishan Mizhquiri.

#### Dubtes inicials o riscos:
- **Risc de seguretat:** Possible pèrdua de traçabilitat dels logs si la configuració de xarxa bloqueja l'escriptura d'auditoria durant les proves de càrrega.
- **Dubte tècnic:** Incertesa sobre la versió de PHP-FPM utilitzada i la seva capacitat de resposta davant una fallida sobtada d'un dels nodes del balancejador.

### 2.3. Sessió 3: 09/02/2026 – 10/02/2026 (Documentació Final i Tancament)

#### Tasques a realitzar:
- Finalitzar el document ADMINISTRADOR.md amb la guia de desplegament i el diagrama de xarxa.
- Redactar el manual d'usuari i la guia de manteniment de l'aplicació.
- Crear l'Acta de Review final del Sprint 3 i tancar totes les tasques al ProofHub.

#### Assignació de tasques:
- **Crear l'Acta de Review final** Trishan Mizhquiri.
- **Redactar el manual d'usuari i la guia de manteniment** Joel Muñoz.
- **Finalitzar el document ADMINISTRADOR.md** Trishan Mizhquiri i Joel Muñoz.

#### Dubtes inicials o riscos:
- **Risc de seguretat:** Exposició de claus privades o rutes internes sensibles en els manuals tècnics que es pujaran al repositori públic.
- **Dubte tècnic:** Incertesa sobre si la versió de la documentació Markdown és prou clara per replicar l'entorn de 7 contenidors des de zero en qualsevol màquina.

## 3. Resum de Responsabilitats (Equitat)
Totes les tasques s'han distribuït per assegurar que cada bloc setmanal tingués una càrrega de treball equilibrada, cobrint tant la part d'administració de sistemes com la de documentació.