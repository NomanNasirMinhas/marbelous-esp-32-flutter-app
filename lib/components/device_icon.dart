import 'package:flutter/material.dart';
import 'package:marbelous_esp32_app/screens/home_screen.dart';
import 'package:marbelous_esp32_app/screens/setting_screens/starter_common_settings.dart';
import 'package:localstore/localstore.dart';
import 'package:udp/udp.dart';
import 'package:network_info_plus/network_info_plus.dart';

class DeviceIcon extends StatefulWidget {
  // const DeviceIcon({ Key? key }) : super(key: key);
  DeviceIcon({this.deviceType, this.icon, this.device_ip, this.isAdded});
  final String deviceType;
  final String icon;
  final String device_ip;
  final bool isAdded;
  @override
  _DeviceIconState createState() => _DeviceIconState();
}

class _DeviceIconState extends State<DeviceIcon> {
  String deviceType;
  String icon;
  String device_ip;
  bool isAdded;
  bool isOnline = false;
  int battery = -1;
  DateTime lastStatusOn = DateTime.now();
  Duration diff;
  startCheckingStatus() async {
    while (true) {
      diff = DateTime.now().difference(lastStatusOn);
      if (diff > Duration(seconds: 5)) {
        setState(() {
          isOnline = false;
          print("$deviceType is Offline Now");
        });
      }
      await Future.delayed(Duration(seconds: 5));
    }
  }

  startListeningStatus() async {
    try {
      print("Listening for battery and power status");
      var receiver = await UDP.bind(Endpoint.any(port: Port(65000)));
      await receiver.listen((datagram) {
        var str = String.fromCharCodes(datagram.data);
        var tokens = str.split("=");
        if (tokens[0].trim() == "deviceStatus") {
          setState(() {
            isOnline = true;
            lastStatusOn = DateTime.now();
          });
          var deviceStatus = tokens[1].split(":");
          if (deviceStatus[0] == "Battery") {
            if (deviceStatus[1] == "ON_USB_POW") {
              setState(() {
                battery = -1;
              });
            } else {
              setState(() {
                battery = int.parse(deviceStatus[1]);
              });
            }
          }
        }
      });
    } on Exception catch (e) {
      // TODO
      print(e.toString());
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      deviceType = widget.deviceType;
      icon = widget.icon;
      device_ip = widget.device_ip;
      isAdded = widget.isAdded;
    });
    startListeningStatus();
    startCheckingStatus();
  }

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
                  new Image.asset(
                    isOnline
                        ? 'assets/img/online.png'
                        : 'assets/img/offline.png',
                    width: 15,
                    height: 15,
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  isOnline
                      ? Container(
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
                                ))
                      : Container()
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
