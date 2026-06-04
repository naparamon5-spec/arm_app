// Basic smoke test for the ARM app.
//
// The original Flutter template test referenced a `MyApp` counter widget that
// does not exist in this project (the real root widget is `ArdentApp`, wired up
// in main.dart with providers and DI). That boilerplate is replaced here with a
// dependency-free smoke test so `flutter test` compiles and passes without
// requiring platform channels (secure storage, etc.).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders a basic widget tree', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: Text('ARM'))),
      ),
    );

    expect(find.text('ARM'), findsOneWidget);
  });
}
