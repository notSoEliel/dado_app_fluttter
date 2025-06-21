import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'pantalla_dado.dart'; // Importa la pantalla principal del dado

/// PantallaLogin es la pantalla de inicio de sesión de la app.
/// Permite al usuario ingresar su usuario y contraseña para acceder a la app.
/// Si el login es exitoso, navega a la pantalla principal del dado.
class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key});

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

/// Estado de la pantalla de login.
/// Aquí se maneja la lógica de autenticación y el diseño visual.
class _PantallaLoginState extends State<PantallaLogin> {
  // Controlador para el campo de usuario
  final TextEditingController _usuarioController = TextEditingController();
  // Controlador para el campo de contraseña
  final TextEditingController _claveController = TextEditingController();
  // Mensaje de error o información para mostrar al usuario
  String _mensaje = '';
  // Indica si se está esperando la respuesta del servidor
  bool _cargando = false;

  /// Función que se ejecuta al presionar el botón de ingresar.
  /// Realiza una petición HTTP al backend para autenticar al usuario.
  /// Si las credenciales son correctas, navega a la pantalla principal.
  /// Si hay error, muestra un mensaje.
  Future<void> _iniciarSesion() async {
    setState(() {
      _cargando = true;
      _mensaje = '';
    });

    try {
      // Realiza la petición POST al backend con usuario y contraseña
      final response = await http.post(
        // Uri.parse('http://localhost:8000/login'),
        Uri.parse(
            'http://10.0.2.2:8000/login'), // Cambia esto si usas un emulador
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': _usuarioController.text, // Usuario ingresado
          'password': _claveController.text, // Contraseña ingresada
        }),
      );

      if (response.statusCode == 200) {
        // Si la respuesta es exitosa, decodifica los datos
        final data = jsonDecode(response.body);
        // Navega a la pantalla principal del dado, pasando los datos del usuario
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(
            builder: (context) => PantallaDado(
              usuarioId: data['id'],
              nombre: data['nombre_completo'],
              puntosIniciales: data['puntos'],
            ),
          ),
        );
      } else {
        // Si las credenciales son incorrectas, muestra mensaje de error
        setState(() {
          _mensaje = 'Credenciales incorrectas';
        });
      }
    } catch (e) {
      // Si ocurre un error de conexión, muestra mensaje de error
      setState(() {
        _mensaje = 'Error al conectar con el servidor.';
      });
    } finally {
      setState(() {
        _cargando = false;
      });
    }
  }

  /// Construye la interfaz de usuario de la pantalla de login.
  /// Incluye logo, título, campos de usuario y contraseña, botón de ingresar y mensajes de error.
  @override
  Widget build(BuildContext context) {
    final CupertinoThemeData theme = CupertinoTheme.of(context); // Tema visual

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text(""), // Quitamos el texto del AppBar
      ),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo de la app, se muestra en la parte superior
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: CupertinoColors.systemGrey.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                    image: const DecorationImage(
                      image: AssetImage('assets/images/logo_app_dado.jpeg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Título de la pantalla debajo del logo
                const Text(
                  "Iniciar Sesión",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 18),
                // Tarjeta que contiene los campos de usuario y contraseña
                Container(
                  constraints: const BoxConstraints(
                    maxWidth: 340,
                    minWidth: 220,
                  ),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: CupertinoColors.systemGrey.withOpacity(0.13),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Campo de texto para el usuario
                      CupertinoTextField(
                        controller: _usuarioController,
                        placeholder: 'Usuario',
                        prefix: const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Icon(CupertinoIcons.person,
                              color: CupertinoColors.systemGrey),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 10),
                        decoration: BoxDecoration(
                          color: CupertinoColors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Campo de texto para la contraseña
                      CupertinoTextField(
                        controller: _claveController,
                        placeholder: 'Contraseña',
                        obscureText:
                            true, // Oculta el texto para mayor seguridad
                        prefix: const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Icon(CupertinoIcons.lock,
                              color: CupertinoColors.systemGrey),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 10),
                        decoration: BoxDecoration(
                          color: CupertinoColors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 22),
                      // Botón de ingresar o indicador de carga
                      _cargando
                          ? const CupertinoActivityIndicator() // Muestra un spinner si está cargando
                          : SizedBox(
                              width: double.infinity,
                              child: CupertinoButton.filled(
                                borderRadius: BorderRadius.circular(10),
                                onPressed:
                                    _iniciarSesion, // Llama a la función de login
                                child: const Text('Ingresar',
                                    style: TextStyle(fontSize: 17)),
                              ),
                            ),
                      const SizedBox(height: 12),
                      // Muestra el mensaje de error si existe
                      if (_mensaje.isNotEmpty)
                        Text(
                          _mensaje,
                          style: theme.textTheme.textStyle.copyWith(
                            color: CupertinoColors.systemRed,
                            fontSize: 15,
                          ),
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
