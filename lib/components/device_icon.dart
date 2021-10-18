import 'package:flutter/material.dart';
import 'package:marbelous_esp32_app/screens/add_device_screen.dart';
import 'package:marbelous_esp32_app/screens/home_screen.dart';
import 'package:marbelous_esp32_app/screens/setting_screens/starter_common_settings.dart';
import 'package:localstore/localstore.dart';
import 'package:udp/udp.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import './../screens/home_screen.dart';

class DeviceIcon extends StatefulWidget {
  // const DeviceIcon({ Key? key }) : super(key: key);
  DeviceIcon({this.deviceType, this.icon, this.port});
  final String deviceType;
  final String icon;

  final int port;
  @override
  _DeviceIconState createState() => _DeviceIconState();
}

class _DeviceIconState extends State<DeviceIcon> {
  String deviceType;
  String icon;
  String device_ip;
  String starterName;
  String deviceName;
  bool isAdded = false;
  // bool isOnline = false;
  int battery = -1;
  // DateTime lastStatusOn = DateTime.now();
  Duration diff;
  bool keepChecking = true;
  var receiver;

  scanNetwork() async {
    final db = Localstore.instance;
    print("Getting Starter Settings");

    var common = await db
        .collection('starter_common_settings')
        .doc("starter_common_settings")
        .get();
    if (common != null && deviceType == "starter") {
      setState(() {
        starterName = common["name"];
      });
    }
    print("Scanning Network");

    final items = await db.collection('marbelous_devices').get();
    if (items == null) {
      print("No Devices Found");
    } else {
      print("${items.length} Devices Found");
      items.forEach((key, value) {
        if (value['type'] == deviceType) {
          setState(() {
            isAdded = true;
            device_ip = value['ip'];
            deviceName = value['name'];
          });
        }
        // MarbleDevice device = new MarbleDevice(
        //     macAddrr: value['macAddrr'],
        //     name: value['name'],
        //     ipAddrr: value['ip'],
        //     type: value['type'],
        //     docID: key);
        // print("Adding device type ${device.type}");
        // devicesMap[device.type] = device;
        // // var idx = devices.indexOf(device);

        // setState(() {
        //   if (device.type == "starter") {
        //     starterFound = true;
        //     currentWidget = "starter";
        //     starterIP = device.ipAddrr;
        //   }
        //   devices.add(device);
        // });
      });
    }

    print('Done');
  }

  startCheckingStatus(BuildContext context) async {
    try {
      while (keepChecking && mounted) {
        var lastStatusOn = context
            .read(devicesStatus_Provider)
            .state[deviceType]['lastStatusOn'];
        diff = DateTime.now().difference(lastStatusOn);

        if (diff > Duration(seconds: 5)) {
          context.read(devicesStatus_Provider).state[deviceType]['isOnline'] =
              false;
        }
        await Future.delayed(Duration(seconds: 5));
      }
    } on Exception catch (e) {
      // TODO
    }
  }

  // startListeningStatus() async {
  //   try {
  //     print("Listening for battery and power status");
  //     receiver = await UDP.bind(Endpoint.any(port: Port(widget.port)));
  //     await receiver.listen((datagram) {
  //       var str = String.fromCharCodes(datagram.data);
  //       var tokens = str.split("=");
  //       var deviceStatus = tokens[1].split("&");
  //       if (tokens[0].trim() == "deviceStatus" &&
  //           deviceStatus[0] == deviceType) {
  //         setState(() {
  //           isOnline = true;
  //           lastStatusOn = DateTime.now();
  //         });

  //         if (deviceStatus[0] == deviceType) {
  //           var power = deviceStatus[1].split(':');
  //           if (power[0] == "Battery") {
  //             if (power[1] == "ON_USB_POW") {
  //               setState(() {
  //                 battery = -1;
  //               });
  //             } else {
  //               setState(() {
  //                 battery = int.parse(power[1]);
  //               });
  //             }
  //           }
  //         }
  //       }
  //     });
  //   } on Exception catch (e) {
  //     // TODO
  //     print(e.toString());
  //   }
  // }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    receiver.close();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    scanNetwork();
    setState(() {
      deviceType = widget.deviceType;
      icon = widget.icon;
    });
    // startListeningStatus();
  }

  @override
  Widget build(BuildContext context) {
    startCheckingStatus(context);
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
            displaySnackBar("Device Not Added Yet");
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
      onTap: () {
        if (isAdded) {
          openSettings(deviceType);
        } else {
          CoolAlert.show(
              context: context,
              type: CoolAlertType.confirm,
              title: "Device Not Found",
              text: "Would You like Add it now?",
              confirmBtnText: "Yes",
              onConfirmBtnTap: () {
                Navigator.pop(context);
                // displaySnackBar("Please Connect to Device Wifi");
                AppSettings.openWIFISettings();
                Navigator.popAndPushNamed(context, AddDeviceScreen.id,
                    arguments: {'deviceType': deviceType});
              },
              cancelBtnText: "Later",
              onCancelBtnTap: () {
                Navigator.pop(context);
              });
        }
      },
      onLongPress: () {
        CoolAlert.show(
            context: context,
            type: CoolAlertType.confirm,
            title: "Forget Device?",
            text: "Are you sure you want to forget this device?",
            confirmBtnText: "Yes",
            onConfirmBtnTap: () {
              forgetDevice(deviceType);
              Navigator.pop(context);
            },
            cancelBtnText: "No",
            onCancelBtnTap: () {
              Navigator.pop(context);
            });
      },
      onDoubleTap: () {
        openSettings(deviceType);
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[700], width: 2),
        ),
        child: Stack(
          // mainAxisAlignment: MainAxisAlignment.start,
          children: [
            new Image.asset(
              'assets/img/$icon',
              width: 50,
              height: 50,
            ),
            Positioned(
              // height: 20,
              // transform: Matrix4.translationValues(0, -15, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Consumer(builder: (context, watch, _) {
                    final onlineStatus = watch(devicesStatus_Provider)
                        .state[deviceType]['isOnline'];
                    return new Image.asset(
                      onlineStatus
                          ? 'assets/img/online.png'
                          : 'assets/img/offline.png',
                      width: 15,
                      height: 15,
                    );
                  }),
                  SizedBox(
                    width: 20,
                  ),
                  Consumer(builder: (context, watch, _) {
                    final onlineStatus = watch(devicesStatus_Provider)
                        .state[deviceType]['isOnline'];
                    print("$deviceType in Consumer status is $onlineStatus");
                    if (onlineStatus == true) {
                      return Container(
                          width: 15,
                          height: 15,
                          child: (battery == -1)
                              ? new Image.asset(
                                  'assets/img/usbPower.png',
                                  height: 15,
                                  width: 15,
                                )
                              : Text(
                                  '${battery.toString()}',
                                  style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 14,
                                      fontFamily: 'Bebas'),
                                ));
                    } else {
                      return Container();
                    }
                  }),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
