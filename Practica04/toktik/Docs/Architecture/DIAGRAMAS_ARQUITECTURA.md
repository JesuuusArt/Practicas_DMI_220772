# Diagramas de Arquitectura (Archify) — Práctica 04: TokTik

Este documento contiene los **2 diagramas de arquitectura** solicitados para la práctica de TokTik, modelados en formato interactivo **OpenCode Archify**:

> **Acceso a los Diagramas Interactivos Archify:**
> 1. 🏛️ **Diagrama 1: Provider Local** — [Abrir toktik_architecture.html](toktik_architecture.html) | [Especificación JSON](toktik.architecture.json) | [Doc Individual](DIAGRAMA_1_PROVIDER_LOCAL.md)
> 2. 🏗️ **Diagrama 2: Clean Architecture con Repositorio y 3 APIs** — [Abrir toktik_clean_architecture.html](toktik_clean_architecture.html) | [Especificación JSON](toktik_clean.architecture.json) | [Doc Individual](DIAGRAMA_2_CLEAN_ARCHITECTURE.md)

---

## 1. Diagrama 1: Arquitectura con Provider Local (Archify)

<div align="center">
  <a href="https://jesuuusart.github.io/Practicas_DMI_220772/Practica04/toktik/Docs/Architecture/toktik_architecture.html" title="Haz clic para abrir el Diagrama 1 en GitHub Pages">
    <img src="toktik_architecture.visual-check.2048x1320.dark.png" alt="Diagrama 1: Provider Local (Oscuro)" width="48%" />
    <img src="toktik_architecture.visual-check.2048x1320.light.png" alt="Diagrama 1: Provider Local (Claro)" width="48%" />
  </a>
</div>

En este esquema básico inicial, la interfaz de usuario se comunica directamente con el `DiscoverProvider`. El Provider accede de forma directa a los datos locales sin una capa intermedia de abstracción ni contratos de interfaz.

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

### Características del Diagrama 1:
- **Flujo directo:** El Provider tiene conocimiento explícito de la fuente de datos en memoria o assets.
- **Acoplamiento fuerte:** Cambiar o añadir una nueva fuente de datos requiere modificar la lógica interna del Provider.
- **Ideal para:** Prototipos rápidos y aplicaciones sencillas con una sola fuente fija de información.

---

## 2. Diagrama 2: Arquitectura Clean Code con Repositorio y Múltiples DataSources (Archify)

<div align="center">
  <a href="https://jesuuusart.github.io/Practicas_DMI_220772/Practica04/toktik/Docs/Architecture/toktik_clean_architecture.html" title="Haz clic para abrir el Diagrama 2 en GitHub Pages">
    <img src="toktik_clean_architecture.visual-check.2048x1320.dark.png" alt="Diagrama 2: Clean Architecture (Oscuro)" width="48%" />
    <img src="toktik_clean_architecture.visual-check.2048x1320.light.png" alt="Diagrama 2: Clean Architecture (Claro)" width="48%" />
  </a>
</div>

En este esquema profesional basado en **Clean Architecture**, se introducen las capas de **Dominio** e **Infraestructura**, desacoplando totalmente la interfaz gráfica de los orígenes de datos mediante el principio de inversión de dependencias.

```mermaid
graph TD
    subgraph Presentation ["Capa de Presentación (lib/presentation)"]
        UI_Screen["DiscoverScreen\n(For You / Discover / Favorites)"]
        Prov_Discover["DiscoverProvider"]
        Prov_Theme["ThemeProvider"]
        UI_Players["Players:\n- FullScreenPlayer (MP4/Local/Pixabay)\n- YoutubeShortsPlayer\n- DailymotionPlayer"]
    end

    subgraph Domain ["Capa de Dominio (lib/domain)"]
        Repo_Interface["<<interface>>\nVideoPostRepository\n+ getTrendingVideosByPage(page)\n+ getFavoriteVideosByUser(userId)"]
        Datasource_Interface["<<interface>>\nVideoPostDatasource\n+ getTrendingVideosByPage(page)\n+ getFavoriteVideosByUser(userId)"]
        Entity_Video["Entity: VideoPost\n(caption, videoUrl, youtubeId,\ndailymotionId, likes, views)"]
    end

    subgraph Infrastructure ["Capa de Infraestructura (lib/infrastructure)"]
        Repo_Impl["VideoPostsRepositoryImpl"]
        DS_Local["LocalVideoDatasource\n(Assets .mp4)"]
        DS_YouTube["YoutubeVideoDatasource\n(Google YouTube Data API v3)"]
        DS_Pixabay["PixabayVideoDatasource\n(Pixabay Videos API)"]
        DS_Dailymotion["DailymotionVideoDatasource\n(Dailymotion Public API)"]
    end

    subgraph Storage ["Almacenamiento Local"]
        Prefs["SharedPreferences\n(Likes persistentes, Mute, Temporada)"]
    end

    %% Relaciones Presentación -> Dominio
    UI_Screen --> Prov_Discover
    UI_Screen --> Prov_Theme
    Prov_Discover --> UI_Players
    Prov_Discover -->|Consume a través de| Repo_Interface
    Prov_Discover <-->|Guarda Likes y Mute| Prefs
    Prov_Theme <-->|Persistencia de Temporada| Prefs

    %% Relaciones Dominio -> Infraestructura
    Repo_Impl -.->|Implementa| Repo_Interface
    Repo_Impl -->|Delega en| Datasource_Interface

    DS_Local -.->|Implementa| Datasource_Interface
    DS_YouTube -.->|Implementa| Datasource_Interface
    DS_Pixabay -.->|Implementa| Datasource_Interface
    DS_Dailymotion -.->|Implementa| Datasource_Interface

    DS_Local -->|Retorna| Entity_Video
    DS_YouTube -->|Retorna| Entity_Video
    DS_Pixabay -->|Retorna| Entity_Video
    DS_Dailymotion -->|Retorna| Entity_Video
```

### Características del Diagrama 2:
- **Inversión de dependencias:** La capa de presentación y el Provider solo conocen las interfaces abstractas de la capa de dominio (`VideoPostRepository` y `VideoPostDatasource`).
- **Múltiples DataSources simultáneos:** Se integran 3 APIs remotas diferentes (**YouTube**, **Pixabay**, **Dailymotion**) más la fuente **Local de Assets**, todas cumpliendo el mismo contrato.
- **Escalabilidad:** Agregar un nuevo proveedor de video (por ejemplo Vimeo o TikTok API) solo requiere crear una clase que implemente `VideoPostDatasource`, sin tocar la interfaz ni el estado.
- **Separación de responsabilidades:** Cada componente tiene una única función bien definida, facilitando pruebas unitarias y mantenimiento.
