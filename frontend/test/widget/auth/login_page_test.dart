import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:unidad_educatica_frontend/features/auth/ui/login_page.dart';
import 'package:unidad_educatica_frontend/state/auth_provider.dart';
import 'package:unidad_educatica_frontend/core/storage.dart';

// Simplified mock for widget test
class MockTokenStorage extends Mock implements TokenStorage {
  @override
  Future<String?> readToken() => super.noSuchMethod(Invocation.method(#readToken, []), returnValue: Future.value(null));
}

void main() {
  testWidgets('LoginPage renders correctly', (WidgetTester tester) async {
    final mockStorage = MockTokenStorage();
    final authProvider = AuthProvider(storage: mockStorage);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: authProvider,
        child: const MaterialApp(
          home: LoginPage(),
        ),
      ),
    );

    // Verify title in AppBar
    expect(find.text('Iniciar Sesión'), findsOneWidget);
    
    // Verify TextFields
    expect(find.widgetWithText(TextField, 'Correo'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Contraseña'), findsOneWidget);
    
    // Verify Button
    expect(find.text('Ingresar'), findsOneWidget);
  });
}
