# Clarity Software

**Una visión compartida del avance de cada proyecto.**

Aplicación académica construida con Flutter, Dart y Firebase para facilitar el seguimiento de proyectos entre administradores y clientes. Reúne avances, hitos, conversación y documentación en una misma experiencia.

[Ver el caso de Clarity en el portafolio](https://darouji.github.io/#clarity)

**Estado:** prototipo académico. El código incluye funcionalidades conectadas a Firebase y áreas todavía incompletas. No se presenta como una aplicación validada en producción ni como un servicio de firma electrónica certificada.

## El problema

Cuando el estado de un proyecto queda repartido entre mensajes, archivos y reuniones, al cliente le cuesta saber qué se está haciendo y qué falta por completar. Clarity propone un espacio común para visualizar el avance y mantener la comunicación.

## Funcionalidades presentes en el código

| Área | Implementación |
| --- | --- |
| Acceso | Inicio de sesión mediante Firebase Authentication y Google Sign-In |
| Roles | Vistas diferenciadas de Administrador y Cliente |
| Proyectos | Listas, tablero Kanban, línea de tiempo e hitos |
| Seguimiento | Actualizaciones mediante streams de Cloud Firestore |
| Comunicación | Chat, comentarios y notificaciones dentro de la aplicación |
| Documentos | Servicios para adjuntar archivos mediante Firebase Storage |
| Agenda | Vistas y servicios de reservas y citas |
| Firma | Interfaz de captura manuscrita; la persistencia de esa pantalla está pendiente |
| Interfaz | Componentes reutilizables y temas claro/oscuro |

## Contexto y contribución

Proyecto académico desarrollado durante la formación de **Fabián García Ríos** en CEDUC UCN, Antofagasta. El trabajo aborda diseño de pantallas, organización de modelos/servicios, flujos por rol e integración con Firebase. Las funcionalidades se describen por lo observable en el repositorio, sin inventar métricas de adopción o uso productivo.

## Tecnologías

Flutter · Dart · Firebase Authentication · Cloud Firestore · Firebase Storage · Provider.

Las restricciones de versión están en `pubspec.yaml` y las dependencias resueltas en `pubspec.lock`. Aunque Flutter permite varios destinos, cada plataforma necesita configuración y validación específicas; este repositorio no acredita que todas hayan sido probadas.

## Estructura

```text
lib/
  models/       # Proyectos, usuarios, hitos, documentos y mensajes
  services/     # Autenticación, Firestore, Storage y preferencias
  screens/      # Vistas de administrador, cliente y compartidas
  widgets/      # Tableros, gráficos, calendarios y componentes
  theme/        # Colores y temas de la aplicación
test/           # Prueba de widget existente (requiere adaptar Firebase)
```

## Ejecutar en desarrollo

1. Instala Flutter y verifica el entorno con `flutter doctor`.
2. Clona este repositorio y ejecuta `flutter pub get`.
3. Crea un proyecto **Firebase de desarrollo independiente**, sin datos personales reales.
4. Configura las plataformas que vayas a ejecutar mediante FlutterFire CLI, siguiendo la [guía oficial de Firebase para Flutter](https://firebase.google.com/docs/flutter/setup).
5. El punto de entrada actual llama a `Firebase.initializeApp()` sin opciones explícitas. Para los destinos que las requieran, importa el archivo local generado `firebase_options.dart` y utiliza `DefaultFirebaseOptions.currentPlatform`, tal como indica la guía oficial.
6. Configura Authentication, Firestore y Storage. Aplica y prueba reglas de acceso por propietario y rol **antes de conectar usuarios reales**. Las reglas desplegadas no forman parte de este repositorio y no han sido auditadas aquí.
7. Ejecuta `flutter run` para tu dispositivo configurado.

No se incluyen cuentas compartidas, contraseñas ni archivos de configuración de un proyecto Firebase real. No asignes privilegios de administrador desde un cliente no confiable.

## Validación y límites conocidos

```sh
flutter analyze
flutter test
```

Estos comandos son el flujo de validación previsto; no se afirma que la suite actual pase. La prueba existente necesita inicializar o simular Firebase y aislar servicios externos. La revisión de presentación del repositorio no incluyó ejecutar Flutter.

Pendientes identificados:

- Persistir la firma capturada: la pantalla actual dibuja la firma, pero no completa su carga a Storage.
- Completar métodos auxiliares vacíos en los servicios de proyectos y usuarios.
- Sustituir mensajes de depuración por registros adecuados.
- Verificar reglas de Firestore/Storage, pruebas con emuladores y permisos de cada rol.
- Revisar compatibilidad por plataforma: algunos servicios utilizan `dart:io`.

## Seguridad, privacidad y uso

Consulta [SECURITY.md](SECURITY.md). Los archivos Firebase de cliente no son equivalentes a claves privadas de servicio; la protección de datos depende de reglas y controles de acceso, no de esconder la configuración.

No se ha concedido una licencia de código abierto. Las dependencias mantienen sus propias licencias.

**Autor:** [Fabián García Ríos](https://github.com/Darouji) · [LinkedIn](https://www.linkedin.com/in/fabian-garcia-55641333b/)
