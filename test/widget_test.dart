import 'package:flutter_test/flutter_test.dart';
import 'package:app_post_master/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app mounts successfully
    expect(find.byType(MyApp), findsOneWidget);
  });
}
