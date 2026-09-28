# Práctica 03 — Yes No Maybe App

> App de chat en Flutter que responde **Sí**, **No** o **Tal vez** a cualquier pregunta
> que termine en `?`, consumiendo la API pública [yesno.wtf](https://yesno.wtf).

- **Estudiante:** Jesus Alejandro Artiaga Morales
- **Matrícula:** 220772 (10° A)
- **Materia:** Desarrollo Móvil Integral (DMI)
- **Docente:** M.T.I. Marco A. Ramírez Hernández
- **Periodo:** Septiembre – Diciembre 2026
---

<div align="center">

[![Portafolio GitHub Pages](https://img.shields.io/badge/🌐%20Portafolio%20en%20Vivo-GitHub%20Pages-06b6d4?style=for-the-badge&logo=github)](https://jesuuusart.github.io/Practicas_DMI_220772/)

  🔗 **[https://jesuuusart.github.io/Practicas_DMI_220772/](https://jesuuusart.github.io/Practicas_DMI_220772/)**
</div>

---

## 1. Objetivo de la práctica

Construir una aplicación móvil con Flutter que consuma un servicio web externo
manipulando la capa de datos, aplicando **arquitectura por capas**, **inyección de
dependencias** y **manejo de errores tipado**, y acompañándola con una batería de
pruebas automatizadas y diagramas de arquitectura documentados.

### Objetivos específicos

1. Separar la lógica en capas claras: `domain`, `infrastructure`, `presentation` y `config`.
2. Desacoplar la lógica de negocio de Flutter mediante **entidades** de dominio.
3. Manejar errores de red con **excepciones propias** en lugar de excepciones crudas.
4. Hacer la lógica **testeable** por inyección de `Dio`, `Random` y del reloj.
5. Cubrir la lógica con pruebas unitarias, de modelo y de widgets.

---

## 2. Tecnologías utilizadas

### Lenguajes y frameworks

| Tecnología | Versión | Para qué se usó en esta práctica |
|:---|:---|:---|
| **Flutter** | `3.47.2` (stable) | Framework de interfaz multiplataforma y tema **Material 3**. |
| **Dart** | `3.13.2` (SDK `^3.13.2`) | Lenguaje de la app: *null safety*, expresiones `switch`, `enum` y `copyWith`. |
| **yesno.wtf** | — | API REST pública que devuelve el texto (`yes`/`no`/`maybe`) y el GIF. |

### Paquetes de `pubspec.yaml`

| Paquete | Versión | Función dentro del proyecto |
|:---|:---|:---|
| [`provider`](https://pub.dev/packages/provider) | `^6.1.5+1` | `ChangeNotifier` + `ChangeNotifierProvider`: el estado del chat vive fuera de los widgets. |
| [`dio`](https://pub.dev/packages/dio) | `^5.11.1` | Cliente HTTP con timeouts configurables y `DioException` tipadas por causa. |
| [`cupertino_icons`](https://pub.dev/packages/cupertino_icons) | `^1.0.8` | Set de iconos con estilo iOS. |
| [`flutter_lints`](https://pub.dev/packages/flutter_lints) | `^6.0.0` | Reglas activadas en `analysis_options.yaml` para que `flutter analyze` quede limpio. |
| [`flutter_launcher_icons`](https://pub.dev/packages/flutter_launcher_icons) | `^0.14.4` | Genera el icono de la app en todas las densidades desde `assets/images/me.jpg`. |
| `integration_test` | `sdk: flutter` | Las 2 pruebas end-to-end que necesitan un emulador real. |

### Herramientas

| Herramienta | Uso |
|:---|:---|
| **Android SDK + Emulador** (AVD `Pixel_10`) | Ejecutar la app en un dispositivo virtual y tomar la evidencia. |
| **Visual Studio Code / Android Studio** | Edición, depuración y hot reload. |
| **Archify** | Generación de los 4 diagramas de arquitectura, secuencia, ciclo de vida y pruebas. |
| **Git + GitHub Pages** | Versionado del código y publicación del portafolio. |

### Conceptos y patrones aplicados

| Concepto | Dónde se aplica |
|:---|:---|
| Arquitectura por capas | `domain` → `infrastructure` → `presentation` → `config` |
| Inyección de dependencias por constructor | `Dio`, `Random`, `AnswerWeights` y el reloj entran por el constructor. |
| Gestión de estado declarativa | `ChangeNotifier` + `context.watch<ChatProvider>()` |
| Composición sobre herencia | `MyApp` arma el `MultiProvider`; las pantallas solo consumen estado. |
| Traducción de errores en la frontera | Todo `DioException` / `FormatException` sale como `YesNoException`. |
| Serialización de peticiones | Cadena de `Future` para que dos respuestas nunca se intercalen. |
| Pruebas con dobles | `Dio` y `Random` falsos + reloj congelado: 38 tests sin red. |

---

## 3. Funcionalidad

| Regla | Comportamiento |
|:---|:---|
| Disparo | Un mensaje solo genera respuesta si su texto recortado termina en `?`. |
| Elección | El resultado lo decide la app con pesos **40 % Sí / 40 % No / 20 % Tal vez**. |
| Texto y GIF | La API se consulta con `?force=<respuesta>` para que el texto y la imagen coincidan. |
| Cola | Las respuestas se encadenan con un `Future` para que nunca se intercalen. |
| Scroll | Tras cada mensaje el chat se desplaza al final con una animación de 300 ms. |
| Hora | Todos los mensajes usan el **mismo reloj inyectable**. |
| Vacío | Un mensaje solo con espacios se descarta sin tocar la red. |
| Errores | Todo fallo se traduce a un mensaje legible en la burbuja de la app. |

### Integración con la API

```
GET https://yesno.wtf/api?force=yes|no|maybe
```

Timeouts de `10 s` en conexión, envío y recepción. La app **no delega el resultado**
en la API: primero sortea con `AnswerWeights.pickAnswer()` y luego pide esa respuesta
concreta para obtener su imagen. De ese modo el texto y el GIF nunca se contradicen.

Dependencias principales: `provider ^6.1.5+1` y `dio ^5.11.1`.

---

## 4. Arquitectura por capas

```
Practica03/yes_no_app/lib/
├── main.dart                                  Composition root (ChangeNotifierProvider)
├── config/
│   ├── helpers/
│   │   ├── get_yes_no_answer.dart             Cliente HTTP, pesos y traducción de errores
│   │   └── format_time_of_day.dart            Formato de la hora de envío
│   └── theme/app_theme.dart                   Tema Material 3
├── domain/entities/message.dart               Entidad pura (sin dependencias de Flutter)
├── infrastructure/models/yes_no_model.dart    DTO + validación del JSON + traducción
└── presentation/
    ├── providers/chat_provider.dart           Estado del chat, cola y scroll
    ├── screens/chat/chat_screen.dart          Pantalla principal
    └── widgets/                               Burbujas, campo de texto y etiqueta de hora
```

La dependencia apunta siempre **hacia dentro**: `presentation → infrastructure → domain`.
`domain` no importa nada de Flutter, por lo que se prueba sin widgets.

---

## 5. Pruebas

| Archivo | Tipo | Casos |
|:---|:---|---:|
| `test/answer_weights_test.dart` | Unitarias — `AnswerWeights` | 9 |
| `test/chat_provider_test.dart` | Unitarias — `ChatProvider` con dobles | 9 |
| `test/yes_no_model_test.dart` | Unitarias — modelo y formato | 10 |
| `test/format_time_of_day_test.dart` | Unitarias — formato de hora | 5 |
| `test/widget_test.dart` | Widgets — `pumpWidget` | 5 |
| **Subtotal `flutter test`** | | **38 / 38** |
| `integration_test/chat_flow_test.dart` | Integración (requiere dispositivo) | 2 |

- `flutter analyze` → **sin incidencias**.
- Evidencia completa: [`Docs/Testing/test_results.txt`](Docs/Testing/test_results.txt).
- Las 2 pruebas de `integration_test/` **no** las cuenta `flutter test`: necesitan un
  dispositivo o emulador real.

### Qué hace testeable al código

`ChatProvider` recibe `GetYesNoAnswer` y un `DateTime Function() now`; a su vez,
`GetYesNoAnswer` recibe `Dio`, `Random` y los `AnswerWeights`. Gracias a esa cadena de
inyección, las 38 pruebas corren en el host **sin red y sin esperas reales**: el doble
de `Dio` devuelve un `Response` fijo y el reloj congelado hace determinista la hora.

---

## 6. Diagramas de arquitectura (Archify)

Los cuatro diagramas son interactivos, exportables a PNG/SVG y tienen modo claro/oscuro.

| Diagrama | Enlace |
|:---|:---|
| Arquitectura por capas | [Abrir](Docs/Architecture/yes_no_app_architecture.visual-check.1440x900.dark.png) |
| Secuencia de una respuesta | [Abrir](Docs/Architecture/yes_no_app_sequence.visual-check.1440x900.dark.png) |
| Ciclo de vida de un mensaje | [Abrir](Docs/Architecture/yes_no_app_lifecycle.visual-check.1440x900.dark.png) |
| Estrategia de pruebas | [Abrir](Docs/Architecture/yes_no_app_tests.visual-check.1440x900.dark.png) |

<a href="https://jesuuusart.github.io/Practicas_DMI_220772/Practica03/yes_no_app/Docs/Architecture/yes_no_app_architecture.html">
  <img src="Docs/Architecture/yes_no_app_architecture.visual-check.2048x1320.dark.png"
       alt="Diagrama de arquitectura por capas de Yes No Maybe App" width="820" />
</a>

En línea: [yesno.wtf/Practica03/yes_no_app/Docs/Architecture/yes_no_app_architecture.html](https://jesuuusart.github.io/Practicas_DMI_220772/Practica03/yes_no_app/Docs/Architecture/yes_no_app_architecture.html)

---

## 7. Requisitos y cómo ejecutarlo

### Requisitos previos

- **Flutter SDK** `3.47.2` o superior (`flutter --version` para verificarlo).
- **Android SDK** con un emulador creado, o un dispositivo Android con
  depuración por USB activada.
- Conexión a internet (solo para consumir la API y para `flutter pub get`).

### Comandos

```bash
flutter pub get
flutter analyze      # sin incidencias
flutter test         # 38 / 38
flutter run          # en un dispositivo o emulador
```

### Pruebas de integración en emulador

Las 2 pruebas de `integration_test/` usan la app real contra la API real,
por lo que necesitan un destino conectado:

```bash
flutter devices                     # confirmar el emulador o dispositivo
flutter test integration_test/chat_flow_test.dart -d <device_id>
```

También se incluye `tool/start_emulator.ps1` para levantar el AVD y abrir
`adb` listo para las pruebas.

---

## 8. Cosas aprendidas

### Sobre Flutter y Dart

1. **Dart moderno**: las expresiones `switch` y el *pattern matching*
   (`on DioException catch`, `switch (e.type) { ... }`) permitem escribir el
   manejo de errores de forma exhaustiva y legible, sin `if/else` anidados.
2. **Null safety a la fuerza**: `String? imageUrl` y `DateTime? sentAt` obligan
   a decidir explícitamente qué hacer cuando no hay dato, que es justamente lo
   que evita los `null` en la UI.
3. **StatelessWidget no significa sin estado**: el estado puede vivir en un
   provider externo; el widget solo se redibuja con `context.watch`.
4. **`notifyListeners()` + `dispose()`**: `ChangeNotifier` avisa a la UI, pero
   hay que liberar el `ScrollController` a mano para no dejar fugas de memoria.
5. **Animación del scroll**: `animateTo` con `Curves.easeOut` y una espera
   previa de 100 ms hace que el chat baje al último mensaje de forma fluida en
   lugar de saltar.

### Sobre arquitectura y calidad de código

6. **Las capas existen para poder testear**: como `domain` no importa nada de
   Flutter, la entidad `Message` se prueba sin levantar un solo widget.
7. **Inyectar el reloj es lo que hace deterministas las pruebas**: si la hora
   saliera de `DateTime.now()` interno, cada test sería intermitente.
8. **Un error de red no es un error de negocio**: envolver `DioException` en
   `YesNoException` mantiene el cliente HTTP fuera de la capa de presentación.
9. **Validar el JSON en el modelo**: `YesNoModel.fromJsonMap` lanza
   `FormatException` si `answer` no es texto, en lugar de dejar que reviente
   más lejos con un mensaje incomprensible.
10. **La condición de carrera era real**: dos preguntas seguidas sí intercalaban
    las respuestas; la cola de `Future` en `herReply()` lo resolvió de raíz.

### Sobre pruebas y herramientas

11. **Un doble de `Dio` evita la red**: basta un `Response` fijo para probar la
    capa completa; combinando eso con un `Random` sembrado, los 38 tests corren
    en segundos y sin internet.
12. **`flutter test` y `integration_test` son cosas distintas**: las primeras
    corren en el host con fakes; las de integración usan la app real y por eso
    necesitan un emulador.
13. **`flutter analyze` es parte del entregable**: el código sin lints es código
    documentado por el analizador.
14. **Un diagrama que no viene del código miente**: los diagramas se generaron
    verificando referencias contra los archivos reales del proyecto.

---

## 9. Conclusiones

1. La **inyección de dependencias** fue lo que hizo posible testear: sin `Dio`, `Random`
   y reloj inyectables, las pruebas dependerían de red y de tiempo real.
2. Traducir los `DioException` a un único `YesNoException` evitó que la capa de
   presentación conociera el cliente HTTP.
3. La **cola con `Future`** evitó una condición de carrera real: dos preguntas seguidas
   ya no intercalan sus respuestas.
4. Separar la entidad `Message` del DTO `YesNoModel` permitió probar el dominio sin
   levantar Flutter.
5. La evidencia ejecutable (`analyze` + 38 pruebas) y los diagramas complementan la
   memoria del proyecto: documentan lo que el código **efectivamente** hace.

---

## 10. Referencias

- [yesno.wtf](https://yesno.wtf) — API pública usada.
- [Documentación de Flutter](https://docs.flutter.dev/) y [Dio](https://pub.dev/packages/dio).
- Portafolio: [jesuuusart.github.io/Practicas_DMI_220772](https://jesuuusart.github.io/Practicas_DMI_220772/)
