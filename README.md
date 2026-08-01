# DSD-Neo Ventas Mobile Portal

Esta es una aplicación móvil desarrollada en Flutter diseñada para la integración y sincronización de pedidos de venta en terreno con el ERP REST de Ventas de DSD-Neo.

## Arquitectura y Tecnologías
- **Core:** Flutter 3.38.x & Dart 3.10.x
- **Gestión de Estado:** `provider` (MultiProvider)
- **Persistencia de Sesión & Ajustes:** `shared_preferences`
- **Integración de Red:** `http` con control exhaustivo de códigos de error (400, 401, 404, 500)
- **Formateo:** `intl` para el manejo localizado de monedas (CLP/USD) e interpolación de fechas.

## Estructura de Directorios (lib/)
```text
lib/
├── main.dart                  # Punto de entrada de la aplicación y configuración de temas
├── config/
│   └── api_config.dart        # Gestión y persistencia de URL Base y API Key
├── models/
│   ├── user.dart              # Datos de perfil del usuario logueado
│   ├── sale.dart              # Resumen del listado de ventas
│   ├── sale_detail.dart       # Detalles, artículos y bodega de un pedido
│   └── checkout_payload.dart  # Payload estructurado para inyectar pedidos
├── services/
│   ├── auth_service.dart      # Autenticación móvil y lógica de guardado de sesiones
│   └── api_service.dart       # Consultas REST y validación de códigos HTTP
├── providers/
│   ├── auth_provider.dart     # Proveedor de estado global de sesión de usuario
│   └── sales_provider.dart    # Proveedor de estado de listados, filtros y operaciones de venta
├── screens/
│   ├── login_screen.dart      # Inicio de sesión con validación
│   ├── register_screen.dart   # Registro dinámico de nuevas credenciales
│   ├── forgot_password_screen.dart  # Formulario de recuperación de clave
│   ├── sales_list_screen.dart  # Listado de pedidos, scroll infinito, pull-to-refresh y Drawer
│   ├── sale_detail_screen.dart # Detalle de artículos, impuestos, anulación y cambio de estado
│   ├── checkout_screen.dart   # POS móvil para crear pedidos con presets de prueba
│   ├── settings_screen.dart   # Ajustes de URL Base y API Key con test de conexión
│   ├── about_screen.dart      # Acerca de la App
│   └── terms_policies_screen.dart # Términos de servicio y políticas de seguridad
└── widgets/
    ├── status_badge.dart      # Etiquetas para estados de venta y pago
    ├── sale_card.dart         # Tarjetas premium para la lista de pedidos
    └── error_view.dart        # Feedback visual y reintentos ante desconexión
```

## Configuración y Ejecución rápida

### 1. Descargar dependencias
Desde la raíz del proyecto, ejecute en su terminal:
```bash
flutter pub get
```

### 2. Ejecutar análisis estático (Verificación de calidad)
Para cerciorarse de que no existan advertencias ni lints:
```bash
flutter analyze
```

### 3. Iniciar la aplicación
Ejecute la app en su emulador o dispositivo físico conectado:
```bash
flutter run
```

---

## Nota de Tráfico Cleartext (HTTP sin cifrado)
La API utiliza por defecto un protocolo sin cifrado (`http://`). Para evitar bloqueos de red en dispositivos móviles reales o emuladores:

### Android
En [AndroidManifest.xml](file:///d:/github/app_post_master/android/app/src/main/AndroidManifest.xml) asegúrese de que el tag `<application>` incluya:
```xml
android:usesCleartextTraffic="true"
```

### iOS
En [Info.plist](file:///d:/github/app_post_master/ios/Runner/Info.plist) agregue:
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```
