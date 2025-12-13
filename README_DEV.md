# Service Marketplace App

Aplicación móvil Flutter que conecta clientes con proveedores de servicios locales.

## Arquitectura

- **DDD (Domain-Driven Design)**: Separación clara entre domain, data y presentation
- **BLoC Pattern**: Manejo de estado con flutter_bloc
- **Clean Architecture**: Capas independientes y testeables
- **SQLite**: Base de datos local con sqflite

## Estructura del Proyecto

```
lib/
├── core/                    # Código compartido
│   ├── constants/          # Constantes de la app
│   ├── theme/              # Tema y estilos
│   ├── utils/              # Utilidades
│   ├── errors/             # Manejo de errores
│   ├── network/            # Cliente HTTP
│   └── database/           # Configuración de BD
│
└── features/               # Features de la app
    ├── auth/              # Autenticación
    │   ├── domain/       # Entidades y contratos
    │   ├── data/         # Implementaciones
    │   └── presentation/ # UI y BLoC
    ├── services/         # Servicios
    ├── appointments/     # Citas
    ├── reviews/          # Reseñas
    ├── chat/             # Mensajería
    ├── home/             # Página principal
    └── notifications/    # Notificaciones
```

## Dependencias Principales

- `flutter_bloc`: Manejo de estado
- `dio`: Cliente HTTP
- `sqflite`: Base de datos local
- `firebase_messaging`: Notificaciones push
- `geolocator`: Geolocalización
- `google_maps_flutter`: Mapas
- `socket_io_client`: Chat en tiempo real
- `dartz`: Programación funcional
- `equatable`: Comparación de objetos

## Instalación

```bash
# Instalar dependencias
flutter pub get

# Ejecutar en modo debug
flutter run

# Generar APK de release
flutter build apk --release
```

## Features Implementados

### ✅ Fase 1: Autenticación
- [x] Estructura DDD completa
- [x] Login/Register use cases
- [x] AuthBloc con estados
- [x] Páginas de Login y Splash
- [x] Integración con backend (preparado)
- [x] Caché local de usuario

### 🚧 Próximos Pasos
- [ ] Página de registro completa
- [ ] Feature de servicios
- [ ] Geolocalización y radio de cobertura
- [ ] Feature de appointments
- [ ] Chat en tiempo real
- [ ] Notificaciones push

## Configuración

### Backend API
Actualizar la URL base en `lib/core/constants/api_constants.dart`:

```dart
static const String baseUrl = 'https://tu-api.com';
```

### Firebase
1. Agregar `google-services.json` (Android) en `android/app/`
2. Agregar `GoogleService-Info.plist` (iOS) en `ios/Runner/`
3. Configurar Firebase en consola

## Notas de Desarrollo

- No se usa inyección de dependencias con get_it/injectable
- Las dependencias se instancian manualmente en `main.dart`
- Los BLoCs se registran con `BlocProvider` en el árbol de widgets
- El radio de cobertura lo define el **proveedor**, no el cliente
