import 'package:flutter/material.dart';
import 'dart:io';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:loading_overlay/loading_overlay.dart';
import './../constants.dart';
import './command_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  // HomeScreen({Key? key}) : super(key: key);
  static String id = "home_screen";

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> devices = [];
  bool isScanning = true;
  String selectedDevice;

  scanNetwork() async {
    print("Scanning Network");
    final info = NetworkInfo();
    var wifiIP = await info.getWifiIP();
    final String subnet = wifiIP.substring(0, wifiIP.lastIndexOf('.'));
    const port = 2255;

    // for (var i = 0; i < 256; i++) {
    //   String ip = '$subnet.$i';
    //   print("Scanning $ip");
    //   var url = Uri.parse("http://$ip/control?command=GET_NAME");
    //   try {
    //     http.Response res = await http.get(url);
    //     if (res.statusCode == 200) {
    //       print("Found device at $ip");
    //       var deviceName = res.body;
    //       setState(() {
    //         devices.add(deviceName);
    //       });
    //     } else {
    //       // currentResponse = "Error: ${res.statusCode}";
    //     }
    //   } on Exception catch (e) {
    //     // TODO
    //     print(e.toString());
    //   }
    // }

    print('Done');
    setState(() {
      isScanning = false;
    });
  }

  List<Widget> getTextWidgets(List<String> devices) {
    List<Widget> widgets = [
      Text(
        "Connected Devices",
        style: headingText,
      ),
      SizedBox(
        height: 50,
      ),
    ];
    for (var i = 0; i < devices.length; i++) {
      widgets.add(
        Container(
          decoration: deviceCard,
          width: 300,
          height: 50,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  devices[i],
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontFamily: 'Roboto',
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedDevice = devices[i];
                    });
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return CommandScreen(
                        deviceIP: selectedDevice,
                      );
                    }));
                  },
                  child: Text(
                    "Select",
                    style: buttonStyle,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      );
    }
    return widgets;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    scanNetwork();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SafeArea(
        child: LoadingOverlay(
          isLoading: isScanning,
          child: Scaffold(
            appBar: AppBar(
              title: Center(
                child: Text(
                  "Marbellous MVP",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Bebas',
                    fontSize: 40,
                    decoration: TextDecoration.overline,
                  ),
                ),
              ),
            ),
            body: Center(
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: devices.length == 0
                      ? <Widget>[
                          Text(
                            "No Devices Found",
                            style: headingText,
                          ),
                          SizedBox(
                            height: 50,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return CommandScreen(
                                  deviceIP: selectedDevice,
                                );
                              }));
                            },
                            child: Text("Run Custom Commmands",
                                style: buttonStyle),
                          ),
                        ]
                      : getTextWidgets(devices),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
