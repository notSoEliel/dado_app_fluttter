# Aplicación de Dado Flutter - "Dado App"

Una sencilla pero atractiva aplicación de juego de dados desarrollada con Flutter, que demuestra el uso de animaciones, gestión de estado y diseño de interfaz de usuario con el estilo Cupertino (iOS).

## Descripción del Proyecto

Esta aplicación permite a los usuarios "lanzar" un dado virtual. El resultado se muestra numéricamente y con una imagen del dado correspondiente. Si el usuario saca un 6, se considera una "victoria" y se activa una animación de confeti y un cambio de fondo especial.

El objetivo principal es mostrar cómo integrar diferentes elementos de Flutter para crear una experiencia de usuario interactiva y visualmente agradable.

## Características Principales

*   **Lanzamiento de Dado Aleatorio**: Simula el lanzamiento de un dado de seis caras.
*   **Feedback Visual**: Muestra el resultado con un número grande y una imagen SVG del dado.
*   **Animación de Sacudida**: El dado realiza una animación de "sacudida" antes de mostrar el resultado.
*   **Animación de Fondo**: El fondo de la pantalla cambia a un degradado dorado al obtener un 6, con una transición suave.
*   **Animación de Confeti**: Al sacar un 6, una explosión de confeti celebra la victoria.
*   **Interfaz de Usuario Estilo Cupertino**: Utiliza widgets de Cupertino para una apariencia nativa de iOS.
*   **Gestión de Estado**: Maneja el estado de la aplicación (resultado del dado, si se está lanzando, si se ganó) de forma eficiente.

## Decisiones de Diseño y Librerías

*   **Flutter y Dart**: El framework y lenguaje principal para el desarrollo multiplataforma.
*   **Cupertino Widgets (`package:flutter/cupertino.dart`)**: Se eligieron para dar a la aplicación un aspecto y sensación similar a las aplicaciones nativas de iOS. Esto incluye `CupertinoPageScaffold`, `CupertinoButton`, `CupertinoActivityIndicator`, y el uso del `CupertinoTheme`.
*   **SVG Images (`package:flutter_svg`)**: Las imágenes de los dados se utilizan en formato SVG para asegurar que se vean nítidas en cualquier resolución de pantalla. Esta librería permite renderizar archivos SVG en Flutter.
*   **Confetti Animation (`package:confetti`)**: Para la animación de celebración al ganar. Esta librería proporciona una forma sencilla de implementar efectos de confeti personalizables.
*   **Gestión de Estado con `StatefulWidget`**: Para una aplicación de esta escala, el manejo de estado incorporado de Flutter con `StatefulWidget` y `setState` es suficiente y adecuado. El estado incluye el resultado del dado, mensajes al usuario, y banderas para controlar animaciones.
*   **Animaciones Nativas de Flutter**:
    *   `AnimationController` y `TweenSequence`: Utilizados para la animación de sacudida del dado. `TweenSequence` permite definir una serie de "pasos" en la animación (pequeñas rotaciones en este caso).
    *   `RotationTransition`: Aplica la animación de rotación al widget del dado.
    *   `AnimatedSwitcher`: Se usa para animar la transición del fondo de la pantalla entre el estado normal y el estado de "victoria". Proporciona un fundido suave entre los dos `Container` que representan los fondos.

## Estructura del Proyecto y Archivos Importantes

```
dado_app_fluttter/
├── android/         # Código específico de Android
├── assets/
│   └── images/      # Imágenes SVG de los dados (dice_1.svg a dice_6.svg)
├── ios/             # Código específico de iOS
├── lib/
│   ├── main.dart    # Punto de entrada de la aplicación, configuración inicial, definición de AppColors y tema.
│   └── screens/
│       └── pantalla_dado.dart # Widget principal de la pantalla del juego, contiene toda la lógica y UI.
├── macos/           # Código específico de macOS
├── test/            # Pruebas unitarias y de widgets
├── web/             # Código específico para web (si está habilitado)
├── windows/         # Código específico de Windows
├── pubspec.yaml     # Archivo de configuración del proyecto, dependencias y assets.
└── README.md        # Este archivo.
```

*   **`lib/main.dart`**: 
    *   Define la clase `MyApp` que inicializa la `CupertinoApp`.
    *   Establece el tema global de Cupertino.
    *   Define la clase estática `AppColors` que centraliza todos los colores utilizados en la aplicación para facilitar su mantenimiento y consistencia.
*   **`lib/screens/pantalla_dado.dart`**: 
    *   Contiene el `StatefulWidget` `PantallaDado` y su `State` `_EstadoPantallaDado`.
    *   Maneja toda la lógica del juego: lanzamiento del dado, generación de números aleatorios, actualización de mensajes.
    *   Implementa todas las animaciones: sacudida del dado, transición de fondo y confeti.
    *   Construye la interfaz de usuario utilizando widgets de Cupertino y los assets SVG.
*   **`assets/images/`**: Carpeta que contiene las imágenes SVG para cada cara del dado (ej. `dice_1.svg`, `dice_2.svg`, ..., `dice_6.svg`). Es crucial que estos archivos existan y estén correctamente referenciados en `pubspec.yaml`.
*   **`pubspec.yaml`**: 
    *   Declara las dependencias del proyecto, como `flutter_svg` y `confetti`.
    *   Define la sección `flutter -> assets` para incluir la carpeta `assets/images/` de modo que las imágenes SVG puedan ser cargadas por la aplicación.

## Dependencias

Las principales dependencias utilizadas en este proyecto (revisar `pubspec.yaml` para versiones exactas) son:

*   `cupertino_icons`: Para los iconos de estilo iOS.
*   `flutter_svg`: Para renderizar imágenes SVG.
*   `confetti`: Para la animación de confeti.

Para instalar las dependencias, ejecuta:
```bash
flutter pub get
```

## Cómo Ejecutar el Proyecto

1.  Asegúrate de tener Flutter SDK instalado y configurado.
2.  Clona este repositorio (si aplica) o ten los archivos del proyecto.
3.  Navega al directorio raíz del proyecto en tu terminal.
4.  Ejecuta `flutter pub get` para instalar las dependencias.
5.  Conecta un dispositivo o inicia un emulador/simulador.
6.  Ejecuta `flutter run`.

## Posibles Mejoras Futuras

*   Añadir efectos de sonido al lanzar el dado y al ganar.
*   Implementar un historial de lanzamientos.
*   Permitir al usuario elegir el número de dados.
*   Hapticas al tirar el dado y al ganar
*   Mejorar la experiencia de usuario con un diseño más atractivo.