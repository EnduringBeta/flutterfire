import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:flutterfire_ui/i10n.dart';
import 'package:flutterfire_ui_oauth_google/flutterfire_ui_google_oauth.dart';
import 'package:mockito/mockito.dart';

import 'utils.dart';

void main() {
  const labels = DefaultLocalizations();

  group('UniversalEmailSignInScreen', () {
    testWidgets('validates email', (tester) async {
      await render(
        tester,
        UniversalEmailSignInScreen(
          providers: [
            EmailAuthProvider(),
            PhoneAuthProvider(),
            GoogleProvider(clientId: 'test-client-id'),
          ],
        ),
      );

      await tester.pump();

      final input = find.byType(TextField);
      expect(input, findsOneWidget);

      await tester.enterText(input, 'notavalidemail');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      await tester.pumpAndSettle();

      expect(find.text(labels.isNotAValidEmailErrorText), findsOneWidget);
    });

    testWidgets('shows RegisterScreen if not providers found', (tester) async {
      await render(
        tester,
        UniversalEmailSignInScreen(
          providers: [
            EmailAuthProvider(),
            PhoneAuthProvider(),
            GoogleProvider(clientId: 'test-client-id'),
          ],
        ),
      );

      await tester.pump();

      final input = find.byType(TextField);
      expect(input, findsOneWidget);

      await tester.enterText(input, 'test@test.com');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      await tester.pumpAndSettle();

      expect(find.byType(RegisterScreen), findsOneWidget);
    });

    testWidgets('shows SingInScreen with only available providers',
        (tester) async {
      await render(
        tester,
        UniversalEmailSignInScreen(
          auth: MockAuth(),
          providers: [
            EmailAuthProvider(),
            PhoneAuthProvider(),
            GoogleProvider(clientId: 'test-client-id'),
          ],
        ),
      );

      await tester.pump();

      final input = find.byType(TextField);
      expect(input, findsOneWidget);

      await tester.enterText(input, 'test@test.com');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      await tester.pumpAndSettle();

      expect(find.byType(SignInScreen), findsOneWidget);
      expect(find.text(labels.signInWithPhoneButtonText), findsOneWidget);
      expect(find.text(labels.signInWithGoogleButtonText), findsOneWidget);
      expect(find.byType(EmailForm), findsNothing);
    });
  });
}

// ignore: avoid_implementing_value_types
class MockApp extends Mock implements FirebaseApp {}

class MockAuth extends Mock implements FirebaseAuth {
  @override
  FirebaseApp get app => MockApp();

  @override
  Future<List<String>> fetchSignInMethodsForEmail(String? email) async {
    return super.noSuchMethod(
      Invocation.method(
        #fetchSignInMethodsForEmail,
        [email],
      ),
      returnValue: ['phone', 'google.com'],
      returnValueForMissingStub: ['phone', 'google.com'],
    );
  }
}