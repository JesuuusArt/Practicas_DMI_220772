# Diagrama 1: Arquitectura con Provider Local (Archify)

> 🌐 **Visor Interactivo en GitHub Pages:** [https://jesuuusart.github.io/Practicas_DMI_220772/Practica04/toktik/Docs/Architecture/toktik_architecture.html](https://jesuuusart.github.io/Practicas_DMI_220772/Practica04/toktik/Docs/Architecture/toktik_architecture.html)  
> 📊 **Formato de Especificación:** [toktik.architecture.json](toktik.architecture.json)

<div align="center">
  <a href="https://jesuuusart.github.io/Practicas_DMI_220772/Practica04/toktik/Docs/Architecture/toktik_architecture.html" title="Haz clic para abrir el Diagrama 1 en GitHub Pages">
    <img src="toktik_architecture.visual-check.2048x1320.dark.png" alt="Diagrama 1: Provider Local (Oscuro)" width="48%" />
    <img src="toktik_architecture.visual-check.2048x1320.light.png" alt="Diagrama 1: Provider Local (Claro)" width="48%" />
  </a>
</div>

---

## Descripción Técnica
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
