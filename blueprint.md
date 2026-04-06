# Blueprint de l'Aplicació de Matrícules

## **OVERVIEW**

Aquest document descriu el disseny, l'arquitectura i les funcionalitats de l'aplicació "Matricules", una eina per a consultar informació detallada sobre matrícules de vehicles a Espanya. L'objectiu és proporcionar una interfície intuïtiva i rica en dades per a explorar els diferents sistemes de matriculació que han existit.

## **PROJECT OUTLINE**

A continuació es detalla l'estructura de l'aplicació, incloent-hi l'estil, el disseny i les funcionalitats implementades.

### **1. Estructura i Navegació**

*   **Pàgina Principal (`home_page.dart`)**:
    *   Presenta una interfície clara amb dues opcions principals: "Matrícules Provincials" i "Matrícules Estatals".
    *   Utilitza un `Scaffold` amb un `AppBar` que mostra el títol de l'aplicació.
    *   El cos està centrat i conté dos botons elevats que condueixen a les respectives seccions de cerca.
    *   Disseny responsiu que s'adapta a diferents mides de pantalla.

*   **Sistema de Rutes (`go_router`)**:
    *   S'ha implementat `go_router` per a gestionar la navegació de manera declarativa i robusta.
    *   Les rutes definides són:
        *   `/`: Pàgina principal.
        *   `/provincial`: Llança el diàleg de cerca per a matrícules provincials.
        *   `/estatal`: Llança el diàleg de cerca per a matrícules estatals.
        *   `/vehicle-details`: Mostra detalls tècnics d'un vehicle (encara no implementat completament).

### **2. Disseny i Experiència d'Usuari (UX)**

*   **Tema Visual (`theme_provider.dart`)**:
    *   S'utilitza `ColorScheme.fromSeed` amb `Colors.deepPurple` per a generar una paleta de colors moderna i consistent (Material 3).
    *   Tipografia personalitzada amb `google_fonts`, utilitzant `Oswald` per a títols i `Roboto` per al cos del text, per a millorar la llegibilitat i l'estètica.
    *   S'ha implementat un `ThemeProvider` (`provider`) per a permetre a l'usuari canviar entre els modes clar i fosc.
    *   El tema defineix estils consistents per a `AppBar`, `ElevatedButton` i altres components.

*   **Components d'Interfície**:
    *   **Diàlegs de Cerca**: Es fan servir `AlertDialog` per a les cerques, la qual cosa permet una experiència d'usuari focalitzada sense canviar de pantalla.
    *   **Iconografia**: S'han afegit icones informatives (`Icons.info_outline`) per a oferir a l'usuari ajuda contextual sobre els formats de matrícula.
    *   **Feedback a l'Usuari**: S'utilitzen `CircularProgressIndicator` per a indicar estats de càrrega i `errorText` als camps de text per a mostrar missatges d'error clars.
    *   **Imatges i Actius**: S'han inclòs banderes (`espana.png`, banderes de comunitats autònomes) per a enriquir visualment la informació presentada.

### **3. Lògica del Negoci i Gestió de Dades**

*   **Gestió d'Estat (`provider`)**:
    *   `ModelProvider`: Carrega i gestiona les dades de les matrícules des d'un fitxer `assets/matricules.csv`. Conté la lògica principal per a cercar i processar la informació.
    *   `ThemeProvider`: Gestiona l'estat del tema (clar/fosc).

*   **Serveis Externs**:
    *   `DgtService`: Servei per a interactuar amb la web de la DGT i obtenir el distintiu ambiental d'un vehicle a partir de la seva matrícula.
    *   `PlateApiService`: Servei (futur) per a obtenir detalls tècnics avançats d'un vehicle.

*   **Models de Dades**:
    *   Les dades es processen des d'un fitxer CSV i es converteixen en mapes de `String` a `dynamic` per a facilitar-ne la manipulació i presentació.

### **4. Funcionalitats Clau Implementades**

*   **Cerca de Matrícules Provincials (`provincial_plate_search_dialog.dart`)**:
    *   Permet a l'usuari introduir una matrícula provincial (ex: "B 1234 AB").
    *   Valida el format de la matrícula.
    *   Mostra informació detallada: any de matriculació, província, i la matrícula estatal equivalent si escau.

*   **Cerca de Matrícules Estatals (`state_plate_search_dialog.dart`)**:
    *   Permet introduir una matrícula del sistema modern (ex: "1234 ABC").
    *   Mostra l'any de matriculació i la data aproximada.
    *   Calcula i mostra una llista de les matrícules provincials equivalents per a aquell any.
    *   **Consulta del Distintiu Ambiental**:
        *   Després d'una cerca, contacta amb el servei de la DGT per a obtenir i mostrar la imatge del distintiu ambiental corresponent.

*   **Funcionalitat "Secreta" / Oculta**:
    *   Al diàleg de cerca estatal, si l'usuari toca la bandera d'Espanya 7 vegades, apareix un botó per a consultar detalls tècnics addicionals del vehicle, fent ús del `PlateApiService`.

### **5. Millores de Qualitat i Arquitectura**

*   **Càrrega de dades optimitzada**: El fitxer CSV es llegeix una sola vegada a l'inici de l'aplicació i es manté en memòria amb el `ModelProvider`, evitant lectures repetides.
*   **Separació de Responsabilitats**: El codi està organitzat en serveis (per a la lògica d'API), proveïdors (per a la gestió de l'estat), widgets (per a la interfície) i models.
*   **Format de Data i Números**: S'utilitza el paquet `intl` per a formatar les dates i els números segons les convencions locals (`es_ES`), millorant l'experiència de l'usuari.

---

## **PLAN ACTUAL: Depuració Servei DGT i Gestió de CORS**

En aquesta darrera fase, s'ha abordat un problema crític que impedia obtenir el distintiu ambiental de la DGT quan l'aplicació s'executava en un navegador web.

**Canvis i Millores:**

*   **Identificació del Problema**: Es va detectar que les peticions directes des del client web al servidor de la `sede.dgt.gob.es` eren bloquejades pel navegador a causa de la **política del mateix origen (Same-Origin Policy)**, resultant en un error de **CORS**.
*   **Intents de Solució amb Proxies**:
    1.  Es va implementar un primer proxy (`corsproxy.io`). Aquesta solució va ser descartada perquè el servei gratuït limita el seu ús a entorns de no producció.
    2.  Es van provar altres proxies públics (`api.allorigins.win`, `thingproxy.freeboard.io`), però van resultar inestables o eren bloquejats directament pel servidor de la DGT, retornant errors `520`.
*   **Decisió Final (a petició de l'usuari)**:
    *   S'ha **eliminat tota la lògica de proxies** del `DgtService`.
    *   L'aplicació ara realitza les peticions directament a la DGT.
*   **Conseqüències i Estat Actual**:
    *   **Plataformes Mòbils (iOS/Android)**: La funcionalitat de consulta del distintiu ambiental hauria de funcionar correctament, ja que les aplicacions natives no estan subjectes a les mateixes restriccions CORS que els navegadors.
    *   **Plataforma Web**: Aquesta funcionalitat **no operarà correctament a la web**. L'error de CORS és esperat en aquest entorn a causa de la configuració de seguretat del servidor de la DGT, que no permet peticions `cross-origin` des de navegadors.
*   **Neteja de Codi**: S'han eliminat imports no utilitzats i s'ha refactoritzat el `DgtService` per a simplificar-lo després de llevar els proxies.
