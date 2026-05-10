import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow_ai/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: TaskFlowApp()));
    await tester.pump();
    expect(find.byType(TaskFlowApp), findsOneWidget);
  });
}
