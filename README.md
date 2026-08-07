# 🎂 Tortas Yani - Aplicación Móvil (Android & iOS)

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%2300B4AB.svg?style=for-the-badge&logo=dart&logoColor=white)
![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)
![Provider](https://img.shields.io/badge/State_Management-Provider-FF6F00?style=for-the-badge)
![Groq AI](https://img.shields.io/badge/AI_Assistant-Groq-F55036?style=for-the-badge)
![Cloudinary](https://img.shields.io/badge/Storage-Cloudinary-3448C5?style=for-the-badge)

**Aplicación móvil multiplataforma desarrollada en Flutter para la gestión de catálogo, pedidos personalizados, mapa interactivo y asistencia virtual por IA de la pastelería "Tortas Yani".**

[Características](#-características-principales) • [Tecnologías](#-tecnologías-y-lenguajes) • [Requisitos](#-requisitos-previos) • [Instalación](#-instalación-y-configuración) • [Ejecución](#-ejecución) • [Estructura](#-estructura-del-proyecto)

</div>

---

## 🌟 Descripción General

**Tortas Yani App** es la experiencia móvil oficial diseñada para clientes y administradores de la pastelería. Ofrece un flujo completo desde el registro de usuarios, catálogo dinámico de productos, personalizador interactivo de tortas, carrito de compras con simulación de pago, geolocalización de entrega mediante mapas interactivos, y un chatbot asistente con IA denominado **Yani** impulsado por el motor Groq LLM.

---

## 🚀 Características Principales

### 📱 Para Clientes
- 🍰 **Catálogo Dinámico:** Exploración de tortas, cupcakes y postres con filtrado por categorías y búsqueda inteligente.
- 🎨 **Personalizador de Tortas:** Selección de tamaño, sabor de bizcocho, relleno y temática con cálculo automático de costo.
- 🤖 **Yani AI (Asistente Virtual):** Chat en vivo integrado con IA para cotizaciones, recomendaciones y soporte en lenguaje natural.
- 🛒 **Carrito & Checkout:** Gestión fluida de ítems, cupones de descuento y confirmación de pedidos.
- 📍 **Mapa de Cobertura y Entrega:** Selección de dirección de envío mediante mapas interactivos (`flutter_map` + `geolocator`).
- ❤️ **Favoritos & Historial:** Guardado de productos preferidos y seguimiento de estado de pedidos.

### 🛡️ Para Administradores
- 📊 **Panel de Control (Dashboard):** Métricas generales de ventas, usuarios e ingresos.
- 📦 **Gestión de Productos (CRUD):** Creación, edición y eliminación de tortas con carga directa de imágenes a **Cloudinary**.
- 📋 **Gestión de Pedidos:** Monitoreo y cambio de estado de pedidos (Pendiente, En Preparación, Entregado, Canceled).
- 👥 **Administración de Usuarios:** Control de roles (Cliente / Administrador).

---

## 🛠️ Tecnologías y Lenguajes

| Categoría | Tecnología / Librería | Descripción |
| :--- | :--- | :--- |
| **Lenguaje Principal** | **Dart** (SDK `^3.5.4`) | Lenguaje fuertemente tipado para el desarrollo multiplataforma |
| **Framework Móvil** | **Flutter** (SDK `^3.x`) | UI Toolkit para compilación nativa en Android & iOS |
| **Gestión de Estado** | **Provider** (`^6.1.5`) | Inyección de dependencias y estado reactivo limpio |
| **Asistente IA** | **Groq API** (`Llama3 / Mixtral`) | Procesamiento de lenguaje natural mediante API OpenAI-compatible |
| **Almacenamiento Cloud**| **Cloudinary API** | Carga y gestión optimizada de imágenes |
| **Mapas & GPS** | `flutter_map` + `latlong2` + `geolocator` | Visualización e interactividad geoespacial basada en OpenStreetMap |
| **Base de Datos Local** | `hive` & `hive_flutter` + `shared_preferences` | Almacenamiento persistente de sesión, caché y configuración local |
| **Diseño y Animaciones**| `google_fonts`, `lottie`, `flutter_animate`, `iconsax` | UI moderna con micro-interacciones, tipografía custom y animaciones fluidas |
| **Notificaciones** | `firebase_messaging` + `flutter_local_notifications` | Notificaciones push y alertas locales |

---

## 🏗️ Arquitectura de la Aplicación

La aplicación sigue una arquitectura por capas basada en patrones **Clean / Modular Architecture**:

```
lib/
├── models/         # Modelos de datos y serialización JSON (User, Recipe, Order, etc.)
├── providers/      # Lógica de estado reactiva con Provider (CartProvider, UserProvider, etc.)
├── services/       # Conexiones API REST (AuthService, ChatService, CloudinaryService)
├── screens/        # Vistas de la aplicación
│   ├── admin/      # Pantallas administrativas (CRUD productos, pedidos, usuarios)
│   └── ...         # Pantallas de cliente (Home, Cart, Profile, Map, Chat AI, etc.)
├── utils/          # Constantes globales, colores, temas y catálogos estáticos
└── widgets/        # Componentes UI reutilizables y personalizados
```

---

## 📋 Requisitos Previos

Antes de comenzar, asegúrate de contar con lo siguiente instalado en tu entorno de desarrollo:

1. **Flutter SDK**: Versión `3.24.x` o superior. ([Instrucciones de instalación](https://docs.flutter.dev/get-started/install))
2. **Dart SDK**: Incluido con Flutter (compatible con `^3.5.4`).
3. **Android Studio** o **VS Code** con las extensiones oficiales de Flutter y Dart.
4. **Android SDK & Emulador** (o dispositivo físico Android con Depuración USB habilitada).
5. **Git** instalado.

---

## 📦 Instalación y Configuración

### 1. Clonar el Repositorio
```bash
git clone https://github.com/junn-shadow/TortasYaniApp.git
cd TortasYaniApp
```

### 2. Instalar Dependencias
Ejecuta el siguiente comando para descargar todos los paquetes registrados en `pubspec.yaml`:
```bash
flutter pub get
```

### 3. Configurar Variables de Entorno (Opcional)
Para habilitar el asistente de IA **Yani**, puedes proveer tu clave de API de Groq durante la compilación o ejecución:
```bash
--dart-define=GROQ_API_KEY="tu_api_key_aqui"
```

---

## 🚀 Ejecución

### En Modo Desarrollo (Debug)

1. Conecta tu dispositivo Android o inicia un emulador.
2. Ejecuta el proyecto con el siguiente comando:

```bash
flutter run
```

O especificando la clave de IA:
```bash
flutter run --dart-define=GROQ_API_KEY="tu_api_key_de_groq"
```

### Compilar APK para Producción (Android)

Para generar el archivo ejecutable `.apk`:

```bash
flutter build apk --release
```

El APK generado se encontrará en:
`build/app/outputs/flutter-apk/app-release.apk`

---

## 📄 Licencia y Créditos

Desarrollado como parte del sistema integral de **Tortas Yani**. Todos los derechos reservados © 2026.
