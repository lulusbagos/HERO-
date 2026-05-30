import 'package:flutter_test/flutter_test.dart';

import 'package:hero/app/hero_app.dart';

void main() {
  testWidgets('HERO login renders key elements', (WidgetTester tester) async {
    await tester.pumpWidget(const HeroApp());

    expect(find.text('HERO'), findsOneWidget);
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });
}
