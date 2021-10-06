import 'package:flutter/material.dart';
import 'package:marbelous_esp32_app/screens/add_device_screen.dart';
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

class HomeScreen extends StatefulWidget {
  // HomeScreen({Key? key}) : super(key: key);
  static String id = "home_screen";

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

  Widget getCurrentWidget() {
    switch (currentWidget) {
      case "none":
        return Container(
          decoration: sectionCard,
          child: GestureDetector(
            onTap: () {
              Navigator.popAndPushNamed(context, AddDeviceScreen.id, arguments: {'deviceType': "starter"});
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
        return DeviceCard(
            title: "Starter", icon: "assets/img/starter.png", type: "starter");
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
            // floatingActionButton: FloatingActionButton(
            //   backgroundColor: Colors.grey[700],
            //   child: Icon(
            //     Icons.add_circle,
            //     size: 40,
            //     color: Colors.blue,
            //   ),
            //   onPressed: () {
            //     Navigator.push(context, MaterialPageRoute(builder: (context) {
            //       return AddDeviceScreen();
            //     }));
            //   },
            // ),
            appBar: AppBar(
              actions: [
                IconButton(
                  icon: Icon(Icons.add_circle),
                  color: Colors.white,
                  onPressed: () {
                    Navigator.popAndPushNamed(context, AddDeviceScreen.id);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.settings),
                  color: Colors.white,
                  onPressed: () {
                    Navigator.pushNamed(context, CommonSettings.id);
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

              // title: Text(
              //   "Marbellous MVP",
              //   style: TextStyle(
              //     color: Colors.white,
              //     fontFamily: 'Bebas',
              //     fontSize: 40,
              //     decoration: TextDecoration.overline,
              //   ),
              // ),
            ),
            body: Center(
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      "Marbelous App",
                      style: headingText,
                      textAlign: TextAlign.center,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: getCurrentWidget(),
                    ),
                    // Column(
                    //   children: <Widget>[
                    //     Container(
                    //       decoration: deviceCard,
                    //       child: Column(
                    //         children: [],
                    //       ),
                    //     ),
                    //   ],
                    // ),
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
                              new Image.asset(
                                'assets/img/starter.png',
                                width: 50,
                                height: 50,
                              )
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(),
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

class RoundedButton extends StatelessWidget {
  RoundedButton({this.color, this.onClick, this.title});
  final String title;
  final Color color;
  final Function onClick;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClick,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Bebas',
            ),
          ),
        ),
      ),
    );
  }
}

class DeviceCard extends StatefulWidget {
  // HomeScreen({Key? key}) : super(key: key);
  // static String id = "home_screen";
  DeviceCard({this.title, this.icon, this.type});
  final String title;
  final String icon;
  final String type;
  @override
  _DeviceCardState createState() => _DeviceCardState();
}

class _DeviceCardState extends State<DeviceCard> {
  //Starter Data
  int dropMarbles = 0;
  int dropMarbleInterval = 0;

  Widget starterData() {
    return Column(
      children: [
        RoundedButton(
          title: "Drop Marble",
          color: Colors.blue,
          onClick: () {},
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            RoundedButton(
              title: " - ",
              color: Colors.blue[300],
              onClick: () {
                if (dropMarbles > 0) {
                  setState(() {
                    dropMarbles--;
                  });
                }
              },
            ),
            Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2)),
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Text(this.dropMarbles.toString()),
              ),
            ),
            RoundedButton(
              title: " + ",
              color: Colors.blue[900],
              onClick: () {
                setState(() {
                  dropMarbles++;
                });
              },
            ),
          ],
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            RoundedButton(
              title: " - ",
              color: Colors.blue[300],
              onClick: () {
                if (dropMarbleInterval > 0) {
                  setState(() {
                    dropMarbleInterval--;
                  });
                }
              },
            ),
            Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2)),
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Text(this.dropMarbleInterval.toString()),
              ),
            ),
            RoundedButton(
              title: " + ",
              color: Colors.blue[900],
              onClick: () {
                setState(() {
                  dropMarbleInterval++;
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: deviceCard,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.teal[700],
              border: Border(
                bottom: BorderSide(
                  color: Colors.black,
                  width: 2,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                widget.title,
                style: TextStyle(
                    color: Colors.white, fontFamily: "Roboto", fontSize: 20),
              ),
            ),
          ),
          SizedBox(height: 1),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 2,
                  child: Image.asset(
                    widget.icon,
                    fit: BoxFit.cover,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: SizedBox(),
                ),
                Expanded(flex: 6, child: starterData()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
