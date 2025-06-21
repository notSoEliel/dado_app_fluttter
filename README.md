# Flutter App – Cliente del Sistema de Dado con Login

Una aplicación en Flutter que permite a los usuarios autenticarse (login sin registro), lanzar un dado virtual, y registrar su puntaje a través de un backend FastAPI.

---

## ✨ Características

- **Login Simple** con conexión al backend.
- **Lanzamiento de Dado Aleatorio** (local, con animación).
- **Interfaz Cupertino (iOS-like)**.
- **Registro de Puntos** vía API REST.
- **Animaciones**: sacudida del dado, fondo dorado, confeti.

---

## 📂 Estructura de Archivos

```markdown
flutter_app/
├── lib/
│   ├── main.dart
│   └── screens/
│       ├── login_screen.dart
│       └── dado_screen.dart
├── assets/images/
├── pubspec.yaml
└── README.md
```

---

## 📦 Dependencias Clave

```yaml
dependencies:
  cupertino_icons: ^1.0.2
  flutter_svg: ^2.0.5
  confetti: ^0.7.0
  http: ^1.2.0
```

⸻

## 📡 Comunicación con el Backend

 • Login:
 • POST a http://localhost:8000/login
 • Envío de username/contraseña
 • Lanzar dado:
 • POST a http://localhost:8000/lanzar_dado
 • Envío de usuario_id
 • Devuelve el resultado (1–6) y los puntos actualizados

Nota: Usa 10.0.2.2 en lugar de localhost si corres en un emulador Android. Esto aplica para acceder al backend desde un emulador Android, ya que localhost se refiere al emulador mismo.

⸻

## ▶️ Cómo Ejecutar

```bash
flutter pub get
flutter run
```

⸻

### 🔐 Usuarios de Prueba

 • neptune.son / clave123
 • thread.it / clave231
 • ericka_aves / clave321
