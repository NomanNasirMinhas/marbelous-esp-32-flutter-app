import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:udp/udp.dart';
import './../constants.dart';
import 'package:localstore/localstore.dart';
import 'dart:io';
import 'package:localstorage/localstorage.dart';

class AddDeviceScreen extends StatefulWidget {
  // AddDeviceScreen({Key? key}) : super(key: key);
  static String id = "add_device_screen";

  @override
  _AddDeviceScreenState createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  bool serverStarted = false;
  final info = NetworkInfo();
  var wifiIP;
  bool deviceFound = false;
  final cmdTextController = TextEditingController();
  var receiver;
  String deviceID;
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
            deviceID = deviceInfo[0];
            deviceName = deviceInfo[0];
            deviceIP = deviceInfo[1];
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

  Future<void> addDevice() async {
    try {
      final db = Localstore.instance;
      // gets new id
      final id = db.collection('marbelous_devices').doc().id;

      // save the item
      await db
          .collection('marbelous_devices')
          .doc(id)
          .set({'name': deviceName, 'id': deviceID, 'ip': deviceIP});
      receiver.close();
      displaySnackBar("Device Added Successfully");
      Navigator.pop(context);
    } on Exception catch (e) {
      print(e.toString());
      cancel();
    }
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
            'Add Device',
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
                deviceFound
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                            SizedBox(
                              height: 50,
                            ),
                            Text(
                              "Found New Device....",
                              style: headingText,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "Enter a Device Name",
                              style: TextStyle(
                                fontSize: 20,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.bold,
                                color: Colors.amber[800],
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            TextField(
                              controller: cmdTextController,
                              // keyboardType: TextInputType.number,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Roboto",
                              ),
                              onChanged: (value) {
                                setState(() {
                                  deviceName = value;
                                });
                              },
                              decoration: kTextFieldDecoration.copyWith(
                                  hintText: deviceName),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "Device ID: $deviceID",
                              style: TextStyle(
                                  fontSize: 30,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[800]),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "Device IP: $deviceIP",
                              style: TextStyle(
                                  fontSize: 30,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[800]),
                            ),
                            SizedBox(
                              height: 50,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                ElevatedButton(
                                  onPressed: () {
                                    addDevice();
                                  },
                                  child: Text(
                                    "Add Device",
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    cancel();
                                  },
                                  child: Text(
                                    "Cancel",
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ])
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              height: 200,
                            ),
                            Text(
                              "Listening for new Device at\n${wifiIP}:65000...",
                              textAlign: TextAlign.center,
                              style: headingText,
                            ),
                          ],
                        ),
                      ),
              ],
            ),
          ),
        ));
  }
}
