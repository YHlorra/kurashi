import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App smoke test', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: Center(child: Text('kurashi'))),
    ));
    expect(find.text('kurashi'), findsOneWidget);
  });
}
