/*
  * Eliel García, 8-990-1192
  * Angélica Rodríguez, 2-751-41
  * Ericka Atencio, 8-1018-73
*/

import 'package:flutter/cupertino.dart';
import 'screens/pantalla_dado.dart';

// Define la paleta de colores centralizada para la aplicación.
class AppColors {
  // Fondos
  static const Color neutralBackground = Color(0xFFDCDCDC);
  static const Color winningBackgroundGoldStart = Color(0xFFBF953F);
  static const Color winningBackgroundGoldCenter = Color(0xFFFCF6BA);
  static const Color winningBackgroundGoldEnd = Color(0xFFB38728);

  // Textos
  static const Color textDefault = Color(0xFF333333);
  static const Color textOnGoldBackground = Color(0xFF4A3B2A);
  static const Color textLight = Color(0xFFFAFAFA);
  static const Color diceNumberGold = Color(0xFFB38728);

  // Botones y UI
  static const Color buttonPrimary = Color(0xFF6D5A3A);
  static const Color buttonDisabled = Color(0xFFBDBDBD);
  static const Color activityIndicator = Color(0xFFFAFAFA);

  // Confeti
  static const List<Color> confettiColors = [
    AppColors.winningBackgroundGoldStart,
    AppColors.winningBackgroundGoldCenter,
    CupertinoColors.white,
    AppColors.winningBackgroundGoldEnd,
  ];
}

// Punto de entrada principal de la aplicación.
void main() {
  runApp(const AplicacionDado());
}

// Widget raíz de la aplicación.
class AplicacionDado extends StatelessWidget {
  const AplicacionDado({super.key});

  @override
  Widget build(BuildContext context) {
    // Estilo de texto base para la aplicación.
    const TextStyle baseTextStyle = TextStyle(
      fontFamily: '.SF Pro Display', // Fuente estándar de Cupertino
      color: AppColors.textDefault,
      letterSpacing: -0.41,
    );

    return CupertinoApp(
      title: 'Lanzador de Dados Deluxe',
      debugShowCheckedModeBanner: false, // Oculta la etiqueta "debug"

      // Tema global de Cupertino que define la apariencia visual por defecto.
      theme: CupertinoThemeData(
        brightness: Brightness.light, // Tema claro.
        scaffoldBackgroundColor:
            AppColors.neutralBackground, // Color de fondo para las pantallas.
        primaryColor: AppColors
            .buttonPrimary, // Color de acento principal para widgets interactivos.
        primaryContrastingColor: AppColors
            .textLight, // Color para texto/iconos sobre `primaryColor`.

        // Estilos de texto por defecto.
        textTheme: CupertinoTextThemeData(
          textStyle: baseTextStyle, // Estilo base para la mayoría del texto.
          actionTextStyle: baseTextStyle.copyWith(
            color: AppColors.buttonPrimary,
            fontSize: 17,
            letterSpacing: -0.24,
          ),
          navLargeTitleTextStyle: baseTextStyle.copyWith(
            fontSize: 34,
            fontWeight: FontWeight.bold,
          ),
          navTitleTextStyle: baseTextStyle.copyWith(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
          navActionTextStyle: baseTextStyle.copyWith(
            color: AppColors.buttonPrimary,
            fontSize: 17,
          ),
          tabLabelTextStyle: baseTextStyle.copyWith(
            fontSize: 10,
            letterSpacing: -0.24,
          ),
        ),
      ),
      home: const PantallaDado(), // Pantalla inicial.
    );
  }
}
