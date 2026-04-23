import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pam_2026_p9_ifs23021_fe/main.dart';

void main() {
  testWidgets('app renders auth gate before entering main screen', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);
  });
}
