import 'package:flutter_test/flutter_test.dart';
import 'package:ngetestaja/main.dart';

void main() {
  testWidgets('shows logistics onboarding', (tester) async {
    await tester.pumpWidget(const SmartLogisticsApp());

    expect(find.text('Neo-Industrial Routing'), findsOneWidget);
    expect(find.text('NEXT'), findsOneWidget);
  });
}
