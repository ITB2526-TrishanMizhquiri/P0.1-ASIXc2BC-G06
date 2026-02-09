# Sprint 1 Planning: Anàlisi i MVP
Període: 15/12/2025 – 20/01/2026
## Índice
[1. Objetivo del Sprint](#1-objetivo-del-sprint)  

[1.1. Estat inicial de la planificació (ProofHub)](#1-estat-inicial-de-la-planificació-proofhub)

[2. Full de Ruta Detallat](#2-full-de-ruta-detallat)

[2.1. Sessió 1: 15/12/2025 – 16/12/2025 (Inici i Gestió)](#21-sessió-1-15122025--16122025-inici-i-gestió)

[2.2. Sessió 2: 12/01/2026 – 13/01/2026 (Infraestructura i Base de Dades)](#22-sessió-2-12012026--13012026-infraestructura-i-base-de-dades)

[2.3. Sessió 3: 19/01/2026 – 20/01/2026 (Desenvolupament i Validació)](#23-sessió-3-19012026--20012026-desenvolupament-i-validació)

[3. Resum de Responsabilitats (Equitat)](#3-resum-de-responsabilitats-equitat)

## 1. Objetivo del sprint:

Dissenyar l'arquitectura inicial del sistema i desplegar un Mínim Producte Viable (MVP) funcional en una sola màquina EC2 en AWS lab per validar l'aplicació Extagram abans de la seva dockerització en el següent Sprint.

### 1.1. Estat inicial de la planificació (ProofHub)
A continuació es mostra el tauler de gestió amb totes les tasques creades i assignades abans de l'inici de les execucions:

![Captura ProofHub - Tasques inicials](/img/proofhub/tasques_inicials.png)

## 2. Full de Ruta Detallat

### 2.1. Sessió 1: 15/12/2025 – 16/12/2025 (Inici i Gestió)

#### Tasques a realitzar:
- Identificar totes les tecnologies implicades (NGINX, PHP, MySQL).
- Crear el repositori a GitHub i configurar el fitxer README.md inicial.
- Configurar l'autenticació per clau SSH entre la màquina de treball i GitHub.
- Elaborar la llista de requisits funcionals (pujar fotos, llistar posts) i no funcionals.
- Crear i documentar l'Acta de Planning inicial en Markdown.

#### Assignació de tasques:
- **Identificació de tecnologies i configuració SSH:** Trishan Mizhquiri.
- **Creació del repositori GitHub i README:** Trishan Mizhquiri.
- **Anàlisi de requisits funcionals i no funcionals:** Joel Muñoz.
- **Redacció i edició de l'Acta de Planning:** Trishan Mizhquiri i Joel Muñoz.

#### Dubtes inicials o riscos:
- **Risc de seguretat:** Exposició accidental de claus privades si no es configura correctament el fitxer .gitignore.
- **Dubte tècnic:** Incertesa sobre quina versió de PHP és la més estable per als scripts heretats del projecte.

### 2.2. Sessió 2: 12/01/2026 – 13/01/2026 (Infraestructura i Base de Dades)

#### Tasques a realitzar:
- Instal·lar el servidor web NGINX a la màquina EC2 AWS LAB.
- Instal·lar i realitzar la configuració bàsica de seguretat del motor MySQL.
- Instal·lar PHP i assegurar la connectivitat mitjançant el mòdul php-mysqli.
- Crear la base de dades extagram_db i definir l'estructura de la taula de publicacions.
- Configurar l'usuari administrador de la base de dades amb els privilegis mínims necessaris.

#### Assignació de tasques:
- **Instal·lar NGINX en EC2 AWS LAB:**  Trishan Mizhquiri.
- **Instal·lar i assegurar MySQL:**  Joel Muñoz.
- **Instal·lar PHP i el mòdul *mysqli*:**  Trishan Mizhquiri.
- **Crear BD *extagram_db* i taula de posts:**  Joel Muñoz.
- **Configurar usuari admin i privilegis:**  Trishan Mizhquiri.

#### Dubtes inicials o riscos:
- **Risc de conflicte:** Possible ocupació del port 80 per processos previs que podria impedir l'arrencada de NGINX.
- **Risc de configuració:** Errors en el fitxer php.ini que podrien desactivar la càrrega de mòduls crítics per a MySQL.

### 2.3. Sessió 3: 19/01/2026 – 20/01/2026 (Desenvolupament i Validació)

#### Tasques a realitzar:
- Copiar i adaptar els fitxers de codi font (extagram.php, upload.php) a l'entorn local.
- Crear el directori uploads/ i assignar els permisos 775 per permetre l'escriptura des del servidor web.
- Verificar que el formulari realitza la càrrega de fitxers al directori correcte.
- Provar la visualització de les imatges carregades des de la interfície web.
- Finalitzar la documentació del Sprint 1 i preparar l'acta de Review.

#### Assignació de tasques:
- **Adaptar fitxers PHP a l'entorn local:** Trishan Mizhquiri.
- **Crear carpeta uploads/ i permisos 775:** Trishan Mizhquiri.
- **Verificar càrrega de fitxers al directori:** Joel Muñoz.
- **Provar visualització web de les imatges:** Trishan Mizhquiri.
- **Finalitzar documentació i Acta de Review:** Joel Muñoz.

#### Dubtes inicials o riscos:
- **Risc de permisos:** Que l'usuari www-data no tingui accés d'escriptura a la carpeta de destinació, bloquejant les pujades.
- **Risc d'espai:** Que la configuració de PHP limiti la mida dels fitxers a carregar (upload_max_filesize).

## 3. Resum de Responsabilitats (Equitat)
Totes les tasques s'han distribuït per assegurar que cada bloc setmanal tingués una càrrega de treball equilibrada, cobrint tant la part d'administració de sistemes com la de documentació.