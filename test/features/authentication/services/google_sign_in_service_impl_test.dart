// Flutter imports:
import 'package:flutter/services.dart';

// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:pockeat/features/authentication/services/google_sign_in_service_impl.dart';
import 'google_sign_in_service_impl_test.mocks.dart';

@GenerateMocks([
  FirebaseAuth,
  GoogleSignIn,
  GoogleSignInAccount,
  GoogleSignInAuthentication,
  UserCredential,
  User,
])

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late GoogleSignInServiceImpl service;
  late MockFirebaseAuth mockAuth;
  late MockGoogleSignIn mockGoogleSignIn;
  late MockGoogleSignInAccount mockGoogleSignInAccount;
  late MockGoogleSignInAuthentication mockGoogleSignInAuthentication;
  late MockUserCredential mockUserCredential;
  late MockUser mockUser;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockGoogleSignIn = MockGoogleSignIn();
    mockGoogleSignInAccount = MockGoogleSignInAccount();
    mockGoogleSignInAuthentication = MockGoogleSignInAuthentication();
    mockUserCredential = MockUserCredential();
    mockUser = MockUser();

    service = GoogleSignInServiceImpl(
      auth: mockAuth,
      googleSignIn: mockGoogleSignIn,
    );

    // Setup default behavior
    when(mockGoogleSignIn.signIn())
        .thenAnswer((_) async => mockGoogleSignInAccount);
    when(mockGoogleSignIn.isSignedIn()).thenAnswer((_) async => false);
    when(mockGoogleSignIn.signOut()).thenAnswer((_) async => null);
    when(mockGoogleSignInAccount.authentication)
        .thenAnswer((_) async => mockGoogleSignInAuthentication);
    when(mockGoogleSignInAuthentication.accessToken)
        .thenReturn('mock_access_token');
    when(mockGoogleSignInAuthentication.idToken).thenReturn('mock_id_token');
    when(mockAuth.signInWithCredential(any))
        .thenAnswer((_) async => mockUserCredential);
    when(mockUserCredential.user).thenReturn(mockUser);
  });

  group('GoogleSignInServiceImpl', () {
    group('constructor', () {
      test('should use provided auth and googleSignIn instances', () {
        // Arrange & Act
        final testService = GoogleSignInServiceImpl(
          auth: mockAuth,
          googleSignIn: mockGoogleSignIn,
        );

        // Assert
        expect(testService, isA<GoogleSignInServiceImpl>());
        // Tidak bisa langsung memverifikasi private field, hanya memastikan
        // service berhasil dibuat dengan parameter yang kita berikan
      });
    });

    group('signInWithGoogle', () {
      test('should successfully sign in with Google when no user is signed in', () async {
        // Arrange
        when(mockGoogleSignIn.isSignedIn()).thenAnswer((_) async => false);

        // Act
        final result = await service.signInWithGoogle();

        // Assert
        expect(result, equals(mockUserCredential));
        verify(mockGoogleSignIn.isSignedIn()).called(1);
        verifyNever(mockGoogleSignIn.signOut());
        verify(mockGoogleSignIn.signIn()).called(1);
        verify(mockGoogleSignInAccount.authentication).called(1);
        verify(mockAuth.signInWithCredential(any)).called(1);
      });

      test('should sign out first when a user is already signed in', () async {
        // Arrange
        when(mockGoogleSignIn.isSignedIn()).thenAnswer((_) async => true);

        // Act
        final result = await service.signInWithGoogle();

        // Assert
        expect(result, equals(mockUserCredential));
        verify(mockGoogleSignIn.isSignedIn()).called(1);
        verify(mockGoogleSignIn.signOut()).called(1);
        verify(mockGoogleSignIn.signIn()).called(1);
        verify(mockGoogleSignInAccount.authentication).called(1);
        verify(mockAuth.signInWithCredential(any)).called(1);
      });

      test('should throw exception when Google sign in is cancelled', () async {
        // Arrange
        when(mockGoogleSignIn.signIn()).thenAnswer((_) async => null);

        // Act & Assert
        expect(
          () => service.signInWithGoogle(),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Google Sign In was cancelled'),
          )),
        );
      });

      test('should throw exception when authentication fails', () async {
        // Arrange
        when(mockGoogleSignInAccount.authentication)
            .thenThrow(Exception('Auth failed'));

        // Act & Assert
        expect(
          () => service.signInWithGoogle(),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Failed to sign in with Google'),
          )),
        );
      });

      test('should throw exception when Firebase sign in fails', () async {
        // Arrange
        when(mockAuth.signInWithCredential(any))
            .thenThrow(Exception('Firebase sign in failed'));

        // Act & Assert
        expect(
          () => service.signInWithGoogle(),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Failed to sign in with Google'),
          )),
        );
      });
    });
  });
}
