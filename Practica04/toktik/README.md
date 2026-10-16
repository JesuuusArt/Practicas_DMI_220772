# Práctica 04: TokTik — Aplicación de Reproducción de Videos Verticales

> **Materia:** Desarrollo Móvil Integral (DMI) — (30 Firmas)  
> **Estudiante:** Jesus Alejandro Artiaga Morales  
> **Matrícula:** 220772 (10º A)  
> **Docente:** M.T.I. Marco A. Ramírez Hernández  
> **Periodo:** Septiembre — Diciembre 2026  

---

<div align="center">

[![Portafolio GitHub Pages](https://img.shields.io/badge/🌐%20Portafolio%20en%20Vivo-GitHub%20Pages-06b6d4?style=for-the-badge&logo=github)](https://jesuuusart.github.io/Practicas_DMI_220772/)
[![Flutter](https://img.shields.io/badge/Flutter-3.47.2-02569B?style=for-the-badge&logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.13.2-0175C2?style=for-the-badge&logo=dart)](https://dart.dev)
[![Clean Architecture](https://img.shields.io/badge/Architecture-CLEAN%20Code-10b981?style=for-the-badge)](Docs/Architecture/DIAGRAMAS_ARQUITECTURA.md)

🔗 **[https://jesuuusart.github.io/Practicas_DMI_220772/](https://jesuuusart.github.io/Practicas_DMI_220772/)**

</div>

---

## 1. Descripción de la Práctica

Aplicación móvil desarrollada en Flutter que simula la experiencia completa de la red social **TikTok** con reproducción continua de videos en desplazamiento vertical. El proyecto está construido bajo los principios de **Clean Architecture**, incorporando:

- **Widgets Stateless y Stateful:** Ciclos de vida, controladores y componentes atómicos reutilizables.
- **Gestión de Estado Reactiva:** MultiProvider (`ThemeProvider` y `DiscoverProvider`).
- **Manejo Integral de Assets:** Videos `.mp4` locales, audios estacionales `.mp3`, iconografía y tipografías personalizadas (`Poppins`, `Creepster`, `MountainsOfChristmas`, `DancingScript`).
- **Paquetes Externos Especializados:** `video_player`, `youtube_player_flutter`, `webview_flutter` (con `Player.js`), `audioplayers`, `shared_preferences`, `animate_do`, `intl`, `http`.
- **Consumo de APIs Remotas:** Integración de **YouTube Data API v3**, **Pixabay Videos API** y **Vimeo API v3** (autenticación `Bearer` con Personal Access Token).
- **GestureDetector:** Para reproducir/pausar, dar/quitar likes, silenciar/desmutear, expandir descripciones y cambiar temas.
- **Posicionamiento y Stacks:** Superposición de controles (`Positioned`), degradados de lectura (`LinearGradient`) y lluvia de partículas dinámicas por temporada (`ThemeOverlay`).
- **Mappers y Aserciones:** Transformación segura de modelos JSON a entidades de dominio con validación por `assert`.
- **Loops y Filtros:** Animaciones cíclicas de temporadas, reproducción en bucle y filtrado dinámico de videos (`views > likes`).

---

## 2. Funcionalidades Específicas Implementadas

### 🎃 🎄 🟣 💖 A. Temas Visuales y Auditivos por Temporada
- **4 Temporadas completas:**
  - **Halloween:** Tipografía *Creepster*, paleta naranja/negra (`#FFFF7518`), audio ambiental `halloween.mp3`, icono de calabaza y animación de murciélagos/calabazas.
  - **Navidad:** Tipografía *Mountains of Christmas*, paleta verde/rojo navideño (`#FF2ECC71`), audio `navidad.mp3`, icono de pino y lluvia de copos de nieve.
  - **San Valentín (Valentine's Day):** Tipografía *Dancing Script*, paleta rosa neón (`#FFFF2E63`), audio romántico `valentines.mp3`, icono con cupidos/corazones y lluvia de corazones.
  - **Normal / Principal:** Tipografía *Poppins*, paleta púrpura (`#FF8E3CC3`), audio base y partículas suaves.
- **Carga automática por fecha:** Detecta el mes actual del dispositivo (Octubre = Halloween, Diciembre = Navidad, Febrero = San Valentín).
- **Mecanismo de prueba interactivo:** Modal `showModalBottomSheet` accesible tocando el badge superior de TokTik o el icono estacional, permitiendo forzar cualquier temporada y persistiendo la selección en **Local Storage** (`SharedPreferences`).
- **Script para cambiar el Launcher Icon:** Herramienta [cambiar_icono.ps1](cambiar_icono.ps1) para actualizar el icono nativo de Android en `mipmap-*/` según la temporada a evaluar.

### 📱 B. Secciones Discover / For You / Favorites (Desplazamiento Lateral)
- **Navegación horizontal (`TabBar` + `TabBarView`):** Permite deslizamiento lateral entre las 3 pestañas principales:
  1. **Para ti (For You):** Videos locales destacados (`LocalVideoDatasource`).
  2. **Descubrir (Discover):** Integración unificada de las 3 APIs remotas (YouTube, Pixabay y Vimeo) con chips horizontales de filtrado interactivo.
  3. **Favoritos (Favorites):** Feed reactivo que extrae en tiempo real los videos marcados con corazón por el usuario.

### 🔇 C. Muteado y Activación de Sonido
- Botón de volumen ubicado en la columna inferior derecha (`VideoButtons`) con micro-animación `AnimatedSwitcher`.
- Sincronización en vivo:
  - Videos MP4 locales y de Pixabay vía `VideoPlayerController.setVolume(muted ? 0 : 1)`.
  - YouTube Shorts vía `_controller.mute()` y `_controller.unMute()`.
  - Vimeo mediante **Player.js API** (`setMuted`), cambiando el volumen **en vivo sin recargar el iframe**.
- Estado de silencio persistido en `SharedPreferences` (`'muted'`).

### ❤️ D. Persistencia de "Me Gusta" (Local Storage)
- Al pulsar el corazón:
  - Si se marca: suma +1 like, activa el corazón rojo con animación `Pulse` (`animate_do`).
  - Si se desmarca: resta -1 like y vuelve al icono blanco de contorno.
- Persistencia atómica en `SharedPreferences` bajo las claves `likes_{key}` y `liked_{key}`.
- Al reiniciar la aplicación, las estadísticas de likes se recargan desde el almacenamiento local.

### 📜 E. Descripción Extensa con (... más) y Desplazamiento Vertical
- Si la descripción excede el límite de 65 caracteres o 2 líneas, muestra automáticamente el sufijo interactivo `... más`.
- Al pulsar `... más`, el contenedor se expande ocupando un máximo del 35% de la pantalla, activando un **`SingleChildScrollView` con scrollbar vertical visible** (`RawScrollbar`) que permite leer el texto completo sin tapar la columna de botones. Incluye botón `menos` para replegar.

### 🌐 F. Consumo de 3 DataSources Remotos Diferentes
Arquitectura multicapa desacoplada cumpliendo con Clean Architecture:
1. **Google YouTube Data API v3** (`YoutubeVideoDatasource`)
2. **Pixabay Videos API** (`PixabayVideoDatasource`)
3. **Vimeo API v3** (`VimeoVideoDatasource`, autenticación por cabecera `Authorization: Bearer <token>`)
4. **Local Assets DataSource** (`LocalVideoDatasource`)

---

## 3. Diagramas de Arquitectura (Archify)

📄 *Para la documentación técnica extendida, consulta: [DIAGRAMAS_ARQUITECTURA.md](Docs/Architecture/DIAGRAMAS_ARQUITECTURA.md).*

> 🌐 **Visores Dinámicos en Vivo en GitHub Pages:**
> - 🏛️ [**Diagrama 1: Provider Local** — Ver interactivo en GitHub Pages](https://jesuuusart.github.io/Practicas_DMI_220772/Practica04/toktik/Docs/Architecture/toktik_architecture.html)
> - 🏗️ [**Diagrama 2: Clean Architecture con Repositorio y 3 APIs** — Ver interactivo en GitHub Pages](https://jesuuusart.github.io/Practicas_DMI_220772/Practica04/toktik/Docs/Architecture/toktik_clean_architecture.html)

---

### Diagrama 1: Arquitectura con Provider Local

<div align="center">
  <a href="https://jesuuusart.github.io/Practicas_DMI_220772/Practica04/toktik/Docs/Architecture/toktik_architecture.html" title="Haz clic para abrir el Diagrama 1 interactivo en GitHub Pages">
    <img src="Docs/Architecture/toktik_architecture.visual-check.2048x1320.dark.png" alt="Diagrama 1: Provider Local (Oscuro)" width="49%" />
    <img src="Docs/Architecture/toktik_architecture.visual-check.2048x1320.light.png" alt="Diagrama 1: Provider Local (Claro)" width="49%" />
  </a>
  <p><em>👆 Haz clic en cualquiera de las imágenes para interactuar con el Diagrama 1 en GitHub Pages</em></p>
</div>

Muestra el flujo directo inicial donde la interfaz de usuario consume los datos a través del Provider conectado directamente al almacenamiento y assets locales:

```mermaid
graph TD
    subgraph UI ["Capa de Presentación (UI)"]
        A["DiscoverScreen"] --> B["VideoScrollableView"]
        B --> C["FullScreenPlayer"]
        B --> D["VideoButtons"]
        B --> E["VideoCaption (... más)"]
    end

    subgraph StateManagement ["Gestor de Estado"]
        F["DiscoverProvider (ChangeNotifier)"]
    end

    subgraph LocalData ["Datos y Almacenamiento Local"]
        G["videoPosts (local_video_post.dart)"]
        H["LocalVideoModel (Mapper / JSON)"]
        I["SharedPreferences (Likes & Muted)"]
    end

    A -.->|watch / read| F
    D -.->|toggleLike / toggleMuted| F
    F -->|Carga directa de datos| G
    G -->|Mapea a entidad| H
    F <-->|Persistencia directa| I
```

---

### Diagrama 2: Arquitectura Clean Code con Repositorio y Múltiples DataSources

<div align="center">
  <a href="https://jesuuusart.github.io/Practicas_DMI_220772/Practica04/toktik/Docs/Architecture/toktik_clean_architecture.html" title="Haz clic para abrir el Diagrama 2 interactivo en GitHub Pages">
    <img src="Docs/Architecture/toktik_clean_architecture.visual-check.2048x1320.dark.png" alt="Diagrama 2: Clean Architecture (Oscuro)" width="49%" />
    <img src="Docs/Architecture/toktik_clean_architecture.visual-check.2048x1320.light.png" alt="Diagrama 2: Clean Architecture (Claro)" width="49%" />
  </a>
  <p><em>👆 Haz clic en cualquiera de las imágenes para interactuar con el Diagrama 2 en GitHub Pages</em></p>
</div>

Muestra el desacoplamiento mediante **Inversión de Dependencias**, donde la Presentación solo interactúa con contratos de Dominio, y la Infraestructura implementa los DataSources para **YouTube, Pixabay, Vimeo y Local**:

```mermaid
graph TD
    subgraph Presentation ["Capa de Presentación (lib/presentation)"]
        UI_Screen["DiscoverScreen\n(For You / Discover / Favorites)"]
        Prov_Discover["DiscoverProvider"]
        Prov_Theme["ThemeProvider"]
        UI_Players["Players:\n- FullScreenPlayer (MP4/Local/Pixabay)\n- VimeoPlayer (embed + Player.js)\n- YoutubeShortsPlayer"]
    end

    subgraph Domain ["Capa de Dominio (lib/domain)"]
        Repo_Interface["<<interface>>\nVideoPostRepository\n+ getTrendingVideosByPage(page)\n+ getFavoriteVideosByUser(userId)"]
        Datasource_Interface["<<interface>>\nVideoPostDatasource\n+ getTrendingVideosByPage(page)\n+ getFavoriteVideosByUser(userId)"]
        Entity_Video["Entity: VideoPost\n(caption, videoUrl, youtubeId,\nvimeoId, likes, views)"]
    end

    subgraph Infrastructure ["Capa de Infraestructura (lib/infrastructure)"]
        Repo_Impl["VideoPostsRepositoryImpl"]
        DS_Local["LocalVideoDatasource\n(Assets .mp4)"]
        DS_YouTube["YoutubeVideoDatasource\n(Google YouTube Data API v3)"]
        DS_Pixabay["PixabayVideoDatasource\n(Pixabay Videos API)"]
        DS_Vimeo["VimeoVideoDatasource\n(Vimeo API v3 + Token)"]
    end

    subgraph Storage ["Almacenamiento Local"]
        Prefs["SharedPreferences\n(Likes persistentes, Mute, Temporada)"]
    end

    UI_Screen --> Prov_Discover
    UI_Screen --> Prov_Theme
    Prov_Discover --> UI_Players
    Prov_Discover -->|Consume a través de| Repo_Interface
    Prov_Discover <-->|Guarda Likes y Mute| Prefs
    Prov_Theme <-->|Persistencia de Temporada| Prefs

    Repo_Impl -.->|Implementa| Repo_Interface
    Repo_Impl -->|Delega en| Datasource_Interface

    DS_Local -.->|Implementa| Datasource_Interface
    DS_YouTube -.->|Implementa| Datasource_Interface
    DS_Pixabay -.->|Implementa| Datasource_Interface
    DS_Vimeo -.->|Implementa| Datasource_Interface

    DS_Local -->|Retorna| Entity_Video
    DS_YouTube -->|Retorna| Entity_Video
    DS_Pixabay -->|Retorna| Entity_Video
    DS_Vimeo -->|Retorna| Entity_Video
```

---

## 4. 📸 Galería de Evidencias de Ejecución (24 Capturas)

A continuación se presentan las 24 capturas de pantalla tomadas directamente en el dispositivo físico Android (**LLY LX3**), demostrando los 5 estados obligatorios y la pantalla de carga con su icono respectivo para cada una de las 4 temporadas:

---

### 🟣 A. Tema Principal (Normal)
*Tipografía **Poppins**, paleta púrpura (`#8E3CC3`), partículas de luces dinámicas e icono circular de la app.*

<div align="center">
  <p><strong>Pantalla de Carga Inicial (Splash Screen con Icono Principal):</strong></p>
  <img src="assets/pruebas/pantallaCargaPrincipal.jpeg" alt="Pantalla de Carga Principal" width="220" />
</div>

<br/>

| 1. Local (Sin Like) | 2. Local (Con Like +1) | 3. Local Propio (Con Like) | 4. API Remota (Con Like) | 5. Sección Favoritos |
| :---: | :---: | :---: | :---: | :---: |
| <img src="assets/pruebas/principal_1_local_sin_like.jpeg" width="180" alt="Principal Sin Like" /> | <img src="assets/pruebas/principal_2_local_con_like.jpeg" width="180" alt="Principal Con Like" /> | <img src="assets/pruebas/principal_3_personalizado_like.jpeg" width="180" alt="Principal Video Propio" /> | <img src="assets/pruebas/principal_4_api_like.jpeg" width="180" alt="Principal API Like" /> | <img src="assets/pruebas/principal_5_favoritos.jpeg" width="180" alt="Principal Favoritos" /> |
| *Corazón blanco vacío* | *Corazón rojo animado (+1)* | *Video propio agregado* | *Video de API con like* | *Pestaña Favoritos con video API* |

---

### 🎃 B. Tema Halloween (Octubre)
*Tipografía **Creepster**, paleta calabaza (`#FF7518`), audio `halloween.mp3`, lluvia de calabazas y murciélagos animados.*

<div align="center">
  <p><strong>Pantalla de Carga Inicial (Splash Screen con Icono Calabaza):</strong></p>
  <img src="assets/pruebas/pantallaCargaHalloween.jpeg" alt="Pantalla de Carga Halloween" width="220" />
</div>

<br/>

| 1. Local (Sin Like) | 2. Local (Con Like +1) | 3. Local Propio (Con Like) | 4. API Remota (Con Like) | 5. Sección Favoritos |
| :---: | :---: | :---: | :---: | :---: |
| <img src="assets/pruebas/halloween_1_local_sin_like.jpeg" width="180" alt="Halloween Sin Like" /> | <img src="assets/pruebas/halloween_2_local_con_like.jpeg" width="180" alt="Halloween Con Like" /> | <img src="assets/pruebas/halloween_3_personalizado_like.jpeg" width="180" alt="Halloween Video Propio" /> | <img src="assets/pruebas/halloween_4_api_like.jpeg" width="180" alt="Halloween API Like" /> | <img src="assets/pruebas/halloween_5_favoritos.jpeg" width="180" alt="Halloween Favoritos" /> |
| *Corazón blanco vacío* | *Corazón rojo animado (+1)* | *Video propio agregado* | *Video de API con like* | *Pestaña Favoritos con video API* |

---

### 🎄 C. Tema Navidad (Diciembre)
*Tipografía **Mountains of Christmas**, paleta verde pino/rojo (`#2ECC71` / `#C41E3A`), audio `navidad.mp3` y copos de nieve cayendo.*

<div align="center">
  <p><strong>Pantalla de Carga Inicial (Splash Screen con Icono Navideño):</strong></p>
  <img src="assets/pruebas/pantallaCargaNavidad.jpeg" alt="Pantalla de Carga Navidad" width="220" />
</div>

<br/>

| 1. Local (Sin Like) | 2. Local (Con Like +1) | 3. Local Propio (Con Like) | 4. API Remota (Con Like) | 5. Sección Favoritos |
| :---: | :---: | :---: | :---: | :---: |
| <img src="assets/pruebas/navidad_1_local_sin_like.jpeg" width="180" alt="Navidad Sin Like" /> | <img src="assets/pruebas/navidad_2_local_con_like.jpeg" width="180" alt="Navidad Con Like" /> | <img src="assets/pruebas/navidad_3_personalizado_like.jpeg" width="180" alt="Navidad Video Propio" /> | <img src="assets/pruebas/navidad_4_api_like.jpeg" width="180" alt="Navidad API Like" /> | <img src="assets/pruebas/navidad_5_favoritos.jpeg" width="180" alt="Navidad Favoritos" /> |
| *Corazón blanco vacío* | *Corazón rojo animado (+1)* | *Video propio agregado* | *Video de API con like* | *Pestaña Favoritos con video API* |

---

### 💖 D. Tema San Valentín (Febrero)
*Tipografía **Dancing Script**, paleta rosa neón (`#FF2E63`), audio romántico `valentines.mp3`, lluvia de corazones neón y nuevo icono con cupidos y rosas.*

<div align="center">
  <p><strong>Pantalla de Carga Inicial (Splash Screen con Nuevo Icono de San Valentín):</strong></p>
  <img src="assets/pruebas/pantallaCargaValentine.jpeg" alt="Pantalla de Carga San Valentín" width="220" />
</div>

<br/>

| 1. Local (Sin Like) | 2. Local (Con Like +1) | 3. Local Propio (Con Like) | 4. API Remota (Con Like) | 5. Sección Favoritos |
| :---: | :---: | :---: | :---: | :---: |
| <img src="assets/pruebas/valentines_1_local_sin_like.jpg" width="180" alt="San Valentín Sin Like" /> | <img src="assets/pruebas/valentines_2_local_con_like.jpg" width="180" alt="San Valentín Con Like" /> | <img src="assets/pruebas/valentines_3_personalizado_like.jpg" width="180" alt="San Valentín Video Propio" /> | <img src="assets/pruebas/valentines_4_api_like.jpg" width="180" alt="San Valentín API Like" /> | <img src="assets/pruebas/valentines_5_favoritos.jpg" width="180" alt="San Valentín Favoritos" /> |
| *Corazón blanco vacío* | *Corazón rojo animado (+1)* | *Video propio agregado* | *Video de API con like* | *Pestaña Favoritos con video API* |

---

## 5. Tecnologías y Paquetes Utilizados

| Paquete / Tecnología | Versión | Propósito en el Proyecto |
| :--- | :---: | :--- |
| **Flutter** | `3.47.2` | Framework base para desarrollo multiplataforma. |
| **Dart** | `3.13.2` | Lenguaje de programación fuertemente tipado con Null Safety. |
| **provider** | `^6.1.5+1` | Inyección de dependencias y reactividad (`DiscoverProvider`, `ThemeProvider`). |
| **video_player** | `^2.10.0` | Reproducción a pantalla completa de videos MP4 locales y de Pixabay. |
| **youtube_player_flutter** | `^9.1.1` | Reproducción nativa embebida de videos de YouTube Shorts. |
| **webview_flutter** | `^4.14.1` | Reproductor embebido de Vimeo controlado dinámicamente con `Player.js`. |
| **audioplayers** | `^6.8.1` | Reproducción de sonidos ambientales y efectos auditivos estacionales. |
| **shared_preferences** | `^2.3.3` | Persistencia en Local Storage de likes, mute y tema seleccionado. |
| **animate_do** | `^4.0.0` | Micro-animaciones para el botón de me gusta (`Pulse`) y transiciones. |
| **intl** | `^0.20.2` | Formato legible compacto para números de likes y vistas (ej. `24.5K`, `1.2M`). |
| **http** | `^1.6.0` | Peticiones HTTP a las APIs de YouTube, Pixabay y Vimeo. |
| **Vimeo API v3** | `v3.4` | API autenticada con Personal Access Token; expone `likes` y `plays` reales. |

---

## 6. Estructura del Proyecto (Clean Architecture)

```
lib/
├── config/
│   ├── api_keys.dart                 # Claves para YouTube, Pixabay y Vimeo
│   ├── helpers/
│   │   └── human_formats.dart        # Formato numérico legible (K, M)
│   └── theme/
│       ├── app_theme.dart            # Tema Normal / Principal (Poppins)
│       ├── christmas_theme.dart      # Tema Navidad (Mountains of Christmas)
│       ├── halloween_theme.dart      # Tema Halloween (Creepster)
│       ├── season.dart               # Utilidad de resolución temporal
│       └── valentines_theme.dart     # Tema San Valentín (Dancing Script)
│
├── domain/                           # Reglas de negocio e interfaces puras
│   ├── datasources/
│   │   └── video_posts_datasource.dart
│   ├── entities/
│   │   └── video_post.dart           # Entidad VideoPost con validaciones assert
│   └── repositories/
│       └── video_posts_repository.dart
│
├── infrastructure/                   # Implementaciones concretas
│   ├── datasources/
│   │   ├── local_video_datasource_impl.dart
│   │   ├── pixabay_video_datasource_impl.dart
│   │   ├── vimeo_video_datasource_impl.dart
│   │   └── youtube_video_datasource_impl.dart
│   ├── models/
│   │   └── local_video_model.dart    # Modelos y mappers a entidades
│   └── repositories/
│       └── video_posts_repository_impl.dart
│
├── presentation/                     # Interfaz de usuario y estado
│   ├── providers/
│   │   ├── discover_provider.dart    # Estado de feeds, likes, vistas y mute
│   │   └── theme_provider.dart       # Estado de temporadas, audios y paleta
│   ├── screens/
│   │   └── discover/
│   │       └── discover_screen.dart  # Pantalla principal con TabBarView
│   └── widgets/
│       ├── shared/
│       │   ├── theme_overlay.dart    # Lluvia de partículas de temporada
│       │   ├── video_buttons.dart    # Columna lateral (like, vistas, mute)
│       │   └── video_scrollable_view.dart # PageView vertical infinito
│       └── video/
│           ├── fullscreen_player.dart# Reproductor nativo de video MP4
│           ├── video_background.dart # Gradiente de sombra para textos
│           ├── video_caption.dart    # Descripción expandible (... más)
│           ├── vimeo_player.dart     # WebView con Vimeo Player.js
│           └── youtube_shorts_player.dart # Reproductor YouTube Shorts
└── main.dart
```

---

## 7. Instrucciones de Ejecución

```bash
# 1. Obtener dependencias
flutter pub get

# 2. Verificar análisis estático de código (0 issues)
flutter analyze

# 3. (Opcional) Cambiar el icono de launcher para pruebas
.\cambiar_icono.ps1 navidad    # Opciones: principal, halloween, navidad, valentines

# 4. Ejecutar en tu dispositivo o emulador
flutter run
```
