import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/main.dart'; 

void main() {
  testWidgets('App launch smoke test', (WidgetTester tester) async {
  
    await tester.pumpWidget(const EFineApp());

   
    expect(find.text('E-Fine SL'), findsOneWidget);
  });
}