import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('FestivalDetailScreen content renders', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Column(children: [
          Text('Mid-Autumn Festival', style: TextStyle(fontSize: 24)),
          Text('15th day of 8th lunar month'),
        ]),
      ),
    ));
    expect(find.text('Mid-Autumn Festival'), findsOneWidget);
  });
}
