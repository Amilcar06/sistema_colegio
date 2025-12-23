import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:unidad_educatica_frontend/state/auth_provider.dart';
import 'package:unidad_educatica_frontend/core/storage.dart';

@GenerateMocks([TokenStorage])
import 'auth_provider_test.mocks.dart';

void main() {
  late AuthProvider authProvider;
  late MockTokenStorage mockStorage;

  setUp(() {
    mockStorage = MockTokenStorage();
    authProvider = AuthProvider(storage: mockStorage);
  });

  group('AuthProvider Tests', () {
    test('Initial state should be unauthenticated', () {
      expect(authProvider.isAuthenticated, false);
      expect(authProvider.token, null);
      expect(authProvider.rol, null);
    });

    test('Login should update state and save token', () async {
      const token = 'valid_token';
      const rol = 'ADMIN';

      // Stub saveToken to return void future
      when(mockStorage.saveToken(token)).thenAnswer((_) async {});

      await authProvider.login(token, rol);

      expect(authProvider.token, token);
      expect(authProvider.rol, rol);
      expect(authProvider.isAuthenticated, true);
      verify(mockStorage.saveToken(token)).called(1);
    });

    test('Logout should clear state and delete token', () async {
      // Setup logged in state
      const token = 'token';
      const rol = 'ADMIN';
      when(mockStorage.saveToken(any)).thenAnswer((_) async {});
      when(mockStorage.deleteToken()).thenAnswer((_) async {});

      await authProvider.login(token, rol);
      // Logout
      await authProvider.logout();

      expect(authProvider.token, null);
      expect(authProvider.rol, null);
      expect(authProvider.isAuthenticated, false);
      verify(mockStorage.deleteToken()).called(1);
    });

    // Note: checking checkAuthOnStart requires a real JWT token string for JwtDecoder or mocking JwtDecoder (static).
    // Mocking static JwtDecoder.isExpired is hard.
    // We will skip checkAuthOnStart complex logic for now or provide real dummy JWT.
  });
}
