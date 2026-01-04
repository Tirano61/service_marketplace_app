# Guía de Subida de Imágenes para Servicios

## 📋 Resumen

Este documento explica cómo funciona la subida de imágenes de servicios a Cloudinary a través del backend NestJS.

## 🏗️ Arquitectura

### Backend (NestJS)
- **Proveedor**: Cloudinary
- **Configuración**: Variables de entorno
  - `CLOUDINARY_CLOUD_NAME`
  - `CLOUDINARY_API_KEY`
  - `CLOUDINARY_API_SECRET`
- **Endpoint**: `POST /services/:id/images`
- **Autenticación**: Solo usuarios con rol `PROVIDER`
- **Handler**: `FileInterceptor` de NestJS

### Frontend (Flutter)
- **Datasource**: [services_remote_datasource.dart](data/datasources/services_remote_datasource.dart)
- **HTTP Client**: Dio con multipart/form-data
- **Selector de imágenes**: image_picker

## 🔄 Flujo de Subida

### 1. Creación de Servicio
```dart
// Primero se crea el servicio sin imágenes
final service = await createService(
  title: "...",
  description: "...",
  // ... otros campos
);
// service.id = "abc123"
```

### 2. Subida de Imágenes (una por una)
```dart
// Cada imagen se sube individualmente
for (final imagePath in imagePaths) {
  final imageUrl = await uploadServiceImage(
    serviceId: service.id,
    imagePath: imagePath, // Ruta local del archivo
  );
  // imageUrl = "https://res.cloudinary.com/..."
}
```

### 3. Actualización del Servicio
El backend actualiza automáticamente el array `images` del servicio con cada subida.

## 🛡️ Validaciones

### En el Backend (upload.controller.ts:79-101)
1. ✅ Verifica que se envió un archivo
2. ✅ Valida que el servicio existe
3. ✅ Verifica que el usuario es el dueño del servicio
4. ✅ Comprueba que no se exceda el límite de 5 imágenes

### En el Frontend
```dart
// Validaciones de archivo
- Tamaño máximo: 5MB
- Formatos: JPG, JPEG, PNG, WEBP
- Límite por servicio: 5 imágenes
```

## 📝 Implementación Detallada

### Método `uploadServiceImage`
```dart
Future<String> uploadServiceImage(String serviceId, String imagePath) async {
  // 1. Crear archivo
  final file = File(imagePath);
  final fileName = file.path.split('/').last;

  // 2. Crear FormData con multipart
  final formData = FormData.fromMap({
    'file': await MultipartFile.fromFile(
      file.path,
      filename: fileName,
    ),
  });

  // 3. POST a /services/:id/images
  final response = await _dio.post(
    '/services/$serviceId/images',
    data: formData,
    options: Options(
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    ),
  );

  // 4. Extraer URL de Cloudinary
  final images = response.data['images'] as List;
  return images.last as String; // Última imagen agregada
}
```

### Flujo Completo en `createService`
```dart
@override
Future<ServiceModel> createService({...}) async {
  // PASO 1: Crear servicio sin imágenes
  final newService = ServiceModel(
    id: generatedId,
    // ... otros campos
    images: const [], // Sin imágenes inicialmente
  );
  
  // Guardar en BD
  await save(newService);

  // PASO 2: Subir imágenes una por una
  final uploadedImageUrls = <String>[];
  for (final imagePath in imagePaths) {
    try {
      final imageUrl = await uploadServiceImage(
        newService.id,
        imagePath,
      );
      uploadedImageUrls.add(imageUrl);
    } catch (e) {
      print('Error subiendo imagen: $e');
      // Continuar con las demás imágenes
    }
  }

  // PASO 3: El servicio ya tiene las imágenes en la BD
  // (actualizadas automáticamente por el backend)
  return await getServiceById(newService.id);
}
```

## 🗑️ Eliminación de Imágenes

### Endpoint
```
DELETE /services/:id/images
```

### Implementación
```dart
Future<void> deleteServiceImage(String serviceId, String imageUrl) async {
  await _dio.delete(
    '/services/$serviceId/images',
    data: {'imageUrl': imageUrl},
  );
  // El backend:
  // 1. Elimina la imagen de Cloudinary
  // 2. Remueve la URL del array de imágenes
}
```

## 🎯 Casos de Uso

### Crear Servicio con Imágenes
```dart
// Usuario selecciona 3 imágenes del dispositivo
final imagePaths = [
  '/storage/emulated/0/Pictures/img1.jpg',
  '/storage/emulated/0/Pictures/img2.jpg',
  '/storage/emulated/0/Pictures/img3.jpg',
];

// Se crea el servicio y se suben las imágenes
final service = await createService(
  title: "Plomería",
  description: "...",
  imagePaths: imagePaths,
);

// Resultado:
// service.images = [
//   'https://res.cloudinary.com/.../img1.jpg',
//   'https://res.cloudinary.com/.../img2.jpg',
//   'https://res.cloudinary.com/.../img3.jpg',
// ]
```

### Actualizar Servicio (agregar/quitar imágenes)
```dart
// El servicio tiene 2 imágenes
// oldImages = ['url1', 'url2']

// Usuario quiere:
// - Mantener 'url1'
// - Eliminar 'url2'
// - Agregar nueva imagen local

await updateService(
  serviceId: service.id,
  imagePaths: [
    'url1', // Mantener (es URL)
    '/storage/new_image.jpg', // Agregar (es ruta local)
  ],
);

// El datasource:
// 1. Elimina 'url2' (no está en la nueva lista)
// 2. Mantiene 'url1' (ya es URL)
// 3. Sube '/storage/new_image.jpg' a Cloudinary
```

## 🐛 Manejo de Errores

### Errores Comunes
1. **Archivo muy grande**: >5MB
2. **Formato no soportado**: GIF, BMP, etc.
3. **Límite excedido**: >5 imágenes
4. **Sin permisos**: Usuario no es el dueño del servicio
5. **Servicio no existe**: ID inválido

### Estrategia
```dart
for (final imagePath in imagePaths) {
  try {
    final imageUrl = await uploadServiceImage(...);
    uploadedImageUrls.add(imageUrl);
  } catch (e) {
    print('Error subiendo imagen: $e');
    // NO romper el proceso completo
    // Continuar con las demás imágenes
  }
}
```

## 📊 Indicador de Progreso

El BLoC emite estados con progreso de subida:

```dart
class ServiceFormSubmitting extends ServiceFormState {
  final int? uploadingImageIndex; // Índice actual (0, 1, 2...)
  final int? totalImages;         // Total a subir (3)
}
```

UI muestra:
```
Subiendo imagen 2 de 3...
[=========>     ] 66%
```

## 🔐 Seguridad

### Headers Automáticos
Dio agrega automáticamente el token de autenticación:
```dart
headers: {
  'Authorization': 'Bearer eyJhbGc...',
  'Content-Type': 'multipart/form-data',
}
```

### Validación Backend
- Solo el proveedor dueño puede subir imágenes
- Se valida el token JWT en cada request
- Se verifican permisos antes de procesar el archivo

## 🚀 Modo MOCK vs REAL

### MOCK (sin conexión a backend)
```dart
if (_dio == null) {
  // Simular subida
  await Future.delayed(const Duration(milliseconds: 800));
  return 'https://res.cloudinary.com/demo/...';
}
```

### REAL (con backend)
```dart
final response = await _dio.post('/services/$id/images', ...);
return response.data['images'].last;
```

## 📱 Ejemplo Completo en UI

```dart
// 1. Usuario toca "Agregar imagen"
onTap: () async {
  final XFile? image = await ImagePicker().pickImage(
    source: ImageSource.gallery,
    maxWidth: 1920,
    maxHeight: 1080,
    imageQuality: 85,
  );
  
  if (image != null) {
    // 2. Agregar al estado del formulario
    context.read<ServiceFormBloc>().add(
      ImageAdded(image.path)
    );
  }
}

// 3. Al guardar el servicio
onPressed: () {
  context.read<ServiceFormBloc>().add(SubmitForm());
}

// 4. El BLoC:
// - Crea el servicio
// - Sube las imágenes (con progreso)
// - Emite ServiceFormSuccess

// 5. UI navega de vuelta con resultado
Navigator.pop(context, true);
```

## 📚 Referencias

- **Backend**: `upload.controller.ts`
- **Cloudinary Docs**: https://cloudinary.com/documentation
- **Dio Multipart**: https://pub.dev/packages/dio#formdata
- **Image Picker**: https://pub.dev/packages/image_picker
