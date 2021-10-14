import 'package:flutter/material.dart';
import 'package:marbelous_esp32_app/screens/home_screen.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:udp/udp.dart';
import './../constants.dart';
import 'package:localstore/localstore.dart';
import 'dart:io';
import 'package:localstorage/localstorage.dart';
import 'package:flutter/services.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'dart:io' show Platform;
import 'package:cool_alert/cool_alert.dart';
import 'package:app_settings/app_settings.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:http/http.dart' as http;

class AddDeviceScreen extends StatefulWidget {
  // AddDeviceScreen({Key? key}) : super(key: key);

  final String deviceType;
  AddDeviceScreen({this.deviceType});

  static String id = "add_device_screen";

  @override
  _AddDeviceScreenState createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  bool isLoading = false;

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

  String deviceToAdd;

  String wifi_ssd;
  String wifi_password;
  String hue_bridge_ip;

  getCurrentGlobalSettings() async {
    try {
      final db = Localstore.instance;
      var settings =
          await db.collection('global_settings').doc("global_settings").get();
      if (settings != null) {
        setState(() {
          wifi_ssd = settings['wifi_ssd'];
          wifi_password = settings['wifi_password'];
          hue_bridge_ip = settings['hue_bridge_ip'];
        });
        var ssid_url = Uri.parse(
            "http://192.168.4.1/control?command=wifi_ssid&value=$wifi_ssd");
        var password_url = Uri.parse(
            "http://192.168.4.1/control?command=wifi_password&value=$wifi_password");
        var restart_url =
            Uri.parse("http://192.168.4.1/control?command=restart");

        http.Response res =
            await http.get(ssid_url).timeout(Duration(seconds: 3));
        if (res.statusCode == 200) {
          http.Response res =
              await http.get(password_url).timeout(Duration(seconds: 3));
          if (res.statusCode == 200) {
            http.Response res =
                await http.get(restart_url).timeout(Duration(seconds: 3));
            if (res.statusCode == 200) {
              displaySnackBar("Global Setings Sent to Device");
            } else {
              displaySnackBar("Error in sending Restart Command");
            }
          } else {
            displaySnackBar("Error in sending Wifi Password");
          }
        } else {
          displaySnackBar("Error in sending Wifi SSID");
        }
        return true;
      } else {
        displaySnackBar("No Global Settings Found");
        return false;
      }
    } on Exception catch (e) {
      print(e.toString());
    }
  }

  startUDPServer() async {
    try {
      print("Starting search for $deviceToAdd");
      receiver = await UDP.bind(Endpoint.any(port: Port(65000)));
      var wifi = await info.getWifiIP();
      setState(() {
        wifiIP = wifi;
        serverStarted = true;
      });
      print("UDP Server Started");
      await receiver.listen((datagram) {
        var str = String.fromCharCodes(datagram.data);
        var tokens = str.split("=");
        if (tokens[0].trim() == "device_info") {
          var deviceInfo = tokens[1].split("_");
          if (deviceInfo[1] == deviceToAdd) {
            setState(() {
              deviceMac = deviceInfo[0];
              deviceName = deviceInfo[1];
              deviceType = deviceInfo[1];
              deviceIP = deviceInfo[2];
              deviceFound = true;
            });
          }
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
      // final id = db.collection('marbelous_devices').doc().id;

      // save the item
      await db.collection('marbelous_devices').doc(deviceMac).set({
        'name': deviceName,
        'macAddrr': deviceMac,
        'ip': deviceIP,
        'type': deviceType
      });
      receiver.close();
      displaySnackBar("Device Added Successfully");
      Navigator.popAndPushNamed(context, HomeScreen.id);
    } on Exception catch (e) {
      print(e.toString());
      cancel();
    }
  }

  cancel() {
    displaySnackBar("Device Not Added");
    receiver.close();
    Navigator.popAndPushNamed(context, HomeScreen.id);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context).settings.arguments as Map;
    setState(() {
      deviceToAdd = arguments['deviceType'];
    });
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
        body: LoadingOverlay(
          isLoading: isLoading,
          child: Center(
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
                                "Device Type: $deviceType",
                                style: TextStyle(
                                    fontSize: 30,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[800]),
                              ),
                              SizedBox(
                                height: 50,
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
                              Text(
                                "MAC Address: $deviceMac",
                                style: TextStyle(
                                    fontSize: 30,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[800]),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
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
                            children: serverStarted
                                ? [
                                    SizedBox(
                                      height: 200,
                                    ),
                                    Text(
                                      "Listening for new '$deviceToAdd' Device at\n${wifiIP}:65000...",
                                      textAlign: TextAlign.center,
                                      style: headingText,
                                    ),
                                    SizedBox(
                                      height: 30,
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        cancel();
                                      },
                                      child: Text("Cancel"),
                                    )
                                  ]
                                : [
                                    SizedBox(
                                      height: 200,
                                    ),
                                    Text(
                                      "Press Button Below to Start Adding the Device",
                                      textAlign: TextAlign.center,
                                      style: headingText,
                                    ),
                                    SizedBox(
                                      height: 30,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () async {
                                            var res =
                                                await getCurrentGlobalSettings();
                                            if (res == true) {
                                              startUDPServer();
                                            } else {
                                              CoolAlert.show(
                                                context: context,
                                                type: CoolAlertType.error,
                                                title:
                                                    "Global Settings Not Found",
                                                text:
                                                    "Please configure your Global Settings before adding a device.",
                                                confirmBtnText: "Go To Home",
                                                onConfirmBtnTap: () {
                                                  Navigator.pop(context);
                                                  Navigator.popAndPushNamed(
                                                      context, HomeScreen.id);
                                                },
                                              );
                                            }
                                            // openSettings();
                                          },
                                          child: Text("Add Device"),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.popAndPushNamed(
                                                context, HomeScreen.id);
                                          },
                                          child: Text("Cancel"),
                                        ),
                                      ],
                                    )
                                  ],
                          ),
                        ),
                ],
              ),
            ),
          ),
        ));
  }
}
