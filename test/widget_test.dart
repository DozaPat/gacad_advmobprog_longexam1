import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gacad_advmobprog_longexam1/widgets/custom_button.dart';

void main() {
  testWidgets('custom button exposes its label and handles taps', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomButton(label: 'Continue', onPressed: () => taps++),
        ),
      ),
    );

    expect(find.text('Continue'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pump();
    expect(taps, 1);
  });
}
