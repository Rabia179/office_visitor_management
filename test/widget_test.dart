import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:office_visitor_management/main.dart';

void main() {
  testWidgets('Office Visitor Management loads', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const VisitorApp());

    expect(find.byType(VisitorApp), findsOneWidget);
  });
}