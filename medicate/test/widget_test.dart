import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:medicate/main.dart';
import 'package:medicate/core/services/services.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MedicateProvider()),
        ],
        child: MyApp(),
      ),
    );
    
    // Verify MyApp is present
    expect(find.byType(MyApp), findsOneWidget);
  });
}
