import 'package:flutter/material.dart';
import 'package:quick_task/parse_service.dart';
import 'package:quick_task/screens/login_screen.dart';
import 'package:quick_task/screens/task_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ParseService.initializeParse();
  runApp(const QuickTaskApp());
}

class QuickTaskApp extends StatelessWidget {
  const QuickTaskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuickTask',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/taskList': (context) => TaskListScreen(),
      },
    );
  }
}
