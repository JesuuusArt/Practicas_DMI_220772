import 'package:flutter_test/flutter_test.dart';

import 'package:toktik/main.dart';

void main() {
  testWidgets('discover screen shows the first video post', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Subiendo escaleras automáticas'), findsOneWidget);
    expect(find.text('23230'), findsOneWidget);
  });
}
