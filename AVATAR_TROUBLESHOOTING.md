# Guía de Solución de Problemas - Sistema de Avatares

## Error 404 al Subir Avatar

### Descripción del Problema
El error 404 indica que el endpoint `/upload/avatar` no existe o no está disponible en el servidor backend.

### Posibles Causas

#### 1. **El Endpoint No Está Implementado en el Backend**
El servidor backend necesita tener implementada la ruta `POST /upload/avatar`.

**Solución:**
Verifica que el backend tenga esta ruta configurada. Debe aceptar:
```
POST http://192.168.18.43:3000/upload/avatar
Headers:
  - Authorization: Bearer {token}
  - Content-Type: multipart/form-data
Body:
  - file: (archivo de imagen)
```

#### 2. **La Ruta en el Backend es Diferente**
Puede que el endpoint en el backend tenga un nombre o estructura diferente.

**Rutas comunes alternativas:**
- `POST /api/upload/avatar`
- `POST /users/avatar`
- `POST /user/avatar/upload`
- `POST /api/v1/upload/avatar`

**Solución:**
Verifica la documentación del backend o revisa el código del servidor para confirmar la ruta exacta.

#### 3. **Falta Prefijo `/api` en la URL Base**
Si el backend usa prefijo `/api` para todas las rutas:

**Solución:**
Actualiza `api_constants.dart`:
```dart
static const String baseUrl = 'http://192.168.18.43:3000/api/';
```

O actualiza el datasource:
```dart
final response = await _dio.post(
  '/api/upload/avatar',  // ← Agregar /api
  data: formData,
  ...
);
```

#### 4. **El Servidor No Está Ejecutándose**
El backend podría no estar activo o no responde en el puerto 3000.

**Solución:**
1. Verifica que el servidor backend esté ejecutándose
2. Confirma que está escuchando en el puerto 3000
3. Prueba acceder a otras rutas del backend para verificar conectividad

#### 5. **Middleware de Autenticación Rechaza la Petición**
El token JWT podría no estar siendo enviado correctamente.

**Solución:**
Verifica que el token se esté enviando en los headers. Revisa la configuración de Dio en `api_client.dart`.

## Cómo Verificar el Problema

### Paso 1: Probar con Postman/Thunder Client
Prueba el endpoint directamente:

```http
POST http://192.168.18.43:3000/upload/avatar
Authorization: Bearer {tu_token_jwt}
Content-Type: multipart/form-data

Body (form-data):
file: [selecciona un archivo de imagen]
```

### Paso 2: Revisar Logs del Backend
Verifica los logs del servidor backend cuando intentas subir el avatar. Busca:
- Si la petición está llegando
- Qué error específico está reportando
- Si la ruta está registrada

### Paso 3: Revisar Logs de la App Flutter
La app ahora imprime información de debug. Busca en la consola:
```
Intentando subir avatar desde: [ruta]
Enviando petición a: /upload/avatar
Error DioException: 404
Mensaje de error: [detalles]
```

### Paso 4: Verificar Rutas Disponibles en el Backend
Lista todas las rutas disponibles en tu backend. En Express/NestJS:

**Express:**
```javascript
app._router.stack.forEach(function(r){
  if (r.route && r.route.path){
    console.log(r.route.path)
  }
})
```

**NestJS:**
```typescript
// En main.ts después de crear la app
const server = app.getHttpServer();
const router = server._events.request._router;
// Ver rutas registradas
```

## Soluciones Rápidas

### Solución 1: Actualizar la Ruta en Flutter
Si el endpoint en el backend es diferente:

```dart
// En auth_remote_datasource.dart
final response = await _dio.post(
  '/api/upload/avatar',  // ← Actualiza la ruta correcta
  data: formData,
  ...
);
```

### Solución 2: Implementar el Endpoint en el Backend
Si el endpoint no existe, necesitas implementarlo en el backend.

**Ejemplo en NestJS:**
```typescript
@Post('upload/avatar')
@UseGuards(JwtAuthGuard)
@UseInterceptors(FileInterceptor('file'))
async uploadAvatar(
  @UploadedFile() file: Express.Multer.File,
  @Req() req: any,
) {
  // Validar archivo
  if (!file) {
    throw new BadRequestException('No se envió ninguna imagen');
  }
  
  // Validar tamaño (5MB)
  if (file.size > 5 * 1024 * 1024) {
    throw new BadRequestException('Archivo debe ser menor a 5MB');
  }
  
  // Validar formato
  const allowedFormats = ['image/jpeg', 'image/png', 'image/webp'];
  if (!allowedFormats.includes(file.mimetype)) {
    throw new BadRequestException('Formato no permitido');
  }
  
  // Subir a Cloudinary (ejemplo)
  const result = await cloudinary.uploader.upload(file.path, {
    folder: 'service-marketplace/avatars',
  });
  
  // Actualizar usuario en base de datos
  await this.usersService.updateAvatar(req.user.id, result.secure_url);
  
  return {
    message: 'Avatar actualizado exitosamente',
    avatarUrl: result.secure_url,
  };
}
```

### Solución 3: Verificar Configuración de CORS
Si el problema es CORS:

**En el backend (NestJS):**
```typescript
app.enableCors({
  origin: true,
  credentials: true,
});
```

**En Express:**
```javascript
const cors = require('cors');
app.use(cors({
  origin: '*',
  credentials: true,
}));
```

## Mensajes de Error Mejorados

La aplicación ahora muestra mensajes más amigables según el tipo de error:

| Código | Mensaje para el Usuario |
|--------|------------------------|
| 404 | "El servicio de subida de imágenes no está disponible en este momento" |
| 400 | "El archivo seleccionado no es válido" |
| 401 | "Tu sesión ha expirado. Por favor, cierra sesión y vuelve a iniciar" |
| 413 | "La imagen es demasiado grande" |
| 500 | "Error en el servidor. Por favor, intenta nuevamente en unos momentos" |
| Timeout | "La conexión está tardando mucho. Verifica tu conexión a internet" |
| Connection Error | "No se pudo conectar con el servidor. Verifica tu conexión a internet" |

## Pruebas Recomendadas

1. **Probar endpoint directamente con Postman**
2. **Verificar logs del backend**
3. **Confirmar que otras rutas funcionan (login, register)**
4. **Verificar que el token JWT se está enviando**
5. **Revisar la documentación del backend**

## Contacto con el Equipo Backend

Si el problema persiste, proporciona al equipo backend:

1. **URL completa que se está intentando:** `http://192.168.18.43:3000/upload/avatar`
2. **Método HTTP:** POST
3. **Headers enviados:** Authorization (Bearer token), Content-Type (multipart/form-data)
4. **Body:** FormData con campo "file"
5. **Código de error recibido:** 404
6. **Logs de la app Flutter** (ver consola)

## Configuración Actual

**URL Base:**
```dart
static const String baseUrl = 'http://192.168.18.43:3000/';
```

**Endpoint completo:**
```
http://192.168.18.43:3000/upload/avatar
```

**Formato esperado de respuesta:**
```json
{
  "message": "Avatar actualizado exitosamente",
  "avatarUrl": "https://res.cloudinary.com/..."
}
```
