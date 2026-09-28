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

## 2. Funcionalidad

| Regla | Comportamiento |
|:---|:---|
| Disparo | Un mensaje solo genera respuesta si su texto recortado termina en `?`. |
| Election | El resultado lo decide la app con pesos **40 % Sí / 40 % No / 20 % Tal vez**. |
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

## 3. Arquitectura por capas

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

## 4. Pruebas

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

## 5. Diagramas de arquitectura (Archify)

Los cuatro diagramas son interactivos, exportables a PNG/SVG y tienen modo claro/oscuro.

| Diagrama | Enlace |
|:---|:---|
| Arquitectura por capas | [Abrir](Docs/Architecture/yes_no_app_architecture.html) |
| Secuencia de una respuesta | [Abrir](Docs/Architecture/yes_no_app_sequence.html) |
| Ciclo de vida de un mensaje | [Abrir](Docs/Architecture/yes_no_app_lifecycle.html) |
| Estrategia de pruebas | [Abrir](Docs/Architecture/yes_no_app_tests.html) |

<a href="Docs/Architecture/yes_no_app_architecture.html">
  <img src="Docs/Architecture/yes_no_app_architecture.visual-check.2048x1320.dark.png"
       alt="Diagrama de arquitectura por capas de Yes No Maybe App" width="820" />
</a>

En línea: [yesno.wtf/Practica03/yes_no_app/Docs/Architecture/yes_no_app_architecture.html](https://jesuuusart.github.io/Practicas_DMI_220772/Practica03/yes_no_app/Docs/Architecture/yes_no_app_architecture.html)

---

## 6. Cómo ejecutarlo

```bash
flutter pub get
flutter analyze      # sin incidencias
flutter test         # 38 / 38
flutter run          # en un dispositivo o emulador
```

---

## 7. Conclusiones

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

## 8. Referencias

- [yesno.wtf](https://yesno.wtf) — API pública usada.
- [Documentación de Flutter](https://docs.flutter.dev/) y [Dio](https://pub.dev/packages/dio).
- Portafolio: [jesuuusart.github.io/Practicas_DMI_220772](https://jesuuusart.github.io/Practicas_DMI_220772/)
