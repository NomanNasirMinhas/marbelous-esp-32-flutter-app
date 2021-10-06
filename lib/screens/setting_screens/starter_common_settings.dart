import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:udp/udp.dart';
import '../../constants.dart';
import 'package:localstore/localstore.dart';
import 'dart:io';
import 'package:localstorage/localstorage.dart';

class CommonSettings extends StatefulWidget {
  // CommonSettings({Key? key}) : super(key: key);
  static String id = "starter_common_settings";

  @override
  _CommonSettingsState createState() => _CommonSettingsState();
}

class _CommonSettingsState extends State<CommonSettings> {
  bool serverStarted = false;
  final info = NetworkInfo();
  var wifiIP;
  bool deviceFound = false;
  final cmdTextController = TextEditingController();
  var receiver;
  String deviceMac;
  String deviceType;
  String deviceName;
  String deviceIP;

  startUDPServer() async {
    try {
      receiver = await UDP.bind(Endpoint.any(port: Port(65000)));
      var wifi = await info.getWifiIP();
      setState(() {
        wifiIP = wifi;
        serverStarted = true;
      });
      print("UDP Server Started");
      await receiver.listen((datagram) {
        var str = String.fromCharCodes(datagram.data);
        var tokens = str.split(":");
        if (tokens[0].trim() == "device_info") {
          var deviceInfo = tokens[1].split("_");
          setState(() {
            deviceMac = deviceInfo[0];
            deviceName = deviceInfo[1];
            deviceType = deviceInfo[1];
            deviceIP = deviceInfo[2];
            deviceFound = true;
          });
        }
      });
    } on Exception catch (e) {
      // TODO
      print(e.toString());
    }
  }

  displaySnackBar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      // action: SnackBarAction(
      //   label: 'View',
      //   onPressed: () {
      //     // Some code to undo the change.
      //   },
      // ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  cancel() {
    displaySnackBar("Device Not Added");
    receiver.close();
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    startUDPServer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Common Settings',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Bebas',
              fontSize: 40,
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Common Settings")
              ],
            ),
          ),
        ));
  }
}
