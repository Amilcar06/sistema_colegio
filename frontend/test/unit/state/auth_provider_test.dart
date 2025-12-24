
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:unidad_educatica_frontend/state/auth_provider.dart';
import 'package:unidad_educatica_frontend/core/storage.dart';

// Generate mocks
@GenerateMocks([TokenStorage])
import 'auth_provider_test.mocks.dart';

void main() {
  group('AuthProvider Tests', () {
    late AuthProvider authProvider;
    late MockTokenStorage mockStorage;

    setUp(() {
      mockStorage = MockTokenStorage();
      authProvider = AuthProvider(storage: mockStorage);
    });

    test('Initial state should be unauthenticated', () {
      expect(authProvider.isAuthenticated, false);
      expect(authProvider.token, null);
      expect(authProvider.rol, null);
    });

    test('login should update state and save token', () async {
      const token = 'fake_token';
      const rol = 'admin';

      when(mockStorage.saveToken(token)).thenAnswer((_) async {});

      await authProvider.login(token, rol);

      expect(authProvider.isAuthenticated, true);
      expect(authProvider.token, token);
      expect(authProvider.rol, rol);
      verify(mockStorage.saveToken(token)).called(1);
    });

    test('logout should clear state and delete token', () async {
      // First login
      when(mockStorage.saveToken(any)).thenAnswer((_) async {});
      await authProvider.login('token', 'rol');
      
      // Then logout
      when(mockStorage.deleteToken()).thenAnswer((_) async {});
      await authProvider.logout();

      expect(authProvider.isAuthenticated, false);
      expect(authProvider.token, null);
      expect(authProvider.rol, null);
      verify(mockStorage.deleteToken()).called(1);
    });
  });
}
