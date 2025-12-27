# Sistema de Avatares de Usuario

## Descripción

Este documento describe la implementación completa del sistema de avatares para los usuarios de la aplicación. Los usuarios pueden subir, actualizar y visualizar sus fotos de perfil.

## Endpoint del Servidor

### POST `/upload/avatar`

**Autenticación:** ✅ JWT requerido

**Headers:**
```
Authorization: Bearer {access_token}
Content-Type: multipart/form-data
```

**Body (Form Data):**
```
file: <image file> (jpg, png, webp)
```

**Validaciones:**
- Máximo 5MB
- Formatos permitidos: jpg, png, webp
- Se reemplaza el avatar anterior si existe

**Response (200):**
```json
{
  "message": "Avatar actualizado exitosamente",
  "avatarUrl": "https://res.cloudinary.com/dkvfdzpj/image/upload/v1701452400/service-marketplace/avatars/550e8400-e29b-41d4-a716-446655440000.jpg"
}
```

**Posibles errores:**
- `400` - No se envió ninguna imagen
- `400` - Archivo debe ser menor a 5MB
- `400` - Formato no permitido (solo jpg, png, webp)

## Arquitectura de la Implementación

La funcionalidad sigue la arquitectura Clean Architecture del proyecto:

### 1. Capa de Datos (Data Layer)

#### `auth_remote_datasource.dart`
```dart
Future<String> uploadAvatar({required String filePath})
```
- Crea un FormData con el archivo de imagen
- Envía la solicitud POST a `/upload/avatar`
- Retorna la URL del avatar subido
- Maneja errores de tamaño, formato y servidor

#### `auth_repository_impl.dart`
```dart
Future<Either<Failure, String>> uploadAvatar({required String filePath})
```
- Implementa el método del repositorio
- Convierte excepciones en Failures
- Maneja errores de forma consistente

### 2. Capa de Dominio (Domain Layer)

#### `auth_repository.dart`
```dart
Future<Either<Failure, String>> uploadAvatar({required String filePath});
```
- Define el contrato para subir avatares

#### `upload_avatar_usecase.dart`
```dart
Future<Either<Failure, String>> call({required String filePath})
```
- Caso de uso que encapsula la lógica de negocio
- Llama al repositorio para subir el avatar

#### `user.dart`
- El campo `photoUrl` almacena la URL del avatar
- Agregado método `copyWith` para actualizar el usuario con la nueva URL

### 3. Capa de Presentación (Presentation Layer)

#### `auth_event.dart`
```dart
class AuthUploadAvatarRequested extends AuthEvent {
  final String filePath;
}
```
- Evento que dispara la subida del avatar

#### `auth_state.dart`
```dart
enum AuthStatus {
  // ... otros estados
  uploadingAvatar,  // Mientras se sube el avatar
  avatarUploaded,   // Avatar subido exitosamente
}
```
- Estados para manejar el progreso de la subida

#### `auth_bloc.dart`
```dart
Future<void> _onUploadAvatarRequested(...)
```
- Maneja el evento de subida de avatar
- Actualiza el estado durante el proceso
- Actualiza el usuario con la nueva URL del avatar
- Muestra notificaciones de éxito o error

#### `avatar_upload_widget.dart`
Widget completo para la gestión del avatar:

**Características:**
- Muestra el avatar actual del usuario
- Si no hay avatar, muestra iniciales del nombre
- Botón flotante para cambiar/subir avatar
- Selector de fuente de imagen (cámara o galería)
- Validación de tamaño de archivo (máx. 5MB)
- Redimensionamiento automático de imagen (1024x1024)
- Indicadores de carga durante la subida
- Notificaciones de éxito/error
- Manejo de errores de red

**Uso:**
```dart
AvatarUploadWidget(
  photoUrl: user?.photoUrl,
  userName: user?.name,
)
```

## Flujo de Funcionamiento

### Flujo de Subida de Avatar

1. **Usuario selecciona imagen:**
   - Usuario toca el botón de cámara en el avatar
   - Se muestra diálogo para elegir entre cámara o galería
   - Usuario selecciona/toma una foto

2. **Validación:**
   - Se valida que el archivo no supere 5MB
   - Se redimensiona la imagen si es necesario

3. **Subida:**
   - Se dispara `AuthUploadAvatarRequested` con la ruta del archivo
   - El BLoC emite estado `uploadingAvatar`
   - Se muestra indicador de carga en el widget

4. **Procesamiento:**
   - El caso de uso llama al repositorio
   - El repositorio llama al datasource remoto
   - Se envía el archivo como multipart/form-data
   - El servidor procesa y sube a Cloudinary

5. **Respuesta:**
   - Si es exitoso:
     - Se recibe la URL del avatar
     - Se actualiza el usuario en el estado
     - Se emite estado `avatarUploaded`
     - Se muestra notificación de éxito
     - Se vuelve a estado `authenticated`
   
   - Si hay error:
     - Se emite estado `error` con mensaje
     - Se muestra notificación de error

### Flujo de Visualización

1. **Al cargar la página:**
   - El widget recibe `photoUrl` del usuario actual
   - Si existe URL, se muestra la imagen de red
   - Si no existe, se muestran las iniciales

2. **Actualizaciones:**
   - El BLoC escucha cambios en el usuario
   - Cuando se actualiza el avatar, el widget se reconstruye
   - La nueva imagen se muestra automáticamente

## Integración en HomePage

El widget de avatar se muestra en la parte superior del HomePage:

```dart
AvatarUploadWidget(
  photoUrl: user?.photoUrl,
  userName: user?.name,
),
```

## Dependencias Utilizadas

- **image_picker:** ^1.1.2 - Para seleccionar imágenes de cámara/galería
- **dio:** ^5.4.3+1 - Para enviar multipart/form-data
- **flutter_bloc:** ^8.1.6 - Para gestión de estado

## Consideraciones de Seguridad

1. **Autenticación:** Requiere JWT token válido
2. **Validación de tamaño:** Máximo 5MB en cliente y servidor
3. **Validación de formato:** Solo jpg, png, webp permitidos
4. **Manejo de errores:** Mensajes seguros sin exponer información sensible

## Mejoras Futuras

1. **Recorte de imagen:** Permitir al usuario recortar la imagen antes de subirla
2. **Compresión:** Comprimir imágenes automáticamente para reducir tamaño
3. **Caché:** Cachear avatares localmente para mejor rendimiento
4. **Edición:** Filtros y edición básica de imagen
5. **Eliminación:** Opción para eliminar el avatar y volver al predeterminado
6. **Vista previa:** Mostrar vista previa antes de subir

## Testing

Para probar la funcionalidad:

1. Iniciar sesión en la aplicación
2. Navegar a la página de inicio (HomePage)
3. Tocar el botón de cámara en el avatar
4. Seleccionar fuente de imagen (cámara o galería)
5. Elegir/tomar una foto
6. Verificar que se muestre el indicador de carga
7. Confirmar que el avatar se actualice correctamente
8. Probar con diferentes tamaños y formatos de imagen
9. Verificar mensajes de error con archivos grandes (>5MB)
10. Verificar que el avatar persista después de cerrar y reabrir la app

## Archivos Modificados/Creados

### Creados:
- `lib/features/auth/domain/usecases/upload_avatar_usecase.dart`
- `lib/features/home/presentation/widgets/avatar_upload_widget.dart`

### Modificados:
- `lib/features/auth/data/datasources/auth_remote_datasource.dart`
- `lib/features/auth/data/repositories/auth_repository_impl.dart`
- `lib/features/auth/domain/repositories/auth_repository.dart`
- `lib/features/auth/domain/entities/user.dart`
- `lib/features/auth/presentation/bloc/auth_bloc.dart`
- `lib/features/auth/presentation/bloc/auth_event.dart`
- `lib/features/auth/presentation/bloc/auth_state.dart`
- `lib/features/home/presentation/pages/home_page.dart`
- `lib/main.dart`
