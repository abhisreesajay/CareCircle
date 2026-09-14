import 'package:flutter_test/flutter_test.dart';
import 'package:care_circle/main.dart';

void main() {
  testWidgets('Caregiver dashboard loads', (WidgetTester tester) async {
    await tester.pumpWidget(const CareCircleApp());

    expect(find.text('Caregiver Dashboard'), findsOneWidget);
    expect(find.text('Medicines'), findsOneWidget);
    expect(find.text('Appointments'), findsOneWidget);
  });
}