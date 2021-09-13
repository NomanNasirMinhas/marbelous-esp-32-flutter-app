import 'package:flutter/material.dart';
import './screens/home.dart';
import './screens/command_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Marbellous MVP',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      initialRoute: HomeScreen.id,
      routes: {
        HomeScreen.id: (context) => HomeScreen(),
        CommandScreen.id: (context) => CommandScreen(),
      },
    );
  }
}
