# Diagramas de Arquitectura (Archify) — Práctica 05: Widgets App

Este documento presenta los **2 diagramas de arquitectura interactivos** diseñados para la aplicación **Widgets App**, cumpliendo con los estándares de **OpenCode Archify** y los lineamientos de la Práctica 05:

> **🔗 Enlaces Directos a los Diagramas Interactivos en GitHub Pages:**
> 1. 🏛️ **Diagrama 1: Arquitectura General Tecnológica** — [Ver interactivo en GitHub Pages ↗](https://jesuuusart.github.io/Practicas_DMI_220772/Practica05/widgets_app/Docs/Architecture/widgets_app_general_architecture.html) | [Archivo HTML](widgets_app_general_architecture.html) | [Especificación JSON](widgets_app_general.architecture.json) | [Doc Individual](DIAGRAMA_1_ARQUITECTURA_GENERAL.md)
> 2. 🏗️ **Diagrama 2: Arquitectura Específica de Pantallas, Rutas y Estados** — [Ver interactivo en GitHub Pages ↗](https://jesuuusart.github.io/Practicas_DMI_220772/Practica05/widgets_app/Docs/Architecture/widgets_app_specific_architecture.html) | [Archivo HTML](widgets_app_specific_architecture.html) | [Especificación JSON](widgets_app_specific.architecture.json) | [Doc Individual](DIAGRAMA_2_ARQUITECTURA_ESPECIFICA.md)
> 
> 📱 **Ejecución en Appetize.io:** [https://appetize.io/app/b_bwtrb7oou2e5asilzdeknfzwi4](https://appetize.io/app/b_bwtrb7oou2e5asilzdeknfzwi4)
> 🌐 **Portafolio en GitHub Pages:** [https://jesuuusart.github.io/Practicas_DMI_220772/](https://jesuuusart.github.io/Practicas_DMI_220772/)

---

## 1. Diagrama 1: Arquitectura General Tecnológica (Archify)

<div align="center">
  <a href="https://jesuuusart.github.io/Practicas_DMI_220772/Practica05/widgets_app/Docs/Architecture/widgets_app_general_architecture.html" title="Haz clic para abrir el Diagrama 1 interactivo en GitHub Pages">
    <img src="widgets_app_general_architecture.visual-check.2048x1320.dark.png" alt="Diagrama 1: Arquitectura General (Oscuro)" width="49%" />
    <img src="widgets_app_general_architecture.visual-check.2048x1320.light.png" alt="Diagrama 1: Arquitectura General (Claro)" width="49%" />
  </a>
  <p><em>👆 Haz clic en cualquiera de las imágenes para abrir el Diagrama 1 interactivo en GitHub Pages</em></p>
</div>

Representa las capas tecnológicas principales de la aplicación, el motor de navegación declarativa, el contenedor reactivo de estados con Riverpod, el sistema de diseño Material 3 y los recursos multimedia locales y remotos.

```mermaid
graph TD
    subgraph Core ["Flutter & Core Framework"]
        SDK["Flutter 3 SDK\nMaterial Design 3"]
        App["MainApp (ConsumerWidget)\nMaterialApp.router"]
        Scope["ProviderScope\n(Contenedor Global Riverpod)"]
    end

    subgraph Navigation ["Navegación Declarativa"]
        Router["GoRouter (appRouter)\n11 Rutas Registradas"]
    end

    subgraph StateTheme ["Gestión de Estado y Tema"]
        ThemeNotif["themeNotifierProvider\n(StateNotifierProvider)"]
        CounterProv["counterProvider\n(StateProvider)"]
        ThemeEngine["AppTheme\n(colorSchemeSeed, isDarkmode)"]
    end

    subgraph Presentation ["Capa de Presentación"]
        Catalog["HomeScreen (Catálogo)\nSideMenu (Drawer agrupado)"]
        Screens["10 Pantallas M3:\nButtons, Cards, Progress, Dialogs,\nAnimated, Controls, Tutorial, Scroll..."]
    end

    subgraph Resources ["Recursos y Animaciones"]
        AnimateDo["animate_do\nFadeIn, FadeInRight, SpinPerfect"]
        Assets["Assets Locales:\n1..3.png, jar-loading.gif"]
        Picsum["Picsum Photos API\nImágenes Remotas Asíncronas"]
    end

    Scope -->|Inyecta contexto reactivo| App
    SDK -->|Ejecuta ciclo de vida| App
    App -->|routerConfig| Router
    App -->|ref.watch| ThemeNotif
    ThemeNotif -->|Configura paleta y modo| ThemeEngine
    Router -->|Despacha rutas| Catalog
    Catalog -->|Navega| Screens
    Screens -.->|ref.watch / ref.read| StateTheme
    Screens -->|Utiliza efectos| AnimateDo
    Screens -->|AssetImage| Assets
    Screens -->|NetworkImage + FadeInImage| Picsum
```

### Características del Diagrama 1:
- **Gestión reactiva desacoplada:** El uso de `ProviderScope` en la cúspide del árbol permite que cualquier widget (`ConsumerWidget`) acceda al estado sin propagar `InheritedWidget` manualmente.
- **Tema Dinámico Global:** `ThemeNotifier` altera el `ColorSchemeSeed` y el brillo en tiempo de ejecución, actualizando `MaterialApp.router` instantáneamente.
- **Navegación Declarativa:** La pila de navegación es administrada centralmente por `GoRouter`, facilitando enlaces profundos y modularidad.

---

## 2. Diagrama 2: Arquitectura Específica de Pantallas, Rutas y Estados (Archify)

<div align="center">
  <a href="https://jesuuusart.github.io/Practicas_DMI_220772/Practica05/widgets_app/Docs/Architecture/widgets_app_specific_architecture.html" title="Haz clic para abrir el Diagrama 2 interactivo en GitHub Pages">
    <img src="widgets_app_specific_architecture.visual-check.2048x1320.dark.png" alt="Diagrama 2: Arquitectura Específica (Oscuro)" width="49%" />
    <img src="widgets_app_specific_architecture.visual-check.2048x1320.light.png" alt="Diagrama 2: Arquitectura Específica (Claro)" width="49%" />
  </a>
  <p><em>👆 Haz clic en cualquiera de las imágenes para abrir el Diagrama 2 interactivo en GitHub Pages</em></p>
</div>

Detalla la estructura de datos centralizada de navegación, el menú lateral con opciones agrupadas, cada una de las 11 pantallas implementadas y sus interacciones con los proveedores de estado de Riverpod.

```mermaid
graph TD
    subgraph DataCentral ["Estructura Centralizada"]
        MenuItems["appMenuItems\n(List<MenuItem> con 10 opciones)"]
    end

    subgraph NavigationUI ["Navegación de Entrada"]
        Home["HomeScreen\n(ListView.builder con _CustomListTile)"]
        Drawer["SideMenu (NavigationDrawer)\n- Main (0..2)\n- Divider\n- More options (3..9)"]
        RouterDef["GoRouter (appRouter)"]
    end

    subgraph ScreensCluster ["Catálogo de Pantallas Demostrativas"]
        S_Count["CounterScreen\n(/counter-river)"]
        S_Theme["ThemeChangerScreen\n(/theme-changer)"]
        S_Btn["ButtonsScreen\n(/buttons)"]
        S_Card["CardsScreen\n(/cards)"]
        S_Prog["ProgressScreen\n(/progress)"]
        S_Snack["SnackbarScreen\n(/snackbars)"]
        S_Anim["AnimatedScreen\n(/animated)"]
        S_UI["UiControlsScreen\n(/ui-controls)"]
        S_Tut["AppTutorialScreen\n(/tutorial)"]
        S_Inf["InfiniteScrollScreen\n(/infinite)"]
    end

    subgraph ProvidersLayer ["Proveedores Riverpod"]
        P_Count["counterProvider (StateProvider<int>)"]
        P_Theme["themeNotifierProvider (StateNotifierProvider)"]
        P_Colors["colorListProvider (Provider<List<Color>>)"]
    end

    MenuItems -->|Alimenta catálogo| Home
    MenuItems -->|Alimenta drawer| Drawer
    Home -->|context.push| RouterDef
    Drawer -->|context.push| RouterDef

    RouterDef --> S_Count
    RouterDef --> S_Theme
    RouterDef --> S_Btn
    RouterDef --> S_Card
    RouterDef --> S_Prog
    RouterDef --> S_Snack
    RouterDef --> S_Anim
    RouterDef --> S_UI
    RouterDef --> S_Tut
    RouterDef --> S_Inf

    S_Count <-->|ref.watch / ref.read| P_Count
    S_Count <-->|toggleDarkmode| P_Theme
    S_Theme <-->|ref.watch / ref.read| P_Theme
    S_Theme -->|ref.watch| P_Colors
```

### Características del Diagrama 2:
- **Centralización del Menú:** La lista `appMenuItems` sirve como única fuente de verdad para el `ListView` de `HomeScreen` y el `NavigationDrawer` de `SideMenu`.
- **Especialización de Widgets:** Pantallas complejas como `AppTutorialScreen` (`PageView` + `PageController`) e `InfiniteScrollScreen` (`ScrollController` + `RefreshIndicator`) encapsulan su lógica interna manteniendo contratos limpios.
- **Separación de Responsabilidades:** Componentes reutilizables como `CustomButton`, `_CardType1..4`, y `_Slide` facilitan el mantenimiento del código.
