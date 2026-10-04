# Fuentes locales

## RockSalt-Regular.ttf

| Dato | Valor |
|---|---|
| Familia | `RockSalt` (Rock Salt Regular) |
| Formato | TrueType (`.ttf`) |
| Tamaño | 119 328 bytes |
| Versión | 1.001 |
| Licencia | Apache License 2.0 |
| Origen | `@expo-google-fonts/rock-salt` (copia de Google Fonts) |

Se empaqueta como asset local en lugar de usar el paquete `google_fonts`, para que
la aplicación no dependa de una descarga en tiempo de ejecución y funcione sin internet.

### Cómo usarla

1. El archivo vive en `assets/fonts/RockSalt-Regular.ttf`.
2. La familia se declara en `pubspec.yaml`:

   ```yaml
   flutter:
     fonts:
       - family: RockSalt
         fonts:
           - asset: assets/fonts/RockSalt-Regular.ttf
   ```

3. Se aplica en el código con `fontFamily`:

   ```dart
   Text(
     '$clickCounter',
     style: TextStyle(
       fontFamily: 'RockSalt',
       fontSize: 160,
       fontWeight: FontWeight.w100,
       color: _getCounterColor(clickCounter),
     ),
   )
   ```
