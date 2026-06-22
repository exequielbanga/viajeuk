# Viaje UK — App iOS nativa (SwiftUI)

App nativa para iPhone que organiza el viaje a UK de Exe & Mica. Es la versión nativa de la web `viaje-uk.html`, con las mismas funciones:

- **Itinerario** día por día agrupado por ciudad, con fotos, horarios, costos, enlaces y mapas.
- **Reservado** como interruptor por entrada; **enlace** y **Google Maps** editables (con sugerencia automática de Maps).
- **Comidas por día** (Desayuno / Almuerzo / Merienda / Cena) con sugerencias según la ciudad, precio estimado editable y mapa.
- **Días libres** con selector buscable de actividades, incluyendo sugerencias de la IA (prefijo **AI ·**).
- **Presupuesto** por categoría con gráfico de dona, en **USD + £ libras + ARS pesos** (tipos de cambio editables; dólar a 1500 ARS por defecto).
- **Persistencia automática** (no se pierde nada) + **respaldo** descargable/restaurable (archivo JSON, vía la app Archivos).
- **Exportar** cambios (copiar / compartir) y **Sincronizar** con la hoja (CSV publicado opcional).

## Requisitos
- **Xcode 15 o superior**
- **iOS 16.0+** (usa NavigationStack, Layout, ShareLink, Swift Charts no requerido — la dona es Canvas propio)

## Cómo abrirlo en Xcode

### Opción A — con XcodeGen (lo más rápido)
1. Instalá XcodeGen: `brew install xcodegen`
2. En esta carpeta (`ViajeUK-iOS/`) corré: `xcodegen generate`
3. Se crea `ViajeUK.xcodeproj`. Abrilo y dale ▶︎ Run.

### Opción B — manual (sin herramientas extra)
1. Xcode → **File → New → Project… → iOS → App**.
2. Product Name: **ViajeUK**, Interface: **SwiftUI**, Language: **Swift**. Creá el proyecto.
3. En el proyecto nuevo, **borrá** los dos archivos que crea Xcode por defecto: `ContentView.swift` y `ViajeUKApp.swift` (Move to Trash). Esto es importante: si no, vas a tener dos `@main` y no compila.
4. Arrastrá **todos los archivos `.swift` de esta carpeta** al proyecto (panel izquierdo). En el diálogo, tildá **“Copy items if needed”** y que estén marcados para el target **ViajeUK**.
5. Seleccioná un simulador (ej. iPhone 15) y dale ▶︎ Run.

> Para correr en un iPhone físico: en *Signing & Capabilities* elegí tu *Team* (cuenta de Apple gratuita sirve).

## Archivos
- `ViajeUKApp.swift` — punto de entrada.
- `Models.swift` — estructuras Codable.
- `TripData.swift` — datos del itinerario, comidas, sugerencias (incluye las AI), ideas y pubs.
- `AppState.swift` — estado observable: persistencia, monedas, presupuesto, parser CSV/sync, export, respaldo.
- `Theme.swift` — paleta británica.
- `SharedComponents.swift`, `FlowLayout.swift` — componentes reutilizables.
- `ContentView.swift` — pestañas.
- `SummaryView.swift` — resumen, tipos de cambio, respaldo, accesos a Sync/Export.
- `ItineraryView.swift` — ciudades, días, comidas.
- `ItemRow.swift` — fila de actividad + selector de día libre.
- `BudgetView.swift` — presupuesto + dona.
- `IdeasView.swift` — ideas + pubs.
- `SyncView.swift`, `ExportView.swift` — hojas modales.

## Sincronización compartida entre Exe y Mica (CloudKit)

Los dos usan la app y **los cambios de uno aparecen en la del otro**. Funciona con **CloudKit** (la nube de Apple, sin servidor propio): hay un único registro compartido del viaje en la **base pública** del contenedor iCloud de la app. Cada dispositivo sube sus cambios (con un pequeño retardo) y baja+fusiona los del otro al abrir la app, al volver al frente, al tocar el botón de refrescar, y por **notificación silenciosa** (casi en tiempo real).

- La **fusión** es por entrada: si Exe edita el día 3 y Mica el día 5, se conservan los dos. Si ambos tocan exactamente lo mismo, gana el cambio más reciente.
- En **Resumen** hay una tarjeta “Compartido con …” con el estado de iCloud, un botón para sincronizar ahora, y un selector **“Soy: Exe / Mica”** (sirve para mostrar quién hizo la última edición).

### Requisitos para que funcione la nube
1. **Cuenta del Apple Developer Program** (de pago, USD 99/año). CloudKit no funciona con cuenta gratuita.
2. Ambos iPhones con **sesión de iCloud** iniciada (Ajustes → tu nombre).

### Pasos en Xcode (una vez)
> ⚠️ El código usa `CKContainer.default()`, que apunta a **`iCloud.<tu bundle id>`**. Si tu bundle id es `com.test.july2026`, el contenedor es **`iCloud.com.test.july2026`**. El error “Couldn't get container configuration from the server” significa que ese contenedor todavía no está habilitado/creado en Apple. Para solucionarlo:

1. En el target → **Signing & Capabilities**, asegurate de estar logueado con tu **Team** (Apple Developer Program).
2. **+ Capability → iCloud**. Tildá **CloudKit**. En **Containers**, tocá **+** y dejá/creá el contenedor que coincide con tu bundle id (ej. `iCloud.com.test.july2026`). **Importante:** que quede el ✓ al lado del contenedor — eso lo crea en el servidor y llena el `com.apple.developer.icloud-container-identifiers` (que ahora está vacío).
3. **+ Capability → Push Notifications** (para las actualizaciones en vivo).
4. **+ Capability → Background Modes** → tildá **Remote notifications**.
5. En el **iPhone/simulador**, iniciá sesión en **iCloud** (Ajustes → tu nombre).
6. **Clean Build Folder** (⇧⌘K) y corré de nuevo.
7. La primera vez que se guarda un registro, CloudKit crea el tipo `TripState` solo en **Development**. Para distribuir (TestFlight/App Store), entrá al **CloudKit Console** y hacé **Deploy Schema to Production**.

> Si querés mantener el bundle id `com.test.july2026`, está perfecto: solo asegurate de que el contenedor de iCloud sea `iCloud.com.test.july2026` y quede tildado. No hace falta tocar el código.

### Permiso de escritura para AMBOS (paso clave para que los dos puedan editar)
En la base **pública** de CloudKit, por defecto **solo quien crea el registro puede modificarlo**. Como el viaje vive en un único registro compartido, el segundo usuario (ej. Mica) puede **leer** los cambios pero no **escribir** hasta que le des permiso. Si en un iPhone aparece *“Recibís los cambios ✓, pero falta permiso para enviar…”*, hacé esto **una sola vez**:

1. Entrá a **CloudKit Console** → https://icloud.developer.apple.com/dashboard → elegí tu contenedor (`iCloud.com.test.july2026`).
2. Andá a **Schema → Security Roles** (entorno **Development**).
3. En el rol **`_icloud` (Authenticated Users)**, marcá **Write** (además de Read/Create) para el tipo de registro **`TripState`** (o para todos los record types).
4. **Save**. Ahora cualquiera de los dos, logueado en su propio iCloud, puede editar el viaje compartido.
5. Para distribuir por TestFlight/App Store, repetí en **Production** o usá **Deploy Schema to Production**.

> Nota de privacidad: la base pública implica que, técnicamente, cualquier usuario de *esta misma app* con tu contenedor podría leer/escribir el registro. Para Exe & Mica es práctico; si más adelante querés que sea estrictamente privado entre ustedes dos, se migra a **CKShare** (base privada compartida con invitación) — más setup. Avisá y lo armo.

> Si no configurás CloudKit, la app igual funciona perfecto en modo individual: guarda todo localmente y muestra “iCloud no disponible”. La sincronización compartida se activa sola cuando están las capacidades y la sesión de iCloud.

## Ícono de la app
El ícono es una **foto real de Arlington Row (Bibury, Cotswolds)** recortada cuadrada, en `Assets.xcassets/AppIcon.appiconset/icon-1024.png` (1024×1024, sin transparencia).

- **Con XcodeGen:** ya queda incluido (el `Assets.xcassets` está en `project.yml` y `ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon`). Solo `xcodegen generate` y listo.
- **Proyecto manual:** arrastrá `Assets.xcassets` a Xcode (o abrí **Assets → AppIcon** y arrastrá `icon-1024.png` al casillero de 1024 pt). Xcode genera el resto de tamaños.

> Crédito/licencia: la foto proviene de **Wikimedia Commons** (Arlington Row, Bibury). Para uso personal está perfecto; si alguna vez publicás la app en la App Store, verificá la licencia de la imagen en su página de Commons y agregá la atribución correspondiente (o reemplazala por una foto propia / con licencia libre). Puedo cambiarla por otra cuando quieras.

## Notas
- Las **fotos** se cargan de internet (Unsplash/Wikimedia) — necesita conexión la primera vez. Si no hay red, se ve un degradado de respaldo. (HTTPS, no requiere configurar ATS.)
- Los **cambios se guardan solos** en el dispositivo (UserDefaults). El **respaldo** es por si cambiás de iPhone.
- **Sincronizar en vivo** funciona solo si publicás la hoja como CSV (*Archivo → Compartir → Publicar en la web → CSV*) y pegás esa URL en la pantalla de Sincronizar. Si no, pedile a Claude “re-sincronizá con el Sheet” y actualiza los datos embebidos.
- No hay backend ni dependencias externas: es 100% SwiftUI + Foundation.
