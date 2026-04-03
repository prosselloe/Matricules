# Blueprint del Projecte: Matrícules Provincials

## Visió General
Aquesta aplicació és una guia de referència completa i interactiva per a les matrícules provincials i estatals d'Espanya. Permet als usuaris explorar la història de cada província a través de les seves matrícules, cercar informació específica, i visualitzar dades de manera geogràfica i cronològica. L'aplicació està dissenyada per a historiadors, aficionats als cotxes, i qualsevol persona interessada en la història automobilística d'Espanya.

## Característiques Implementades

- **Catàleg de Províncies**:
    - Graella visualment atractiva de totes les províncies espanyoles amb les seves banderes corresponents.
    - **Cerca Dinàmica**: Cerca per nom de província, acrònim o capital en temps real.
    - **Filtratge per Autonomia**: Filtra les províncies per comunitat autònoma mitjançant un menú desplegable i un mapa interactiu.
    - **Ordenació Flexible**: Ordena la llista per nom, any d'implantació o per nombre d'unitats matriculades.

- **Cerca per Matrícules**:
    - **Cerca Nacional (Sistema 2000-Actualitat)**:
        - Introdueix una matrícula del sistema actual (p. ex., `1234 ABC`) per obtenir una data de matriculació estimada.
        - Mostra les matrícules provincials equivalents per a l'any de la matrícula cercada, amb un format clar i destacat.
    - **Cerca Provincial (Sistema 1907-2000)**:
        - **Validació Avançada per a Matrícules Alfanumèriques (1971-2000):**
            - Implementació de regles de validació estrictes per al sistema alfanumèric provincial.
            - Verificació del format de la matrícula (p. ex., `XX-0000-A` o `XX-0000-AB`).
            - **Regles de validació per a combinacions de lletres:**
                - **Una lletra:** No es fan servir les vocals, ni Ñ, Q, R.
                - **Dues lletres:**
                    - La primera lletra no pot ser Ñ, Q, R.
                    - La segona lletra no pot ser A, E, I, O, Ñ, Q, R.
                - La combinació "WC" no està permesa.
            - Missatges d'error clars i informatius per a l'usuari.

- **Pantalla de Detalls de la Província**:
    - **Transició Hero**: Animació de la bandera de la província des de la llista fins a la pantalla de detalls.
    - **Informació Completa**:
        - Imatge de la bandera a pantalla completa.
        - Descripció detallada sobre la història de la matriculació a la província.
        - Dades clau: acrònims utilitzats, autonomia, capital, regió i total d'unitats.
        - Secció de províncies limítrofes per a una navegació contextual.
        - Llista de períodes de matriculació amb rangs de números de matrícula i dates.

- **Eines Addicionals**:
    - **Descodificador de VIN**: Una utilitat per a vehicles moderns que descodifica un Número d'Identificació del Vehicle (VIN) de 17 dígits per obtenir informació detallada.
    - **Cerca per Bastidor (Històric)**: Eina per cercar informació sobre vehicles clàssics a partir del seu número de bastidor.

- **Visualització Geogràfica**:
    - **Mapa d'Autonomies**: Un mapa interactiu que apareix en filtrar per autonomia, destacant la regió seleccionada.

- **Personalització i Usabilitat**:
    - **Temes Clar i Fosc**: Suport complet per a temes clar i fosc.
    - **Localització**: L'aplicació està completament localitzada en català (`ca`).

- **Pantalla d'Informació**:
    - Una secció "Quant a l'aplicació" que mostra informació rellevant sobre el projecte.

## Estil i Disseny (UI/UX)

- **Tipografia**: `Google Fonts` s'utilitza per a una estètica moderna i llegible:
    - **Títols**: `Exo 2` per a una aparença tècnica.
    - **Text del Cos**: `Lato` per a una llegibilitat òptima.
- **Paleta de Colors**:
    - **Color Primari**: Blau fosc (`#001e50`).
    - **Esquema de Colors**: Generat amb `ColorScheme.fromSeed` per a consistència en temes clar i fosc.
- **Components Visuals**:
    - **Targetes (`Card`)**: Per agrupar informació de manera clara i amb profunditat visual.
    - **Consistència**: Disseny coherent a tota l'aplicació mitjançant temes centralitzats.
    - **`RichText`**: S'utilitza per a una presentació de dades més rica i amb format, com en el cas de les matrícules provincials equivalents.

## Estructura i Arquitectura del Projecte

- **Gestió d'Estat**: `provider` per a la gestió de l'estat global (`ThemeProvider`, `ModelProvider`).
- **Navegació**: `go_router` per a una navegació declarativa i robusta.
- **Estructura de Fitxers**:
    - `lib/`
        - `main.dart`: Punt d'entrada i configuració general.
        - `models/`: Classes de dades (`MatriculaModel`, `StatePlateData`).
        - `providers/`: Gestors d'estat (`ModelProvider`).
        - `services/`: Lògica de negoci i càrrega de dades.
        - `screens/`: Pantalles de l'aplicació.
        - `widgets/`: Components reutilitzables.
    - `assets/`
        - `data/`: Fitxers de dades en format JSON (`db_*.json`).
        - `images/`: Banderes de les províncies.
- `pubspec.yaml`: Definició de dependències i actius.
- `blueprint.md`: Aquest fitxer.

## Pla de Desenvolupament Actual

### Reconeixement de Matrícules per Imatge

S'implementarà una nova funcionalitat per permetre als usuaris reconèixer una matrícula a partir d'una fotografia feta amb la càmera o seleccionada des de la galeria.

1.  **Integració de Dependències**:
    *   S'afegirà `image_picker` per permetre la selecció d'imatges.
    *   S'afegirà `google_ml_kit_text_recognition` per realitzar el Reconeixement Òptic de Caràcters (OCR) sobre la imatge.

2.  **Interfície d'Usuari (UI)**:
    *   S'afegirà un botó d'acció flotant (`FloatingActionButton`) o una icona a la barra de cerca per iniciar el procés.

3.  **Lògica de Reconeixement**:
    *   Es crearà una funció per gestionar el flux de selecció d'imatge (càmera o galeria).
    *   La imatge seleccionada serà processada pel servei de reconeixement de text.
    *   S'aplicarà un filtre sobre el text extret per identificar patrons que coincideixin amb formats de matrícules espanyoles (provincials i estatals).

4.  **Diàleg de Verificació i Correcció**:
    *   Un cop identificada una matrícula potencial, es mostrarà un diàleg emergent a l'usuari.
    *   Aquest diàleg contindrà un camp de text (`TextField`) pre-omplert amb la matrícula reconeguda, permetent a l'usuari verificar-la i corregir-la si és necessari.
    *   En confirmar, la matrícula (ja verificada) s'enviarà al servei de cerca existent per mostrar-ne els detalls.
