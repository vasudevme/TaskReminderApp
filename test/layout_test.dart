import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:nova_tasks/screens/main_navigation.dart';
import 'package:nova_tasks/providers/task_provider.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  testWidgets('App Layout Smoke Test', (WidgetTester tester) async {
    // Initialize dummy supabase
    Supabase.initialize(
      url: 'https://dummy.supabase.co',
      publishableKey: 'dummy',
    );
    
    // Create a mock provider or real provider
    final provider = TaskProvider();
    
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<TaskProvider>.value(value: provider),
        ],
        child: MaterialApp(
          home: const MainNavigation(),
        ),
      ),
    );

    // Let the layout settle
    await tester.pumpAndSettle();
    
    // If we reach here without exceptions, layout is fine
    expect(find.byType(MainNavigation), findsOneWidget);
  });
}
