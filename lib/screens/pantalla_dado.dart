import 'dart:math'; // Para generar números aleatorios.
import 'package:flutter/cupertino.dart'; // Widgets y temas de estilo iOS.
import 'package:flutter_svg/flutter_svg.dart'; // Para renderizar imágenes SVG.
import 'package:confetti/confetti.dart'; // Para la animación de confeti al ganar.
import 'dart:convert'; // Para usar jsonEncode y jsonDecode
import 'package:http/http.dart' as http; // Para usar http.post
import '../main.dart'; // Importar AppColors y configuraciones globales desde main.dart.
import 'pantalla_login.dart'; // Importar la pantalla de login para navegación.

// PantallaDado: El widget principal para la interfaz del juego de dados.
// Es un StatefulWidget porque su apariencia y datos cambian durante la interacción del usuario.
class PantallaDado extends StatefulWidget {
  final int usuarioId;
  final String nombre;
  final int puntosIniciales;

  const PantallaDado({
    super.key,
    required this.usuarioId,
    required this.nombre,
    required this.puntosIniciales,
  });

  @override
  State<PantallaDado> createState() => _EstadoPantallaDado();
}

// _EstadoPantallaDado: Maneja el estado interno, la lógica del juego y las animaciones para PantallaDado.
// 'with TickerProviderStateMixin' es necesario para que este estado pueda proveer Tickers
// a los AnimationController, que son esenciales para las animaciones.
class _EstadoPantallaDado extends State<PantallaDado>
    with TickerProviderStateMixin {
  // --- Variables de Estado ---
  // Estas variables almacenan datos que, cuando cambian (usando setState),
  // provocan que la UI se reconstruya para reflejar los nuevos valores.

  late int _puntos;

  int _resultadoDado =
      1; // Almacena el número (1-6) del último lanzamiento del dado.
  String _mensaje =
      "¡Lanza el dado!"; // Mensaje que se muestra al usuario (ej. resultado, ganar, perder).
  bool _estaLanzando =
      false; // true si una animación de lanzamiento está en curso; se usa para deshabilitar el botón.
  bool _ganoEnUltimoLanzamiento =
      false; // true si el último lanzamiento resultó en un 6.
  bool _forzarReseteoInstantaneoFondo =
      false; // Bandera para controlar si el fondo debe resetearse instantáneamente.

  // --- Controladores de Animación ---
  // Los AnimationController gestionan el progreso de una animación.

  late AnimationController
      _scaleController; // Controla la animación de escala del dado.
  late Animation<double>
      _scaleAnimation; // Define los valores específicos de la animación de escala (zoom).

  late AnimationController
      _shakeController; // Controla la animación de "sacudida" del dado.
  late Animation<double>
      _shakeAnimation; // Define los valores específicos de la animación de sacudida (rotación).

  late ConfettiController
      _confettiController; // Controla la animación de confeti.

  // initState: Se llama una única vez cuando este objeto State se crea e inserta en el árbol de widgets.
  // Es el lugar ideal para inicializaciones que solo necesitan ocurrir una vez.
  @override
  void initState() {
    super.initState(); // Siempre llamar a super.initState() primero.

    _puntos = widget.puntosIniciales;

    //Inicializacion del cotrolador de animación de escala del dado.
    _scaleController = AnimationController(
      duration:
          const Duration(milliseconds: 200), // Duración total de la animación.
      vsync: this, // Vincula el controlador al TickerProvider de este State.
    );

    // Definición de la animación de escala.
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.5)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(_scaleController);

    // Inicialización del controlador de la animación de sacudida.
    _shakeController = AnimationController(
      duration:
          const Duration(milliseconds: 300), // Duración total de la animación.
      vsync: this, // Vincula el controlador al TickerProvider de este State.
    );
    // Definición de la animación de sacudida usando una secuencia de movimientos de rotación.
    _shakeAnimation = TweenSequence<double>(
      <TweenSequenceItem<double>>[
        TweenSequenceItem<double>(
            tween: Tween<double>(begin: 0.0, end: 2), weight: 1),
        // TweenSequenceItem<double>(tween: Tween<double>(begin: -0.05, end: 0.05), weight: 1),
        // TweenSequenceItem<double>(tween: Tween<double>(begin: 0.05, end: -0.03), weight: 1),
        // TweenSequenceItem<double>(tween: Tween<double>(begin: -0.03, end: 0.03), weight: 1),
        // TweenSequenceItem<double>(tween: Tween<double>(begin: 0.03, end: 0.0), weight: 1), // Termina en la posición original.
      ],
    ).animate(CurvedAnimation(
        parent: _shakeController,
        curve: Curves.easeInOutSine)); // Aplica una curva suave.

    // Inicialización del controlador de confeti.
    _confettiController = ConfettiController(
        duration:
            const Duration(seconds: 1)); // Duración de la explosión de confeti.
  }

  // dispose: Se llama cuando este objeto State se elimina permanentemente del árbol de widgets.
  // Es crucial liberar los recursos de los controladores aquí para evitar fugas de memoria.
  @override
  void dispose() {
    _scaleController.dispose();
    _shakeController.dispose();
    _confettiController.dispose();
    super.dispose(); // Siempre llamar a super.dispose() al final.
  }

  // _crearDecoracionFondo: Devuelve un BoxDecoration para el fondo de la pantalla.
  // Cambia entre un fondo dorado (si se ganó) y el fondo neutro normal.
  BoxDecoration _crearDecoracionFondo() {
    if (_ganoEnUltimoLanzamiento) {
      // Si se ganó, se aplica un degradado dorado vistoso.
      return const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.winningBackgroundGoldStart,
            AppColors.winningBackgroundGoldCenter,
            AppColors.winningBackgroundGoldEnd,
            AppColors.winningBackgroundGoldStart,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [
            0.0,
            0.35,
            0.65,
            1.0
          ], // Puntos de parada para controlar la mezcla de colores.
        ),
      );
    } else {
      // En estado normal, se usa el color de fondo neutro definido en AppColors.
      return const BoxDecoration(color: AppColors.neutralBackground);
    }
  }

  /// Lógica principal para lanzar el dado cuando el usuario presiona el botón.
  ///
  /// - Si el usuario no tiene suficientes puntos o ya está lanzando, no hace nada.
  /// - Cambia el estado a "lanzando", muestra mensaje y resetea animaciones si es necesario.
  /// - Envía una petición HTTP al backend para obtener el resultado del dado y los puntos actualizados.
  /// - Si el resultado es 6, muestra confeti y mensaje especial.
  /// - Si ocurre un error, muestra mensaje de error.
  void _lanzarDado() async {
    if (_estaLanzando || _puntos < 100)
      return; // Evita lanzar si ya está lanzando o no hay puntos suficientes.

    setState(() {
      _estaLanzando = true; // Indica que está lanzando el dado.
      _mensaje = "Lanzando..."; // Mensaje temporal.
      if (_ganoEnUltimoLanzamiento) {
        _forzarReseteoInstantaneoFondo = true; // Resetea fondo si ganó antes.
      }
      _ganoEnUltimoLanzamiento = false;
      if (_confettiController.state == ConfettiControllerState.playing) {
        _confettiController.stop(); // Detiene confeti si estaba activo.
      }
    });

    // Inicia animaciones de sacudida y escala del dado.
    _shakeController.forward(from: 0.0);
    _scaleController.forward(from: 0.0).then((_) => _scaleController.reverse());

    try {
      // Envía petición POST al backend para lanzar el dado.
      final response = await http.post(
        // Uri.parse('http://localhost:8000/lanzar_dado'),
        Uri.parse(
            'http://10.0.2.2:8000/lanzar_dado'), // Cambia esto si usas un emulador
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'usuario_id': widget.usuarioId}),
      );

      if (response.statusCode == 200) {
        // Si la respuesta es exitosa, actualiza el resultado y los puntos.
        final data = jsonDecode(response.body);
        final resultado = data['resultado']; // Número que salió en el dado.
        final puntos =
            data['puntos_actuales']; // Puntos actualizados del usuario.

        setState(() {
          _resultadoDado = resultado;
          _puntos = puntos;
          _ganoEnUltimoLanzamiento = (resultado == 6); // ¿Ganó?
          _mensaje = _ganoEnUltimoLanzamiento
              ? "¡VAYA CRACK! ¡Sacaste un 6!" // Mensaje especial si gana
              : "Sacaste un $resultado. ¡Suerte la próxima!";
          if (_ganoEnUltimoLanzamiento) {
            _confettiController.play(); // Activa confeti si ganó
          }
        });
      } else {
        // Si hay error en la respuesta, muestra mensaje de error.
        setState(() {
          _mensaje = "Error al lanzar dado. Intenta de nuevo.";
        });
      }
    } catch (e) {
      // Si ocurre un error de conexión, muestra mensaje de error.
      setState(() {
        _mensaje = "Error de conexión con el servidor.";
      });
    } finally {
      setState(() {
        _estaLanzando = false; // Permite volver a lanzar.
      });
    }
  }

  // _construirImagenDado2D: Construye y devuelve el widget que muestra la imagen SVG del dado.
  Widget _construirImagenDado2D() {
    // Construir la ruta del archivo SVG basada en el resultado del dado.
    final svgPath = 'assets/images/dice_$_resultadoDado.svg';

    return ScaleTransition(
      scale: _scaleAnimation, // Aplica la animación de escala al dado.
      child: RotationTransition(
        // Aplica la animación de sacudida al dado.
        turns: _shakeAnimation, // La animación de sacudida se aplica aquí.
        child: SvgPicture.asset(
          // Cargar la imagen SVG del dado.
          svgPath, // Ruta del archivo SVG.
          height: 180, // Altura del dado.
          width: 180, // Ancho del dado.
          placeholderBuilder: (context) => Container(
            // Placeholder mientras se carga la imagen.
            height: 180, width: 180, // Dimensiones del contenedor.
            padding: const EdgeInsets.all(30.0), // Espacio interno.
            child: const CupertinoActivityIndicator(
                color: AppColors.activityIndicator), // Indicador de carga.
          ),
        ),
      ),
    );
  }

  // build: Este método es llamado por Flutter cada vez que el estado cambia o necesita redibujar la UI.
  // Describe cómo construir la interfaz de usuario basada en el estado actual.
  @override
  Widget build(BuildContext context) {
    // Obtener la instancia del tema de Cupertino definido en main.dart.
    // Esto permite usar los estilos de texto y colores definidos globalmente.
    final CupertinoThemeData cupertinoTheme = CupertinoTheme.of(context);

    // Lógica para resetear la bandera _forzarReseteoInstantaneoFondo.
    // Se usa addPostFrameCallback para ejecutar código después de que el frame actual se haya construido.
    // Esto evita errores de setState durante un build.
    if (_forzarReseteoInstantaneoFondo) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Verificar si el widget sigue montado antes de llamar a setState.
        if (mounted) {
          setState(() {
            _forzarReseteoInstantaneoFondo = false;
          });
        }
      });
    }

    // Colores con alfa ajustado para opacidad, usando el método estándar `withAlpha`.
    // `withValues` toma un double entre 0.0 (transparente) y 1.0 (opaco) y lo asigna al atributo alpha.
    final Color colorBlancoSemiOpaco =
        CupertinoColors.white.withValues(alpha: 0.90);
    final Color colorSombraNegra =
        CupertinoColors.black.withValues(alpha: 0.10);
    final Color colorSombraBoton =
        CupertinoColors.black.withValues(alpha: 0.20);

    // CupertinoPageScaffold es la estructura base para una pantalla de estilo iOS.
    return CupertinoPageScaffold(
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // AnimatedSwitcher se encargará de la transición entre los fondos.
          AnimatedSwitcher(
            duration: _forzarReseteoInstantaneoFondo
                ? Duration
                    .zero // Transición instantánea si se fuerza el reseteo.
                : const Duration(
                    milliseconds: 600), // Duración normal del fundido.
            // El child del AnimatedSwitcher. La Key es importante para que detecte el cambio.
            // Usamos ValueKey(_ganoEnUltimoLanzamiento) para que cambie cuando el estado de victoria cambie.
            child: Container(
                key: ValueKey<bool>(
                    _ganoEnUltimoLanzamiento), // Cambio de Key dispara la animación.
                width: double
                    .infinity, // Asegura que el container ocupe toda la pantalla.
                height: double.infinity,
                decoration:
                    _crearDecoracionFondo(), // Aplica la decoración actual (gris o dorada).
                // El contenido de la pantalla va DENTRO del Container que se anima.
                // El child del AnimatedSwitcher (y por ende del Container con el fondo) es el contenido principal de la pantalla.
                child: Stack(
                  children: [
                    SafeArea(
                      // SafeArea asegura que el contenido no sea obstruido por elementos del sistema
                      // como el notch del teléfono, la barra de estado o los gestos de navegación.
                      child: Center(
                        // Centra a su hijo (Column) en el espacio disponible del SafeArea.
                        child: Column(
                          // Column organiza a sus hijos en una lista vertical.
                          mainAxisAlignment: MainAxisAlignment
                              .center, // Alinea los hijos verticalmente en el centro de la Column.
                          children: <Widget>[
                            // Spacer es un widget flexible que ocupa el espacio disponible,
                            // útil para empujar otros widgets o distribuir espacio. Aquí empuja el contenido hacia el centro.
                            const Spacer(),

                            // Container que muestra el número resultante del dado.
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12), // Espacio interno.
                              decoration: BoxDecoration(
                                // Estilo visual del contenedor.
                                color:
                                    colorBlancoSemiOpaco, // Color de fondo (definido en el build).
                                borderRadius: BorderRadius.circular(
                                    15), // Bordes redondeados.
                                boxShadow: [
                                  // Sombra para dar efecto de profundidad.
                                  BoxShadow(
                                    color:
                                        colorSombraNegra, // Color de la sombra (definido en el build).
                                    spreadRadius:
                                        1, // Cuánto se expande la sombra.
                                    blurRadius:
                                        8, // Cuán difuminada es la sombra.
                                    offset: const Offset(0,
                                        4), // Desplazamiento de la sombra (horizontal, vertical).
                                  ),
                                ],
                              ),
                              // Texto que muestra el número del dado y los puntos actuales.
                              child: Column(
                                children: [
                                  Text(
                                    _estaLanzando ? "?" : '$_resultadoDado',
                                    style: cupertinoTheme
                                        .textTheme.navLargeTitleTextStyle
                                        .copyWith(
                                      fontSize: 40,
                                      color: _ganoEnUltimoLanzamiento
                                          ? AppColors.diceNumberGold
                                          : AppColors.textDefault,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Puntos: $_puntos",
                                    style: cupertinoTheme.textTheme.textStyle
                                        .copyWith(
                                      fontSize: 16,
                                      color: CupertinoColors.systemGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                                height:
                                    40), // Un espacio vertical fijo de 40 píxeles.

                            // Expanded hace que su hijo (_construirImagenDado2D) ocupe el espacio vertical disponible
                            // dentro de la Column, según su factor de 'flex'.
                            Expanded(
                                flex:
                                    3, // Proporción del espacio que este Expanded debe ocupar en relación a otros Expanded.
                                child:
                                    _construirImagenDado2D() // Widget que muestra la imagen del dado.
                                ),
                            const SizedBox(
                                height: 20), // Otro espacio vertical fijo.

                            // Padding añade espacio alrededor de su hijo (Text del mensaje).
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0), // Espacio horizontal.
                              child: Text(
                                // Texto que muestra el mensaje de estado (ganó, perdió, etc.).
                                _mensaje,
                                style:
                                    cupertinoTheme.textTheme.textStyle.copyWith(
                                  // Estilo del texto.
                                  // Color de texto adaptado al fondo actual para mejor legibilidad.
                                  color: _ganoEnUltimoLanzamiento
                                      ? AppColors.textOnGoldBackground
                                      : AppColors.textDefault,
                                  fontWeight: _ganoEnUltimoLanzamiento
                                      ? FontWeight.bold
                                      : FontWeight.w500, // Peso de la fuente.
                                  fontSize: 18, // Tamaño de fuente.
                                ),
                                textAlign:
                                    TextAlign.center, // Alineación del texto.
                              ),
                            ),
                            const Spacer(), // Otro Spacer para empujar el botón hacia la parte inferior.

                            // Padding para el botón, principalmente para darle espacio en la parte inferior de la pantalla.
                            Padding(
                              padding: const EdgeInsets.only(bottom: 30.0),
                              child: CupertinoButton(
                                // Botón de estilo iOS.
                                padding: EdgeInsets
                                    .zero, // Quita el padding por defecto del CupertinoButton.
                                onPressed: _estaLanzando
                                    ? null
                                    : _lanzarDado, // Llama a _lanzarDado o se deshabilita.
                                child: Container(
                                  // Container para darle forma y estilo al botón.
                                  width: 80, height: 80, // Tamaño del botón.
                                  decoration: BoxDecoration(
                                    color: _estaLanzando
                                        ? AppColors.buttonDisabled
                                        : AppColors
                                            .buttonPrimary, // Color dinámico.
                                    shape: BoxShape.circle, // Forma circular.
                                    boxShadow: [
                                      // Sombra del botón.
                                      BoxShadow(
                                        color:
                                            colorSombraBoton, // Color de la sombra (definido en el build).
                                        spreadRadius: 1,
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  // Contenido del botón: un indicador de carga o un ícono.
                                  child: _estaLanzando
                                      ? const CupertinoActivityIndicator(
                                          color: AppColors
                                              .activityIndicator) // Si está lanzando.
                                      : const Icon(
                                          CupertinoIcons.arrow_2_circlepath,
                                          color: AppColors.textLight,
                                          size: 40), // Ícono de refrescar.
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 60,
                      right: 20,
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            CupertinoPageRoute(
                                builder: (context) => const PantallaLogin()),
                          );
                        },
                        child: const Icon(
                          CupertinoIcons.square_arrow_left,
                          color: AppColors.buttonPrimary,
                          size: 28,
                        ),
                      ),
                    ),
                  ],
                )),
          ),
          // Widget para mostrar la animación de confeti.
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality
                .explosive, // Confeti explota en todas direcciones.
            shouldLoop: false, // No repetir la animación.
            numberOfParticles: 25, // Cantidad de partículas.
            gravity: 0.1, // Gravedad ligera.
            emissionFrequency: 0.03, // Frecuencia de emisión.
            colors: AppColors.confettiColors, // Colores del confeti.
          ),
        ],
      ),
    );
  }
}
