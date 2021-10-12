import 'package:flutter/material.dart';
import 'package:marbelous_esp32_app/screens/add_device_screen.dart';
// import './screens/home.dart';
import './screens/home_screen.dart';
import './screens/command_screen.dart';
import 'screens/setting_screens/starter_common_settings.dart';
import './screens/setting_screens/starter_advanced_settings.dart';
import './screens/global_settings.dart';
import './utilities/messageRecvr.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    MessageRecvr recvr = MessageRecvr();
    recvr.startListeningForMessages();
    return MaterialApp(
      title: 'Marblelous MVP',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      initialRoute: HomeScreen.id,
      routes: {
        HomeScreen.id: (context) => HomeScreen(),
        CommandScreen.id: (context) => CommandScreen(),
        StarterCommonSettings.id: (context) => StarterCommonSettings(),
        StarterAdvancedSettings.id: (context) => StarterAdvancedSettings(),
        AddDeviceScreen.id: (context) => AddDeviceScreen(),
        GlobalSettings.id: (context) => GlobalSettings(),
      },
    );
  }
}
