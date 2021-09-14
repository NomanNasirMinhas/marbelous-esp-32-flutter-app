import 'package:flutter/material.dart';
import 'package:marbelous_esp32_app/screens/add_device_screen.dart';
import 'dart:io';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:loading_overlay/loading_overlay.dart';
import './../constants.dart';
import './command_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:localstore/localstore.dart';
import './../utilities/device_class.dart';

class HomeScreen extends StatefulWidget {
  // HomeScreen({Key? key}) : super(key: key);
  static String id = "home_screen";

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<MarbleDevice> devices = [];
  bool isScanning = true;
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
            id: value['id'],
            name: value['name'],
            ipAddrr: value['ip'],
            docID: key);
        // var idx = devices.indexOf(device);

        setState(() {
          devices.add(device);
        });
      });
    }

    print('Done');
    setState(() {
      isScanning = false;
    });
  }

  forgetDevice(String docID) async {
    var id = docID.split("/").last;
    print("Forgetting $id");
    final db = Localstore.instance;
    await db.collection('marbelous_devices').doc(id).delete();
    for (int i = 0; i < devices.length; i++) {
      print("Checking ${devices[i].docID}");
      if (devices[i].docID == docID) {
        setState(() {
          devices.removeAt(i);
          devices.join(', ');
        });
      }
    }
    // setState(() {
    //   devices.removeWhere((element) => element.docID == id);
    //   devices.join(', ');
    //   print(devices.length);
    //   scanNetwork();
    // });
  }

  List<Widget> getTextWidgets(List<MarbleDevice> devices) {
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
        Column(
          children: [
            Container(
              decoration: deviceCard,
              width: 300,
              // height: 150,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Name: ${devices[i].name}",
                      softWrap: true,
                      style: TextStyle(
                        fontSize: 30,
                        color: Colors.black,
                        fontFamily: 'Bebas',
                      ),
                    ),
                    Text(
                      "Device ID: ${devices[i].id}",
                      softWrap: true,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    Text(
                      "Device IP: ${devices[i].ipAddrr}",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  selectedDevice = devices[i].name;
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
                          ),
                          flex: 3,
                        ),
                        Expanded(
                          flex: 2,
                          child: SizedBox(),
                        ),
                        Expanded(
                          flex: 5,
                          child: Row(children: <Widget>[
                            ElevatedButton(
                              onPressed: () {
                                // setState(() {
                                //   selectedDevice = devices[i].name;
                                // });
                                // Navigator.push(context,
                                //     MaterialPageRoute(builder: (context) {
                                //   return CommandScreen(
                                //     deviceIP: selectedDevice,
                                //   );
                                // }));
                              },
                              child: Icon(
                                Icons.edit,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () {
                                forgetDevice(devices[i].docID.toString());
                              },
                              child: Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                          ]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
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
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.amber[900],
              child: Icon(
                Icons.add_circle,
                size: 40,
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return AddDeviceScreen();
                }));
              },
            ),
            appBar: AppBar(
              actions: [
                IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: () {
                    scanNetwork();
                  },
                ),
              ],
              title: Text(
                "Marbellous MVP",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Bebas',
                  fontSize: 40,
                  decoration: TextDecoration.overline,
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
