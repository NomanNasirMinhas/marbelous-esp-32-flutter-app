import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:marbelous_esp32_app/screens/add_device_screen.dart';
import 'package:marbelous_esp32_app/screens/global_settings.dart';
import 'package:marbelous_esp32_app/screens/setting_screens/starter_advanced_settings.dart';
import 'dart:io';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:loading_overlay/loading_overlay.dart';
import './../constants.dart';
import './command_screen.dart';
import 'setting_screens/starter_common_settings.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:localstore/localstore.dart';
import './../utilities/device_class.dart';
import './device_cards/starter_card.dart';

class HomeScreen extends StatefulWidget {
  // HomeScreen({Key? key}) : super(key: key);
  static String id = "home_screen";

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HashMap devicesMap = new HashMap<String, MarbleDevice>();
  List<MarbleDevice> devices = [];
  bool isScanning = true;
  bool starterFound = false;
  String currentWidget = "none";
  String selectedDevice;

  scanNetwork() async {
    setState(() {
      isScanning = true;
      devices = [];
    });
    print("Scanning Network");
    final db = Localstore.instance;
    final items = await db.collection('marbelous_devices').get();
    if (items == null) {
      print("No Devices Found");
    } else {
      print("${items.length} Devices Found");
      items.forEach((key, value) {
        MarbleDevice device = new MarbleDevice(
            macAddrr: value['macAddrr'],
            name: value['name'],
            ipAddrr: value['ip'],
            type: value['type'],
            docID: key);
        devicesMap[device.type] = device;
        // var idx = devices.indexOf(device);

        setState(() {
          if (device.type == "starter") {
            starterFound = true;
            currentWidget = "starter";
          }
          devices.add(device);
        });
      });
    }

    print('Done');
    setState(() {
      isScanning = false;
    });
  }

  displaySnackBar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    scanNetwork();
  }

  Widget getCurrentWidget() {
    switch (currentWidget) {
      case "none":
        return Container(
          decoration: sectionCard,
          child: GestureDetector(
            onTap: () {
              Navigator.popAndPushNamed(context, AddDeviceScreen.id,
                  arguments: {'deviceType': "starter"});
            },
            child: Text(
              "Starter NOT Found. Click to Add",
              style: subheadingText,
              textAlign: TextAlign.center,
            ),
          ),
        );
        break;
      case "starter":
        if (devicesMap.containsKey("starter")) {
          return StarterCard(
              title: "Starter",
              icon: "assets/img/starter.png",
              type: "starter");
        } else {
          return GestureDetector(
              onTap: () {
                Navigator.popAndPushNamed(context, AddDeviceScreen.id,
                    arguments: {'deviceType': "starter"});
              },
              child: Text(
                "Device NOT Found. Click to Add",
                style: subheadingText,
                textAlign: TextAlign.center,
              ));
        }
        break;
      case 'finisher':
        if (devicesMap.containsKey("finisher")) {
          return BoldInfoText(text: "Device Card Not Ready Yet");
        } else {
          return GestureDetector(
              onTap: () {
                Navigator.popAndPushNamed(context, AddDeviceScreen.id,
                    arguments: {'deviceType': "finisher"});
              },
              child: Text(
                "Device NOT Found. Click to Add",
                style: subheadingText,
                textAlign: TextAlign.center,
              ));
        }
        break;
      case 'wheel':
        if (devicesMap.containsKey("wheel")) {
          return BoldInfoText(text: "Device Card Not Ready Yet");
        } else {
          return GestureDetector(
              onTap: () {
                Navigator.popAndPushNamed(context, AddDeviceScreen.id,
                    arguments: {'deviceType': "wheel"});
              },
              child: Text(
                "Device NOT Found. Click to Add",
                style: subheadingText,
                textAlign: TextAlign.center,
              ));
        }
        break;
      case 'spiral':
        if (devicesMap.containsKey("spiral")) {
          return BoldInfoText(text: "Device Card Not Ready Yet");
        } else {
          return GestureDetector(
              onTap: () {
                Navigator.popAndPushNamed(context, AddDeviceScreen.id,
                    arguments: {'deviceType': "spiral"});
              },
              child: Text(
                "Device NOT Found. Click to Add",
                style: subheadingText,
                textAlign: TextAlign.center,
              ));
        }
        break;
      case 'teleport1':
        if (devicesMap.containsKey("teleport1")) {
          return BoldInfoText(text: "Device Card Not Ready Yet");
        } else {
          return GestureDetector(
              onTap: () {
                Navigator.popAndPushNamed(context, AddDeviceScreen.id,
                    arguments: {'deviceType': "teleport1"});
              },
              child: Text(
                "Device NOT Found. Click to Add",
                style: subheadingText,
                textAlign: TextAlign.center,
              ));
        }
        break;
      case 'teleport2':
        if (devicesMap.containsKey("teleport2")) {
          return BoldInfoText(text: "Device Card Not Ready Yet");
        } else {
          return GestureDetector(
              onTap: () {
                Navigator.popAndPushNamed(context, AddDeviceScreen.id,
                    arguments: {'deviceType': "teleport2"});
              },
              child: Text(
                "Device NOT Found. Click to Add",
                style: subheadingText,
                textAlign: TextAlign.center,
              ));
        }
        break;
      case 'switch':
        if (devicesMap.containsKey("switch")) {
          return BoldInfoText(text: "Device Card Not Ready Yet");
        } else {
          return GestureDetector(
              onTap: () {
                Navigator.popAndPushNamed(context, AddDeviceScreen.id,
                    arguments: {'deviceType': "switch"});
              },
              child: Text(
                "Device NOT Found. Click to Add",
                style: subheadingText,
                textAlign: TextAlign.center,
              ));
        }
        break;
      default:
        return Text(
          "Error",
          style: subheadingText,
          textAlign: TextAlign.center,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SafeArea(
        child: LoadingOverlay(
          isLoading: isScanning,
          child: Scaffold(
            appBar: AppBar(
              actions: [
                IconButton(
                  icon: Icon(Icons.settings),
                  color: Colors.white,
                  onPressed: () {
                    Navigator.pushNamed(context, GlobalSettings.id);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.notifications_active),
                  color: Colors.white,
                  onPressed: () {
                    // scanNetwork();
                  },
                ),
              ],
              title: Text(
                "Marbellous Home",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Scheherazade',
                  fontSize: 40,
                  // decoration: TextDecoration.overline,
                ),
              ),
            ),
            body: Center(
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      "Marbelous Icon Goes Here",
                      style: headingText,
                      textAlign: TextAlign.center,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: getCurrentWidget(),
                    ),
                    Container(
                      decoration: sectionCard,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              //Starter ICON
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    currentWidget = 'starter';
                                  });
                                },
                                child: DeviceIcon(
                                  deviceType: 'starter',
                                  icon: 'starter.png',
                                  device_ip: devicesMap.containsKey("starter")
                                      ? devicesMap["starter"].ipAddrr
                                      : null,
                                ),
                              ),

                              //Icon 2
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    currentWidget = 'finisher';
                                  });
                                },
                                child: DeviceIcon(
                                  deviceType: 'finisher',
                                  icon: 'finisher.png',
                                  device_ip: devicesMap.containsKey("finisher")
                                      ? devicesMap["finisher"].ipAddrr
                                      : null,
                                ),
                              ),

                              //Icon 3
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    currentWidget = 'wheel';
                                  });
                                },
                                child: DeviceIcon(
                                  deviceType: 'wheel',
                                  icon: 'wheel.png',
                                  device_ip: devicesMap.containsKey("wheel")
                                      ? devicesMap["wheel"].ipAddrr
                                      : null,
                                ),
                              ),

                              //Icon 4
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    currentWidget = 'spiral';
                                  });
                                },
                                child: DeviceIcon(
                                  deviceType: 'spiral',
                                  icon: 'spiral.png',
                                  device_ip: devicesMap.containsKey("spiral")
                                      ? devicesMap["spiral"].ipAddrr
                                      : null,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              //Starter ICON
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    currentWidget = 'teleport1';
                                  });
                                },
                                child: DeviceIcon(
                                  deviceType: 'teleport1',
                                  icon: 'teleporter1.png',
                                  device_ip: devicesMap.containsKey("teleport1")
                                      ? devicesMap["teleport1"].ipAddrr
                                      : null,
                                ),
                              ),

                              //Icon 2
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    currentWidget = 'teleport2';
                                  });
                                },
                                child: DeviceIcon(
                                  deviceType: 'teleport2',
                                  icon: 'teleporter2.png',
                                  device_ip: devicesMap.containsKey("teleport2")
                                      ? devicesMap["teleport2"].ipAddrr
                                      : null,
                                ),
                              ),

                              //Icon 3
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    currentWidget = 'switch';
                                  });
                                },
                                child: DeviceIcon(
                                  deviceType: 'switch',
                                  icon: 'switch.png',
                                  device_ip: devicesMap.containsKey("switch")
                                      ? devicesMap["switch"].ipAddrr
                                      : null,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DeviceIcon extends StatelessWidget {
  DeviceIcon({this.deviceType, this.icon, this.device_ip});

  final String deviceType;
  final String icon;
  final String device_ip;

  @override
  Widget build(BuildContext context) {
    displaySnackBar(String message) {
      final snackBar = SnackBar(
        content: Text(message),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    openSettings(String deviceType) {
      switch (deviceType) {
        case 'starter':
          if (device_ip == null) {
            displaySnackBar("Device IP Not Present");
          } else {
            Navigator.pushNamed(context, StarterCommonSettings.id,
                arguments: {'starter_ip': device_ip});
          }
          break;
        case 'finisher':
          break;
        case 'wheel':
          break;
        case 'spiral':
          break;
        case 'teleport1':
          break;
        case 'teleport2':
          break;
        case 'switch':
          break;
        default:
          displaySnackBar("Invalid Device Selected");
          break;
      }
    }

    forgetDevice(String deviceType) async {
      final db = Localstore.instance;
      final devices = await db.collection('marbelous_devices').get();
      print(devices);
      if (devices != null) {
        devices.forEach((key, value) async {
          if (value['type'] == deviceType) {
            var id = value['macAddrr'].split("/").last;
            var name = value['name'];
            print("Forgetting MAC $id");
            await db.collection('marbelous_devices').doc(id).delete();
            displaySnackBar("Forgot $name Device");
            Navigator.popAndPushNamed(context, HomeScreen.id);
          }
        });
      }
    }

    return GestureDetector(
      onLongPress: () {
        forgetDevice(deviceType);
      },
      onDoubleTap: () {
        openSettings(deviceType);
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[700], width: 2),
        ),
        child: new Image.asset(
          'assets/img/$icon',
          width: 50,
          height: 50,
        ),
      ),
    );
  }
}

class BoldInfoText extends StatelessWidget {
  final String text;
  BoldInfoText({this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      softWrap: true,
      style: boldInfoText,
      // textAlign: TextAlign.justify,
    );
  }
}
