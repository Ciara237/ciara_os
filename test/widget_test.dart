import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ciaraos/main.dart';

void main() {
  testWidgets('Ciara OS placeholder home renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: CiaraOsApp(),
      ),
    );

    expect(find.text('Ciara OS'), findsOneWidget);
    expect(find.text('Scaffold ready — screens coming soon.'), findsOneWidget);
  });
}
