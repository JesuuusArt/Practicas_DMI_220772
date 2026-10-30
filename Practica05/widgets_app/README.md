# Práctica 05: Widgets App — Catálogo de Material Design 3

<div align="center">
  <img src="../../logoTI.jpeg" alt="Logo TI" width="380" />

  ## Desarrollo Móvil Integral — 10° Cuatrimestre
  ### Ingeniería en Desarrollo y Gestión de Software

  **Estudiante:** Jesus Alejandro Artiaga Morales (Matrícula: 220772)  
  **Docente:** M.T.I. Marco A. Ramírez Hernández  
  **Periodo:** Septiembre - Diciembre 2026  
  **Valor:** 40 Firmas | **Estatus:** 🟢 Concluida al 100%  

  [![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
  [![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
  [![Riverpod](https://img.shields.io/badge/Riverpod-2.6-blueviolet?style=for-the-badge)](https://riverpod.dev)
  [![GoRouter](https://img.shields.io/badge/GoRouter-18.0-0ea5e9?style=for-the-badge)](https://pub.dev/packages/go_router)
  [![Material 3](https://img.shields.io/badge/Material%20Design-3-green?style=for-the-badge&logo=materialdesign)](https://m3.material.io)
  [![GitHub Pages](https://img.shields.io/badge/🌐%20Diagramas%20en%20Vivo-GitHub%20Pages-06b6d4?style=for-the-badge&logo=github)](https://jesuuusart.github.io/Practicas_DMI_220772/)
</div>

---

## 📖 Descripción del Proyecto

**Widgets App** es una aplicación móvil desarrollada en Flutter y Dart diseñada para explorar, implementar y documentar componentes visuales e interactivos de **Material Design 3**. La aplicación organiza un catálogo integral de interfaces mediante un sistema de navegación declarativa con **GoRouter** y una arquitectura de estado reactivo impulsada por **Flutter Riverpod**.

La aplicación incorpora:
- **Botones interactivos y personalizados:** Variantes estándar de Material 3 y componentes construidos con `Material` e `InkWell`.
- **Tarjetas multi-estilo:** Elevación progresiva, bordes perimetrales, superficies de color y portadas de imagen remota.
- **Indicadores de progreso:** Progreso indeterminado y flujos continuos síncronos mediante `Stream.periodic` y `StreamBuilder`.
- **Notificaciones y diálogos modales:** `SnackBar` con acciones personalizadas, diálogos de confirmación (`AlertDialog`) y créditos de licencias (`showAboutDialog`).
- **Animaciones implícitas y compuestas:** `AnimatedContainer` con propiedades físicas aleatorias y efectos de aparición con `animate_do`.
- **Controles de selección y formularios:** Interruptores (`SwitchListTile`), radio botones (`RadioListTile`), casillas de verificación (`CheckboxListTile`) y listas expandibles (`ExpansionTile`).
- **Tutorial introductorio:** Diapositivas horizontales con `PageView`, `PageController`, imágenes locales y botón con animación `FadeInRight`.
- **Desplazamiento infinito y gestos:** Carga progresiva asíncrona mediante `ScrollController`, `FadeInImage` con GIF de carga y Pull to Refresh con `RefreshIndicator`.
- **Gestión global de temas:** Conmutación dinámica de paletas de colores y modo oscuro/claro en tiempo real con `StateNotifierProvider` y `ConsumerWidget`.

<div align="center">
  <br />
  <img src="Docs/Architecture/screenshot_emulator.png" alt="Widgets App en Emulador Android" width="280" style="border-radius: 18px; box-shadow: 0 10px 30px rgba(0,0,0,0.5);" />
  <p><em>Evidencia de ejecución en vivo: Catálogo completo de Widgets App en Android Emulator</em></p>
  <br />
</div>

---

## 🎯 Objetivo de la Práctica

Diseñar y desarrollar una aplicación móvil multiplataforma mediante Flutter y Dart, implementando widgets de Material Design 3, navegación declarativa con GoRouter, administración del estado con Riverpod y animaciones interactivas, con la finalidad de fortalecer las competencias en el diseño de interfaces gráficas, modularización del código, interacción con el usuario, documentación de arquitectura y distribución de aplicaciones móviles.

---

## 📋 Matriz de Cumplimiento de Actividades (1 a 20)

| No. | Actividad | Estatus | Evidencia / Implementación |
|:---:|:---|:---:|:---|
| **1** | **Creación y configuración del proyecto** | 🟢 Concluida | Proyecto `widgets_app` con dependencias `go_router`, `flutter_riverpod`, `animate_do` y registro de carpeta `assets/images/` en [pubspec.yaml](pubspec.yaml). |
| **2** | **Organización modular de la arquitectura** | 🟢 Concluida | Separación estricta de responsabilidades en `lib/config/` (menu, router, theme) y `lib/presentation/` (providers, screen, widgets). |
| **3** | **Configuración de Material Design 3** | 🟢 Concluida | Clase inmutable [AppTheme](lib/config/theme/app_theme.dart) con `useMaterial3: true`, paleta de 9 colores, soporte claro/oscuro y método `copyWith()`. |
| **4** | **Navegación declarativa (GoRouter)** | 🟢 Concluida | Configuración de 11 rutas limpias en [app_router.dart](lib/config/router/app_router.dart) y `MaterialApp.router` en `main.dart`. |
| **5** | **Construcción de la pantalla principal** | 🟢 Concluida | [HomeScreen](lib/presentation/screen/home/home_screen.dart) con `Scaffold`, `AppBar`, `ListView.builder` y `_CustomListTile` consumiendo `appMenuItems`. |
| **6** | **Implementación del menú lateral** | 🟢 Concluida | [SideMenu](lib/presentation/widgets/side_menu.dart) con `NavigationDrawer`, opciones agrupadas (`sublist(0, 3)` y `sublist(3)`), divisores y notch safe-area. |
| **7** | **Exploración de widgets de botones** | 🟢 Concluida | [ButtonsScreen](lib/presentation/screen/buttons/buttons_screen.dart) con `ElevatedButton`, `FilledButton`, `OutlinedButton`, `TextButton`, `IconButton`, `FloatingActionButton` y botón personalizado con `Material` e `InkWell`. |
| **8** | **Diseño de tarjetas (Card)** | 🟢 Concluida | [CardsScreen](lib/presentation/screen/cards/cards_screen.dart) con 4 variantes: elevaciones (0 a 5), bordes (`outline`), superficie (`surfaceContainerHighest`) e imágenes Picsum. |
| **9** | **Indicadores de progreso** | 🟢 Concluida | [ProgressScreen](lib/presentation/screen/progress/progress_screen.dart) con `CircularProgressIndicator` indeterminado y circular/lineal controlado por `Stream.periodic` y `StreamBuilder`. |
| **10** | **Gestión de notificaciones y cuadros de diálogo** | 🟢 Concluida | [SnackbarScreen](lib/presentation/screen/snackbar/snackbar_screen.dart) con `SnackBar`, `ScaffoldMessenger`, `AlertDialog` y `showAboutDialog`. |
| **11** | **Implementación de animaciones implícitas** | 🟢 Concluida | [AnimatedScreen](lib/presentation/screen/animated/animated_screen.dart) con `AnimatedContainer`, `StatefulWidget`, valores aleatorios (`Random`) y curva `Curves.elasticOut`. |
| **12** | **Construcción de controles interactivos** | 🟢 Concluida | [UiControlsScreen](lib/presentation/screen/ui_controls/ui_controls_screen.dart) con `SwitchListTile`, `ExpansionTile`, `RadioListTile` (`enum Transportation`) y `CheckboxListTile`. |
| **13** | **Desarrollo de un tutorial introductorio** | 🟢 Concluida | [AppTutorialScreen](lib/presentation/screen/app_tutorial/app_tutorial_screen.dart) con `PageView`, `PageController`, imágenes locales (`1.png`, `2.png`, `3.png`) y botón con `FadeInRight`. |
| **14** | **Implementación de desplazamiento infinito** | 🟢 Concluida | [InfiniteScrollScreen](lib/presentation/screen/infinite_scroll/infinite_scroll_screen.dart) con `ScrollController`, carga progresiva asíncrona y `FadeInImage` con `jar-loading.gif`. |
| **15** | **Actualización de contenido mediante gestos** | 🟢 Concluida | Pull to Refresh integrado mediante `RefreshIndicator` y animación de recarga con `SpinPerfect` en el FAB. |
| **16** | **Administración del estado con Riverpod** | 🟢 Concluida | Envoltorio raíz con `ProviderScope` en [main.dart](lib/main.dart) y [CounterScreen](lib/presentation/screen/counter/counter_screen.dart) implementada con `ConsumerWidget`, `ref.watch()` y `ref.read()`. |
| **17** | **Personalización dinámica del tema** | 🟢 Concluida | [ThemeNotifier](lib/presentation/providers/theme_provider.dart) con `StateNotifierProvider`, selección de colores por `RadioListTile` y modo oscuro reflejado globalmente. |
| **18** | **Pruebas de integración y funcionamiento** | 🟢 Concluida | Pruebas de widgets verificadas con `flutter test` aprobadas al 100%. |
| **19** | **Documentación de arquitectura mediante Archify** | 🟢 Concluida | Elaboración de 2 diagramas interactivos OpenCode Archify (General y Específico) en formato HTML y JSON. |
| **20** | **Publicación y documentación del proyecto** | 🟢 Concluida | Documentación exhaustiva en `README.md`, integración en repositorio de GitHub, visualización en GitHub Pages y compilación release. |

---

## 🏛️ Diagramas de Arquitectura (Archify)

Se elaboraron dos diagramas interactivos bajo el estándar de **Archify** disponibles en la carpeta [Docs/Architecture/](Docs/Architecture/):

1. **🏛️ Diagrama 1: Arquitectura General Tecnológica**
   - 🌐 [Abrir Diagrama Interactivo (HTML)](Docs/Architecture/widgets_app_general_architecture.html)
   - 📄 [Especificación Técnica JSON](Docs/Architecture/widgets_app_general.architecture.json)
   - 📖 [Documento Explicativo](Docs/Architecture/DIAGRAMA_1_ARQUITECTURA_GENERAL.md)

2. **🏗️ Diagrama 2: Arquitectura Específica de Pantallas, Rutas y Estados**
   - 🌐 [Abrir Diagrama Interactivo (HTML)](Docs/Architecture/widgets_app_specific_architecture.html)
   - 📄 [Especificación Técnica JSON](Docs/Architecture/widgets_app_specific.architecture.json)
   - 📖 [Documento Explicativo](Docs/Architecture/DIAGRAMA_2_ARQUITECTURA_ESPECIFICA.md)

---

## 📂 Estructura de Directorios del Proyecto

```text
widgets_app/
├── assets/
│   └── images/
│       ├── 1.png               # Diapositiva 1 del tutorial
│       ├── 2.png               # Diapositiva 2 del tutorial
│       ├── 3.png               # Diapositiva 3 del tutorial
│       └── jar-loading.gif     # Placeholder animado de carga
├── Docs/
│   └── Architecture/
│       ├── DIAGRAMAS_ARQUITECTURA.md
│       ├── DIAGRAMA_1_ARQUITECTURA_GENERAL.md
│       ├── DIAGRAMA_2_ARQUITECTURA_ESPECIFICA.md
│       ├── widgets_app_general.architecture.json
│       ├── widgets_app_general_architecture.html
│       ├── widgets_app_specific.architecture.json
│       └── widgets_app_specific_architecture.html
├── lib/
│   ├── config/
│   │   ├── menu/
│   │   │   └── menu_items.dart         # Catálogo centralizado (10 elementos)
│   │   ├── router/
│   │   │   └── app_router.dart         # GoRouter con 11 rutas
│   │   └── theme/
│   │       └── app_theme.dart          # Motor de tema Material 3
│   ├── presentation/
│   │   ├── providers/
│   │   │   ├── counter_provider.dart   # StateProvider<int>
│   │   │   └── theme_provider.dart     # StateNotifierProvider<ThemeNotifier, AppTheme>
│   │   ├── screen/
│   │   │   ├── animated/               # AnimatedScreen
│   │   │   ├── app_tutorial/           # AppTutorialScreen (PageView)
│   │   │   ├── buttons/                # ButtonsScreen (M3 + Custom)
│   │   │   ├── cards/                  # CardsScreen (4 estilos)
│   │   │   ├── counter/                # CounterScreen (Riverpod)
│   │   │   ├── home/                   # HomeScreen (Catálogo)
│   │   │   ├── infinite_scroll/        # InfiniteScrollScreen (Pull to refresh)
│   │   │   ├── progress/               # ProgressScreen (StreamBuilder)
│   │   │   ├── screens.dart            # Archivo barril de exportación
│   │   │   ├── snackbar/               # SnackbarScreen (Diálogos)
│   │   │   ├── theme_changer/          # ThemeChangerScreen (RadioListTile)
│   │   │   └── ui_controls/            # UiControlsScreen (Tiles y Enum)
│   │   └── widgets/
│   │       └── side_menu.dart          # NavigationDrawer agrupado
│   └── main.dart                       # ProviderScope y MainApp reactiva
├── test/
│   └── widget_test.dart                # Smoke tests con ProviderScope
└── pubspec.yaml                        # Dependencias y recursos registrados
```

---

## 🚀 Guía de Instalación y Ejecución

### Requisitos Previos:
- Flutter SDK (versión 3.13.0 o superior).
- Dart SDK compatible.
- Dispositivo físico o emulador Android/iOS configurado.

### Pasos de ejecución:

1. **Clonar el repositorio y ubicarse en el proyecto:**
   ```bash
   git checkout Practica05
   cd Practica05/widgets_app
   ```

2. **Descargar las dependencias:**
   ```bash
   flutter pub get
   ```

3. **Ejecutar la suite de pruebas unitarias y de widgets:**
   ```bash
   flutter test
   ```

4. **Ejecutar en modo de desarrollo:**
   ```bash
   flutter run
   ```

5. **Compilar el paquete release APK para demostración y despliegue:**
   ```bash
   flutter build apk --release
   ```
   *El instalador generado se ubicará en `build/app/outputs/flutter-apk/app-release.apk` listo para subir a [Appetize.io](https://appetize.io).*

---

## 📱 Demostración en Appetize.io

Para evaluar la aplicación en un emulador virtual streaming en la nube vía WebRTC/HTML5:
- 📱 **Enlace de ejecución en Appetize.io:** *(Subir el APK generado `app-release.apk` a Appetize.io y copiar el URL aquí)*
- 🌐 **Visualización de portafolio y diagramas:** [https://jesuuusart.github.io/Practicas_DMI_220772/](https://jesuuusart.github.io/Practicas_DMI_220772/)
