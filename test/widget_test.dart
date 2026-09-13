import 'package:flutter_test/flutter_test.dart';
import 'package:care_circle/main.dart';

void main() {
  testWidgets('CareCircle app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const CareCircleApp());

    expect(find.text('CareCircle'), findsOneWidget);
    expect(find.text('Firebase Connected'), findsOneWidget);
  });
}