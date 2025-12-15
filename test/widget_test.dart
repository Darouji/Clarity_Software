// test/widget_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:clarity_software/main.dart';
import 'package:clarity_software/screens/login_screen.dart';
import 'package:clarity_software/services/mock_api_service.dart';
import 'package:clarity_software/services/feedback_notification_service.dart';

void main() {
  testWidgets('La aplicación carga correctamente y muestra el Login', (
    WidgetTester tester,
  ) async {
    // 1. Inicialización de Servicios (Mock)
    // Al igual que en el main.dart real, debemos inicializar los servicios
    // antes de construir el widget principal para evitar errores de nulidad.
    await MockApiService().init();
    await FeedbackNotificationService().init();

    // 2. Construir la aplicación (Pump Widget)
    // Usamos ClaritySoftware en lugar de MyApp
    await tester.pumpWidget(const ClaritySoftware());

    // 3. Esperar a que terminen las animaciones o cargas iniciales (si las hay)
    await tester.pumpAndSettle();

    // 4. Verificaciones (Asserts)
    // Verificamos que se esté mostrando la pantalla de Login
    expect(find.byType(LoginScreen), findsOneWidget);

    // Opcional: Verificar que el título de la app (si aparece en texto) está presente.
    // expect(find.text('Clarity Software'), findsOneWidget);
  });
}
