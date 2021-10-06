import 'package:flutter/material.dart';
import 'package:marbelous_esp32_app/screens/add_device_screen.dart';
// import './screens/home.dart';
import './screens/home_screen.dart';
import './screens/command_screen.dart';
import 'screens/setting_screens/starter_common_settings.dart';
import './screens/setting_screens/starter_advanced_settings.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
        CommonSettings.id:(context) => CommonSettings(),
        AdvancedSettings.id:(context) => AdvancedSettings(),
        AddDeviceScreen.id:(context) => AddDeviceScreen(),
      },
    );
  }
}
