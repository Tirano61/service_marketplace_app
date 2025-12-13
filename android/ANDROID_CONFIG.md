# Configuración de Android para Service Marketplace App

## Cambios Aplicados

### 1. NDK Version
**Problema**: Plugins requerían Android NDK 27.0.12077973 pero el proyecto usaba 26.3.11579264

**Solución**: Actualizado en `android/app/build.gradle.kts`:
```kotlin
ndkVersion = "27.0.12077973"
```

### 2. Core Library Desugaring
**Problema**: `flutter_local_notifications` requiere desugaring para soportar APIs de Java 8+

**Solución**: Habilitado en `android/app/build.gradle.kts`:
```kotlin
compileOptions {
    sourceCompatibility = JavaVersion.VERSION_11
    targetCompatibility = JavaVersion.VERSION_11
    isCoreLibraryDesugaringEnabled = true
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
```

## Versiones Configuradas

- **minSdk**: Configurado por Flutter
- **compileSdk**: Configurado por Flutter  
- **targetSdk**: Configurado por Flutter
- **NDK**: 27.0.12077973
- **Java**: VERSION_11
- **Kotlin JVM Target**: VERSION_11
- **Desugar JDK Libs**: 2.0.4

## Comandos Útiles

```bash
# Limpiar build
flutter clean

# Reinstalar dependencias
flutter pub get

# Build debug APK
flutter build apk --debug

# Build release APK
flutter build apk --release

# Ejecutar en dispositivo
flutter run
```

## Notas

- El warning sobre x86 targets es informativo y no afecta el build
- Todas las dependencias son compatibles con NDK 27.0.12077973 (backward compatible)
- Core library desugaring permite usar APIs modernas de Java manteniendo compatibilidad
