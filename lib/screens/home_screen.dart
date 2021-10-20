import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:marbelous_esp32_app/screens/add_device_screen.dart';
import 'package:marbelous_esp32_app/screens/global_settings.dart';
import 'package:marbelous_esp32_app/screens/setting_screens/starter_advanced_settings.dart';
import 'dart:io';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:udp/udp.dart';
import './../constants.dart';
import './command_screen.dart';
import 'setting_screens/starter_common_settings.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:localstore/localstore.dart';
import './../utilities/device_class.dart';
import './device_cards/starter_card.dart';
import './../components/device_icon.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import './../main.dart';

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
  String starterIP;
  String starterName;
  dynamic starter_common_settings;
  dynamic starter_advanced_settings;
  var receiver;

  // Future<UDP> receiver = UDP.bind(Endpoint.any(port: Port(65000)));
  scanNetwork() async {
    final db = Localstore.instance;
    print("Getting Starter Settings");

    var common = await db
        .collection('starter_common_settings')
        .doc("starter_common_settings")
        .get();
    var advanced = await db
        .collection('starter_advanced_settings')
        .doc("starter_advanced_settings")
        .get();
    setState(() {
      isScanning = true;
      devices = [];
      starter_common_settings = common;
      starter_advanced_settings = advanced;
    });

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
        print("Adding device type ${device.type}");
        devicesMap[device.type] = device;
        // var idx = devices.indexOf(device);
        if (device.type == "starter") {
          context.read(starter_ip_provider).state = device.ipAddrr;
        }
        if (device.type == "finisher") {
          context.read(finisher_ip_provider).state = device.ipAddrr;
        }
        if (device.type == "switch") {
          context.read(switch_ip_provider).state = device.ipAddrr;
        }
        setState(() {
          if (device.type == "starter") {
            starterFound = true;
            currentWidget = "starter";
            starterIP = device.ipAddrr;
          }
          devices.add(device);
        });
      });
    }

    print('Done');
    setState(() {
      isScanning = false;
    });
    if (starterFound == false) {
      CoolAlert.show(
          context: context,
          type: CoolAlertType.confirm,
          title: "Starter Not Found",
          text: "Would You like Add it now?",
          confirmBtnText: "Yes",
          onConfirmBtnTap: () {
            Navigator.pop(context);
            // displaySnackBar("Please Connect to Device Wifi");
            AppSettings.openWIFISettings();
            Navigator.popAndPushNamed(context, AddDeviceScreen.id,
                arguments: {'deviceType': "starter"});
          },
          cancelBtnText: "Later",
          onCancelBtnTap: () {
            Navigator.pop(context);
          });
    }
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
    scanNetwork();
    startListeningForMessages(context);
    super.initState();
  }

  @override
  dispose() {
    super.dispose();
    stopReciever();
  }

  @override
  Widget build(BuildContext context) {
    startListeningForMessages(context);
    return Container(
      child: SafeArea(
        child: LoadingOverlay(
          isLoading: isScanning,
          child: Scaffold(
            // appBar: AppBar(
            //   actions: [
            //     IconButton(
            //       icon: Icon(Icons.settings),
            //       color: Colors.white,
            //       onPressed: () {
            //         Navigator.pushNamed(context, GlobalSettings.id);
            //       },
            //     ),
            //     // IconButton(
            //     //   icon: Icon(Icons.notifications_active),
            //     //   color: Colors.white,
            //     //   onPressed: () {
            //     //     // scanNetwork();
            //     //   },
            //     // ),
            //   ],
            //   title: Text(
            //     "Marblelous Home",
            //     style: TextStyle(
            //       color: Colors.white,
            //       fontFamily: 'Scheherazade',
            //       fontSize: 40,
            //       // decoration: TextDecoration.overline,
            //     ),
            //   ),
            // ),
            body: Center(
              child: Container(
                child: ListView(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: [
                          Expanded(flex: 1, child: Container()),
                          Expanded(
                            flex: 5,
                            child: new Image.asset(
                              'assets/img/logo.jpeg',
                              fit: BoxFit.contain,
                            ),
                          ),
                          Expanded(
                              flex: 1,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, GlobalSettings.id);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.black, width: 2),
                                      borderRadius: BorderRadius.circular(4)),
                                  child: Icon(
                                    Icons.settings,
                                    size: 30,
                                  ),
                                ),
                              )),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    StarterCard(
                      title:
                          "Starter (${starter_common_settings == null ? "Name Not Set" : starter_common_settings['name']})",
                      icon: "assets/img/starter.png",
                      type: "starter",
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
                                child: DeviceIcon(
                                  port: 65001,
                                  deviceType: 'starter',
                                  icon: 'starter.png',
                                ),
                              ),

                              //Icon 2
                              GestureDetector(
                                child: DeviceIcon(
                                  port: 65002,
                                  deviceType: 'finisher',
                                  icon: 'finisher.png',
                                ),
                              ),

                              //Icon 3
                              GestureDetector(
                                child: DeviceIcon(
                                  port: 65003,
                                  deviceType: 'wheel',
                                  icon: 'wheel.png',
                                ),
                              ),

                              //Icon 4
                              GestureDetector(
                                child: DeviceIcon(
                                  port: 65004,
                                  deviceType: 'spiral',
                                  icon: 'spiral.png',
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
                                child: DeviceIcon(
                                  port: 65005,
                                  deviceType: 'teleport1',
                                  icon: 'teleporter1.png',
                                ),
                              ),

                              //Icon 2
                              GestureDetector(
                                child: DeviceIcon(
                                  port: 65006,
                                  deviceType: 'teleport2',
                                  icon: 'teleporter2.png',
                                ),
                              ),

                              //Icon 3
                              GestureDetector(
                                child: DeviceIcon(
                                  port: 65007,
                                  deviceType: 'switch',
                                  icon: 'switch.png',
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

  // Widget getCurrentWidget() {
  //   switch (currentWidget) {
  //     case "none":
  //       return Container(
  //         decoration: sectionCard,
  //         child: GestureDetector(
  //           onTap: () {
  //             Navigator.popAndPushNamed(context, AddDeviceScreen.id,
  //                 arguments: {'deviceType': "starter"});
  //           },
  //           child: Text(
  //             "Starter NOT Found. Click to Add",
  //             style: subheadingText,
  //             textAlign: TextAlign.center,
  //           ),
  //         ),
  //       );
  //       break;
  //     case "starter":
  //       if (devicesMap.containsKey("starter")) {
  //         return StarterCard(
  //           title:
  //               "Starter (${starter_common_settings == null ? "Name Not Set" : starter_common_settings['name']})",
  //           icon: "assets/img/starter.png",
  //           type: "starter",
  //         );
  //       } else {
  //         return GestureDetector(
  //             onTap: () {
  //               Navigator.popAndPushNamed(context, AddDeviceScreen.id,
  //                   arguments: {'deviceType': "starter"});
  //             },
  //             child: Text(
  //               "Device NOT Found. Click to Add",
  //               style: subheadingText,
  //               textAlign: TextAlign.center,
  //             ));
  //       }
  //       break;
  //     case 'finisher':
  //       if (devicesMap.containsKey("finisher")) {
  //         return BoldInfoText(text: "Device Card Not Ready Yet");
  //       } else {
  //         return GestureDetector(
  //             onTap: () {
  //               Navigator.popAndPushNamed(context, AddDeviceScreen.id,
  //                   arguments: {'deviceType': "finisher"});
  //             },
  //             child: Text(
  //               "Device NOT Found. Click to Add",
  //               style: subheadingText,
  //               textAlign: TextAlign.center,
  //             ));
  //       }
  //       break;
  //     case 'wheel':
  //       if (devicesMap.containsKey("wheel")) {
  //         return BoldInfoText(text: "Device Card Not Ready Yet");
  //       } else {
  //         return GestureDetector(
  //             onTap: () {
  //               Navigator.popAndPushNamed(context, AddDeviceScreen.id,
  //                   arguments: {'deviceType': "wheel"});
  //             },
  //             child: Text(
  //               "Device NOT Found. Click to Add",
  //               style: subheadingText,
  //               textAlign: TextAlign.center,
  //             ));
  //       }
  //       break;
  //     case 'spiral':
  //       if (devicesMap.containsKey("spiral")) {
  //         return BoldInfoText(text: "Device Card Not Ready Yet");
  //       } else {
  //         return GestureDetector(
  //             onTap: () {
  //               Navigator.popAndPushNamed(context, AddDeviceScreen.id,
  //                   arguments: {'deviceType': "spiral"});
  //             },
  //             child: Text(
  //               "Device NOT Found. Click to Add",
  //               style: subheadingText,
  //               textAlign: TextAlign.center,
  //             ));
  //       }
  //       break;
  //     case 'teleport1':
  //       if (devicesMap.containsKey("teleport1")) {
  //         return BoldInfoText(text: "Device Card Not Ready Yet");
  //       } else {
  //         return GestureDetector(
  //             onTap: () {
  //               Navigator.popAndPushNamed(context, AddDeviceScreen.id,
  //                   arguments: {'deviceType': "teleport1"});
  //             },
  //             child: Text(
  //               "Device NOT Found. Click to Add",
  //               style: subheadingText,
  //               textAlign: TextAlign.center,
  //             ));
  //       }
  //       break;
  //     case 'teleport2':
  //       if (devicesMap.containsKey("teleport2")) {
  //         return BoldInfoText(text: "Device Card Not Ready Yet");
  //       } else {
  //         return GestureDetector(
  //             onTap: () {
  //               Navigator.popAndPushNamed(context, AddDeviceScreen.id,
  //                   arguments: {'deviceType': "teleport2"});
  //             },
  //             child: Text(
  //               "Device NOT Found. Click to Add",
  //               style: subheadingText,
  //               textAlign: TextAlign.center,
  //             ));
  //       }
  //       break;
  //     case 'switch':
  //       if (devicesMap.containsKey("switch")) {
  //         return BoldInfoText(text: "Device Card Not Ready Yet");
  //       } else {
  //         return GestureDetector(
  //             onTap: () {
  //               Navigator.popAndPushNamed(context, AddDeviceScreen.id,
  //                   arguments: {'deviceType': "switch"});
  //             },
  //             child: Text(
  //               "Device NOT Found. Click to Add",
  //               style: subheadingText,
  //               textAlign: TextAlign.center,
  //             ));
  //       }
  //       break;
  //     default:
  //       return Text(
  //         "Error",
  //         style: subheadingText,
  //         textAlign: TextAlign.center,
  //       );
  //   }
  // }