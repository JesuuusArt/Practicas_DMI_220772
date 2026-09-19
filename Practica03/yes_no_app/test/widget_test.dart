import 'package:flutter_test/flutter_test.dart';

import 'package:yes_no_app/main.dart';

void main() {
  testWidgets('Chat screen renders without layout errors', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Hola soy un chat'), findsOneWidget);
    expect(find.text('Hola soy un field box'), findsOneWidget);
  });
}
