import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pockeat/features/authentication/services/logout_service.dart';
import 'package:pockeat/features/authentication/services/logout_service_impl.dart';

// Mock untuk Firebase Auth
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

// Mock untuk Google Sign In
class MockGoogleSignIn extends Mock implements GoogleSignIn {}

// Mock untuk User
class MockUser extends Mock implements User {}

// Mock untuk UserInfo
class MockUserInfo extends Mock implements UserInfo {}

void main() {
  late LogoutService logoutService;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockGoogleSignIn mockGoogleSignIn;
  late MockUser mockUser;
  late MockUserInfo mockUserInfo;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockGoogleSignIn = MockGoogleSignIn();
    mockUser = MockUser();
    mockUserInfo = MockUserInfo();

    // Setup LogoutService dengan mock
    logoutService = LogoutServiceImpl(
      auth: mockFirebaseAuth,
      googleSignIn: mockGoogleSignIn,
    );
  });

  group('LogoutService Tests', () {
    test('Logout with normal Email/Password auth should return true', () async {
      // Arrange
      when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.providerData).thenReturn([mockUserInfo]);
      when(() => mockUserInfo.providerId).thenReturn('password');
      when(() => mockFirebaseAuth.signOut()).thenAnswer((_) async {});

      // Act
      final result = await logoutService.logout();

      // Assert
      expect(result, true);
      verify(() => mockFirebaseAuth.signOut()).called(1);
      verifyNever(() => mockGoogleSignIn.signOut());
    });

    test('Logout with Google auth should sign out from Google too', () async {
      // Arrange
      when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.providerData).thenReturn([mockUserInfo]);
      when(() => mockUserInfo.providerId).thenReturn('google.com');
      when(() => mockFirebaseAuth.signOut()).thenAnswer((_) async {});
      when(() => mockGoogleSignIn.signOut()).thenAnswer((_) async => null);

      // Act
      final result = await logoutService.logout();

      // Assert
      expect(result, true);
      verify(() => mockFirebaseAuth.signOut()).called(1);
      verify(() => mockGoogleSignIn.signOut()).called(1);
    });

    test('Logout should handle errors and return false', () async {
      // Arrange
      when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.providerData).thenReturn([mockUserInfo]);
      when(() => mockUserInfo.providerId).thenReturn('password');
      when(() => mockFirebaseAuth.signOut())
          .thenThrow(FirebaseAuthException(code: 'error'));

      // Act
      final result = await logoutService.logout();

      // Assert
      expect(result, false);
      verify(() => mockFirebaseAuth.signOut()).called(1);
    });
  });
}
