Service Marketplace es una plataforma que conecta personas que necesitan servicios (clientes) con profesionales que los ofrecen (proveedores) en su área local. Piensa en una combinación de Uber + TaskRabbit + Mercado Libre para servicios.

App Móvil (Flutter) - Lo que ve el usuario
Para Clientes:

Buscar servicios cercanos (según radio definido por cada proveedor)
Ver perfiles de proveedores con calificaciones y trabajos previos
Solicitar un servicio con fecha/hora
Chatear en tiempo real con el proveedor
Recibir notificaciones cuando aceptan tu solicitud
Calificar el servicio recibido

Para Proveedores:

Crear perfil profesional con portfolio de servicios
Publicar servicios que ofrecen con fotos y precios
Recibir solicitudes de clientes cercanos
Aceptar/rechazar trabajos según disponibilidad
Chatear con clientes para coordinar detalles
Gestionar agenda de trabajos
Construir reputación con calificaciones
Definir radio de cobertura para cada servicio


## Arquitectura DDD + BLoC - Estructura del proyecto

lib/
├── core/
│   ├── constants/
│   │   ├── api_constants.dart (URLs del backend)
│   │   ├── app_colors.dart
│   │   ├── app_strings.dart
│   │   └── app_routes.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   └── text_styles.dart
│   ├── utils/
│   │   ├── validators.dart
│   │   ├── date_formatter.dart
│   │   └── location_helper.dart
│   ├── errors/
│   │   ├── failures.dart
│   │   └── exceptions.dart
│   └── network/
│       ├── api_client.dart (Dio)
│       └── network_info.dart (conectividad)
│
├── features/
│   ├── auth/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart (interface)
│   │   │   └── usecases/
│   │   │       ├── login_usecase.dart
│   │   │       ├── register_usecase.dart
│   │   │       ├── logout_usecase.dart
│   │   │       └── get_current_user_usecase.dart
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── user_model.dart
│   │   │   ├── datasources/
│   │   │   │   ├── auth_remote_datasource.dart
│   │   │   │   └── auth_local_datasource.dart (SharedPreferences)
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── auth_bloc.dart
│   │       │   ├── auth_event.dart
│   │       │   └── auth_state.dart
│   │       ├── pages/
│   │       │   ├── splash_page.dart
│   │       │   ├── onboarding_page.dart
│   │       │   ├── login_page.dart
│   │       │   ├── register_page.dart
│   │       │   └── profile_page.dart
│   │       └── widgets/
│   │           ├── custom_text_field.dart
│   │           ├── role_selector.dart
│   │           └── profile_avatar.dart
│   │
│   ├── services/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── service.dart
│   │   │   │   └── category.dart
│   │   │   ├── repositories/
│   │   │   │   └── services_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_services_usecase.dart
│   │   │       ├── create_service_usecase.dart
│   │   │       ├── update_service_usecase.dart
│   │   │       ├── delete_service_usecase.dart
│   │   │       └── search_services_usecase.dart
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── service_model.dart
│   │   │   │   └── category_model.dart
│   │   │   ├── datasources/
│   │   │   │   └── services_remote_datasource.dart
│   │   │   └── repositories/
│   │   │       └── services_repository_impl.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── services_list_bloc/ (lista de servicios)
│   │       │   ├── service_detail_bloc/ (detalle)
│   │       │   └── service_form_bloc/ (crear/editar)
│   │       ├── pages/
│   │       │   ├── services_list_page.dart
│   │       │   ├── service_detail_page.dart
│   │       │   ├── create_service_page.dart
│   │       │   └── edit_service_page.dart
│   │       └── widgets/
│   │           ├── service_card.dart
│   │           ├── category_filter.dart
│   │           ├── service_images_carousel.dart
│   │           └── rating_display.dart
│   │
│   ├── appointments/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── appointment.dart
│   │   │   ├── repositories/
│   │   │   │   └── appointments_repository.dart
│   │   │   └── usecases/
│   │   │       ├── create_appointment_usecase.dart
│   │   │       ├── get_appointments_usecase.dart
│   │   │       ├── accept_appointment_usecase.dart
│   │   │       ├── reject_appointment_usecase.dart
│   │   │       ├── complete_appointment_usecase.dart
│   │   │       └── cancel_appointment_usecase.dart
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── appointment_model.dart
│   │   │   ├── datasources/
│   │   │   │   └── appointments_remote_datasource.dart
│   │   │   └── repositories/
│   │   │       └── appointments_repository_impl.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── appointments_list_bloc/
│   │       │   ├── appointment_detail_bloc/
│   │       │   └── appointment_form_bloc/
│   │       ├── pages/
│   │       │   ├── appointments_list_page.dart
│   │       │   ├── appointment_detail_page.dart
│   │       │   └── create_appointment_page.dart
│   │       └── widgets/
│   │           ├── appointment_card.dart
│   │           ├── appointment_status_badge.dart
│   │           └── appointment_actions.dart
│   │
│   ├── reviews/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── review.dart
│   │   │   ├── repositories/
│   │   │   │   └── reviews_repository.dart
│   │   │   └── usecases/
│   │   │       ├── create_review_usecase.dart
│   │   │       ├── get_provider_reviews_usecase.dart
│   │   │       └── delete_review_usecase.dart
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── review_model.dart
│   │   │   ├── datasources/
│   │   │   │   └── reviews_remote_datasource.dart
│   │   │   └── repositories/
│   │   │       └── reviews_repository_impl.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── reviews_list_bloc/
│   │       │   └── review_form_bloc/
│   │       ├── pages/
│   │       │   ├── reviews_list_page.dart
│   │       │   └── create_review_page.dart
│   │       └── widgets/
│   │           ├── review_card.dart
│   │           ├── rating_input.dart
│   │           └── rating_summary.dart
│   │
│   ├── chat/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── message.dart
│   │   │   │   └── chat_room.dart
│   │   │   ├── repositories/
│   │   │   │   └── chat_repository.dart
│   │   │   └── usecases/
│   │   │       ├── send_message_usecase.dart
│   │   │       ├── get_messages_usecase.dart
│   │   │       ├── connect_socket_usecase.dart
│   │   │       └── mark_as_read_usecase.dart
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── message_model.dart
│   │   │   ├── datasources/
│   │   │   │   ├── chat_remote_datasource.dart
│   │   │   │   └── chat_socket_datasource.dart (Socket.IO)
│   │   │   └── repositories/
│   │   │       └── chat_repository_impl.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── chat_bloc/
│   │       │   └── chat_list_bloc/
│   │       ├── pages/
│   │       │   ├── chat_list_page.dart
│   │       │   └── chat_page.dart
│   │       └── widgets/
│   │           ├── message_bubble.dart
│   │           ├── message_input.dart
│   │           └── chat_list_item.dart
│   │
│   ├── home/
│   │   └── presentation/
│   │       ├── pages/
│   │       │   └── home_page.dart (bottom navigation)
│   │       └── widgets/
│   │           └── bottom_nav_bar.dart
│   │
│   └── notifications/
│       ├── domain/
│       │   ├── entities/
│       │   │   └── notification.dart
│       │   ├── repositories/
│       │   │   └── notifications_repository.dart
│       │   └── usecases/
│       │       ├── register_fcm_token_usecase.dart
│       │       ├── get_notifications_usecase.dart
│       │       └── mark_notification_read_usecase.dart
│       ├── data/
│       │   ├── models/
│       │   │   └── notification_model.dart
│       │   ├── datasources/
│       │   │   ├── notifications_remote_datasource.dart
│       │   │   └── fcm_datasource.dart (Firebase)
│       │   └── repositories/
│       │       └── notifications_repository_impl.dart
│       └── presentation/
│           ├── bloc/
│           │   └── notifications_bloc/
│           ├── pages/
│           │   └── notifications_page.dart
│           └── widgets/
│               └── notification_item.dart
│
└── main.dart




Pantallas de la aplicación
FASE 1: Autenticación y Onboarding
⬜ 1. Splash Screen

Logo de la app
Verificar si hay sesión activa
Redirigir a Home o Login

⬜ 2. Onboarding (primera vez)

3-4 slides explicando la app
Beneficios para clientes
Beneficios para proveedores
Botón "Empezar"

⬜ 3. Login

Email
Password
Botón "Iniciar sesión"
Link "¿No tenés cuenta? Registrate"
Link "¿Olvidaste tu contraseña?"

⬜ 4. Registro

Paso 1: Email, Password, Confirmar password
Paso 2: Nombre completo, Teléfono
Paso 3: Elegir rol (Cliente o Proveedor)
Paso 4: Ubicación (permitir GPS o ingresar manualmente)
Paso 5: Foto de perfil (opcional)
Botón "Crear cuenta"


FASE 2: Home y Navegación Principal
✅ 5. Home (Bottom Navigation con 4-5 tabs)
Para CLIENTES:

Tab 1: Explorar (buscar servicios)
Tab 2: Mis Citas (appointments)
Tab 3: Chat (mensajes)
Tab 4: Perfil
Tab 5: Notificaciones (opcional, puede ser ícono en AppBar)

Para PROVEEDORES:

Tab 1: Mis Servicios (servicios publicados)
Tab 2: Solicitudes (appointments pendientes)
Tab 3: Agenda (appointments aceptados)
Tab 4: Chat (mensajes)
Tab 5: Perfil


FASE 3: Funcionalidad por Rol

👤 PANTALLAS PARA CLIENTES
⬜ 6. Explorar Servicios

Barra de búsqueda
Filtros: Categoría, Cobertura sugerida, Rating, Precio
Grid/Lista de servicios con:

Foto del servicio
Nombre del proveedor
Rating (estrellas + número de reviews)
Precio aproximado
Cobertura confirmada ("Estás dentro de 5 km del proveedor")


Al tocar → ver detalle

⬜ 7. Detalle de Servicio

Carousel de imágenes
Nombre del servicio
Descripción completa
Precio
Información del proveedor:

Foto, nombre, rating
Botón "Ver perfil"


Reviews de otros clientes
Botón principal: "Solicitar servicio"
Botón secundario: "Chatear"

⬜ 8. Perfil de Proveedor

Foto grande
Nombre, rating promedio
Ubicación aproximada
Tiempo en la plataforma
Todos sus servicios publicados
Lista completa de reviews
Badges/logros (opcional: "100 trabajos completados")

⬜ 9. Crear Solicitud de Servicio

Servicio seleccionado (read-only)
Fecha y hora deseada (DateTimePicker)
Descripción del problema/necesidad (TextArea)
Ubicación del servicio:

Usar ubicación actual
Ingresar dirección manualmente
Seleccionar en mapa


Presupuesto estimado (opcional)
Botón "Enviar solicitud"

⬜ 10. Mis Citas (Cliente)

Tabs:

Pendientes: Esperando respuesta del proveedor
Confirmadas: Proveedor aceptó, fecha programada
En curso: Servicio comenzó
Completadas: Servicio finalizado
Canceladas


Cada cita muestra:

Servicio, proveedor, fecha, estado
Acciones según estado


Al tocar → Detalle de cita

⬜ 11. Detalle de Cita (Cliente)

Estado actual con timeline visual
Información del servicio
Información del proveedor
Fecha y hora
Ubicación en mapa
Descripción de la solicitud
Precio acordado (si hay)
Acciones según estado:

PENDING: "Cancelar solicitud"
ACCEPTED: "Ver en mapa", "Chatear", "Cancelar"
IN_PROGRESS: "Contactar proveedor"
COMPLETED: "Calificar servicio"


Botón de chat siempre visible

⬜ 12. Calificar Servicio

Rating con estrellas (1-5)
Comentario (opcional)
Fotos del resultado (opcional)
Botón "Enviar calificación"


🛠️ PANTALLAS PARA PROVEEDORES
✅ 13. Mis Servicios

Lista de servicios publicados
Cada servicio muestra:

Foto, nombre, precio, rating
Estado: Activo/Pausado


FAB (Floating Action Button): "Agregar servicio"
Al tocar → Editar servicio
Swipe para eliminar

✅ 14. Crear/Editar Servicio

Título del servicio
Categoría (dropdown)
Descripción detallada
Precio (opcional, puede ser "A convenir")
Radio de cobertura (km)
Subir hasta 5 fotos
Botón "Publicar" / "Guardar cambios"

⬜ 15. Solicitudes (Provider)

Lista de solicitudes PENDING
Cada solicitud muestra:

Cliente (nombre, foto, rating si tiene)
Servicio solicitado
Fecha/hora deseada
Ubicación y distancia
Vista previa de descripción


Al tocar → Detalle de solicitud

⬜ 16. Detalle de Solicitud (Provider)

Información del cliente
Servicio solicitado
Fecha y hora deseada
Ubicación en mapa con ruta
Descripción completa del cliente
Historial del cliente (cuántos servicios contrató)
Botones principales:

"Aceptar solicitud"
"Rechazar"
"Chatear para más detalles"

⬜ 17. Agenda (Provider)

Vista de calendario
Appointments aceptados por fecha
Vista día/semana/mes
Al tocar fecha → Lista de citas ese día
Colores según estado:

Azul: ACCEPTED (confirmado)
Verde: IN_PROGRESS
Gris: COMPLETED

⬜ 18. Detalle de Cita (Provider)

Similar a la del cliente pero desde perspectiva del proveedor
Información del cliente
Ubicación con botón "Cómo llegar" (abre Google Maps)
Acciones según estado:

ACCEPTED: "Iniciar servicio", "Cancelar"
IN_PROGRESS: "Marcar como completado"
COMPLETED: Ver review del cliente (si dejó)


Botón de chat siempre visible


💬 PANTALLAS COMUNES (AMBOS ROLES)
⬜ 19. Lista de Chats

Conversaciones activas
Cada chat muestra:

Foto y nombre de la otra persona
Último mensaje
Timestamp
Badge de mensajes no leídos
Appointment relacionado (pequeño tag)


Ordenados por último mensaje

⬜ 20. Chat Individual

Mensajes en burbujas
Propio mensaje: alineado derecha, color azul
Mensaje del otro: alineado izquierda, color gris
Timestamp de cada mensaje
Indicador "escribiendo..."
Input de texto con botón enviar
Header muestra:

Foto y nombre de la otra persona
Estado online/offline (opcional)
Botón para ir al appointment relacionado

⬜ 21. Perfil (Usuario actual)

Foto de perfil (tap para cambiar)
Nombre, email, teléfono
Ubicación guardada
Rol (Cliente/Proveedor)
Si es proveedor: Rating y total de trabajos
Opciones:

Editar perfil
Cambiar contraseña
Configuración de notificaciones
Ayuda y soporte
Términos y condiciones
Cerrar sesión



⬜ 22. Editar Perfil

Cambiar foto
Nombre, teléfono
Actualizar ubicación
Guardar cambios

⬜ 23. Notificaciones

Lista de notificaciones recibidas
Tabs: Todas / No leídas
Cada notificación:

Ícono según tipo
Título y mensaje
Timestamp
Al tocar → Navega a la pantalla relevante


Marcar todas como leídas

⬜ 24. Configuración

Notificaciones push (on/off)
Notificaciones de chat (on/off)
Solo notificaciones importantes
Modo no molestar
Idioma (futuro)
Tema claro/oscuro
Acerca de la app
Versión


🔄 Flujos principales de la aplicación
Flujo 1: Cliente busca y contrata un servicio
1. Cliente abre app → Pantalla Explorar
2. Busca "plomero" o filtra por categoría
3. Ve lista de servicios → Toca uno
4. Pantalla Detalle de Servicio
5. Ve info, fotos, reviews → Decide contratar
6. Toca "Solicitar servicio"
7. Pantalla Crear Solicitud
8. Completa: fecha, hora, descripción, ubicación
9. Envía solicitud
10. Pantalla Mis Citas → Aparece como PENDING
11. Recibe notificación push: "Juan aceptó tu solicitud"
12. Pantalla actualiza estado a ACCEPTED
13. Puede chatear con Juan para coordinar
14. Día del servicio: Juan marca como IN_PROGRESS
15. Termina: Juan marca COMPLETED
16. Cliente recibe notificación: "Califica el servicio"
17. Pantalla Calificar → Deja 5 estrellas y comentario
18. Flujo completo ✅

Flujo 2: Proveedor recibe y completa trabajo
1. Proveedor recibe notificación push: "Nueva solicitud de trabajo"
2. Abre app → Pantalla Solicitudes
3. Ve solicitud de María
4. Toca → Pantalla Detalle de Solicitud
5. Lee descripción, ve ubicación, revisa fecha
6. Decide aceptar → Toca "Aceptar solicitud"
7. Solicitud pasa a Pantalla Agenda
8. Puede chatear con María si necesita más detalles
9. Día del servicio: Va a la ubicación
10. Toca "Iniciar servicio" → Estado IN_PROGRESS
11. Realiza el trabajo
12. Termina → Toca "Marcar como completado"
13. Recibe notificación: "María te calificó con 5 estrellas"
14. Su rating promedio se actualiza
15. Flujo completo ✅

Flujo 3: Conversación por chat
1. Cliente en Detalle de Servicio → Toca "Chatear"
2. Si no hay appointment creado, le pide crear solicitud primero
3. Una vez hay appointment → Abre chat
4. Cliente escribe: "¿Podés el sábado en vez del viernes?"
5. Mensaje se envía vía WebSocket
6. Proveedor recibe notificación push
7. Abre app → Chat ya tiene el mensaje
8. Proveedor responde: "Sí, sin problema"
9. Cliente recibe notificación
10. Conversación fluye en tiempo real
11. Ambos pueden ver historial completo

