import 'package:flutter/material.dart';
import 'package:marbelous_esp32_app/screens/add_device_screen.dart';
// import './screens/home.dart';
import './screens/home_screen.dart';
import './screens/command_screen.dart';
import 'screens/setting_screens/starter_common_settings.dart';
import './screens/setting_screens/starter_advanced_settings.dart';
import './screens/global_settings.dart';
import './utilities/messageRecvr.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marbelous_esp32_app/utilities/device_msg_class.dart';
import 'package:udp/udp.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:localstore/localstore.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    // Adding ProviderScope enables Riverpod for the entire project
    ProviderScope(child: MyApp()),
  );
}

var receiver;

final wifiIP_Provider = StateProvider((ref) => "");
final isDropping_Provider = StateProvider((ref) => false);
//Add Device Vars
final deviceMac_Provider = StateProvider((ref) => "");
final deviceType_Provider = StateProvider((ref) => "");
final deviceName_Provider = StateProvider((ref) => "");
final deviceIP_Provider = StateProvider((ref) => "");
final deviceToAdd_Provider = StateProvider((ref) => "");
final deviceFound_Provider = StateProvider((ref) => false);
//Device Icons Vars
//Starter
final starter_Online = StateProvider((ref) => false);
final starter_battery = StateProvider((ref) => -1);
final starter_lastStatusOn = StateProvider((ref) => DateTime.now());

//Finisher
final finisher_Online = StateProvider((ref) => false);
final finisher_battery = StateProvider((ref) => -1);
final finisher_lastStatusOn = StateProvider((ref) => DateTime.now());

//Wheel
final wheel_Online = StateProvider((ref) => false);
final wheel_battery = StateProvider((ref) => -1);
final wheel_lastStatusOn = StateProvider((ref) => DateTime.now());

//Spiral
final spiral_Online = StateProvider((ref) => false);
final spiral_battery = StateProvider((ref) => -1);
final spiral_lastStatusOn = StateProvider((ref) => DateTime.now());

//Teleport1
final teleport1_Online = StateProvider((ref) => false);
final teleport1_battery = StateProvider((ref) => -1);
final teleport1_lastStatusOn = StateProvider((ref) => DateTime.now());

//Teleport2
final teleport2_Online = StateProvider((ref) => false);
final teleport2_battery = StateProvider((ref) => -1);
final teleport2_lastStatusOn = StateProvider((ref) => DateTime.now());

//Switch
final switch_Online = StateProvider((ref) => false);
final switch_battery = StateProvider((ref) => -1);
final switch_lastStatusOn = StateProvider((ref) => DateTime.now());

startListeningForMessages(BuildContext context) async {
  final db = Localstore.instance;
  final info = NetworkInfo();
  try {
    print("Listening for messages");
    receiver = await UDP.bind(Endpoint.any(port: Port(65000)));
    var wifi = await info.getWifiIP();
    context.read(wifiIP_Provider).state = wifi;

    await receiver.listen((datagram) async {
      var str = String.fromCharCodes(datagram.data);
      print("Message Recived $str");
      var tokens = str.split("=");
      if (tokens[0].trim() == "device_msg") {
        //For Receiving messages for starter cards
        var command = tokens[1].split(":");
        if (command[0] == "finisher_finish") {
          context.read(isDropping_Provider).state =
              false; //TODO: Set it to true when pressed Drop Marble
        }
      } else if (tokens[0].trim() == "deviceStatus") {
        var deviceStatus = tokens[1].split("&");
        var deviceType = deviceStatus[0];
        var battery = 0;
        var power = deviceStatus[1].split(':');
        if (power[0] == "Battery") {
          if (power[1] == "ON_USB_POW") {
            battery = -1;
          } else {
            battery = int.parse(power[1]);
          }
        }
        print("$deviceType is online with $battery Battery. Updating..");
        switch (deviceType) {
          case 'starter':
            context.read(starter_Online).state = true;
            context.read(starter_battery).state = battery;
            context.read(starter_lastStatusOn).state = DateTime.now();
            break;
          case 'finisher':
            context.read(finisher_Online).state = true;
            context.read(finisher_battery).state = battery;
            context.read(finisher_lastStatusOn).state = DateTime.now();
            break;
          case 'wheel':
            context.read(wheel_Online).state = true;
            context.read(wheel_battery).state = battery;
            context.read(wheel_lastStatusOn).state = DateTime.now();
            break;
          case 'spiral':
            context.read(spiral_Online).state = true;
            context.read(spiral_battery).state = battery;
            context.read(spiral_lastStatusOn).state = DateTime.now();
            break;
          case 'teleport1':
            context.read(teleport1_Online).state = true;
            context.read(teleport1_battery).state = battery;
            context.read(teleport1_lastStatusOn).state = DateTime.now();
            break;
          case 'teleport2':
            context.read(teleport2_Online).state = true;
            context.read(teleport2_battery).state = battery;
            context.read(teleport2_lastStatusOn).state = DateTime.now();
            break;
          case 'switch':
            context.read(switch_Online).state = true;
            context.read(switch_battery).state = battery;
            context.read(switch_lastStatusOn).state = DateTime.now();
            break;
          default:
            break;
        }
      }
    });
  } on Exception catch (e) {
    // TODO
    print(e.toString());
  }
}

stopReciever() {
  receiver.close();
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // MessageRecvr recvr = MessageRecvr();
    // recvr.startListeningForMessages();
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
