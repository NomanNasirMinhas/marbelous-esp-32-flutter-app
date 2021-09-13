import 'package:flutter/material.dart';
import 'dart:io';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:loading_overlay/loading_overlay.dart';
import '../constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CommandScreen extends StatefulWidget {
  // CommandScreen({Key? key}) : super(key: key);
  static String id = "command_screen";
  CommandScreen({this.deviceIP});

  final String deviceIP;
  @override
  _CommandScreenState createState() => _CommandScreenState();
}

class _CommandScreenState extends State<CommandScreen> {
  bool isScanning = false;
  bool showRecentCmd = false;
  String ipAddress;
  final cmdTextController = TextEditingController();
  String currentCommand = "";
  String currentResponse;
  List<String> recentCommands = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      ipAddress = widget.deviceIP;
    });
  }

  Future<void> sendCommand(String cmd) async {
    setState(() {
      showRecentCmd = false;
    });
    try {
      print(cmd);
      var url = Uri.parse(cmd.trim());
      http.Response res = await http.get(url);
      if (res.statusCode == 200) {
        var decodedData = res.body;
        setState(() {
          currentResponse = decodedData;
        });
      } else {
        currentResponse = "Error: ${res.statusCode}";
      }
      setState(() {
        recentCommands.add(cmd.trim());
      });
    } catch (e) {
      print(e);
      setState(() {
        currentResponse = e.toString();
      });
    }
  }

  List<Widget> recentCommandsList() {
    List<Widget> list = [];
    if (recentCommands.length > 0) {
      for (var i = 0; i < recentCommands.length; i++) {
        list.add(
          GestureDetector(
            onTap: () {
              setState(() {
                currentCommand = recentCommands[i];
                showRecentCmd = false;
              });
            },
            child: Container(
              decoration: deviceCard,
              width: 300,
              height: 50,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      recentCommands[i],
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    } else {
      list.add(
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
                  "No Recent Command Found",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontFamily: 'Bebas',
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    setState(() {
      currentResponse = null;
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SafeArea(
        child: LoadingOverlay(
          isLoading: isScanning,
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                "Marbellous MVP",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Bebas',
                  fontSize: 40,
                ),
              ),
            ),
            body: SafeArea(
              child: Center(
                child: Container(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: ListView(
                      // mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          ipAddress == null
                              ? "No Device Selected"
                              : "$ipAddress Selected",
                          style: headingText,
                        ),
                        SizedBox(
                          height: 20,
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
                              currentCommand = value;
                            });
                          },
                          decoration: kTextFieldDecoration,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                child: Text("Send Command", style: buttonStyle),
                                onPressed: () async {
                                  setState(() {
                                    isScanning = true;
                                  });
                                  await sendCommand(currentCommand);
                                  setState(() {
                                    currentCommand = "";
                                    cmdTextController.clear();
                                    isScanning = false;
                                  });
                                },
                              ),
                              flex: 2,
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Expanded(
                              child: ElevatedButton(
                                child:
                                    Text("Recent Commands", style: buttonStyle),
                                onPressed: () {
                                  setState(() {
                                    showRecentCmd = !showRecentCmd;
                                  });
                                },
                              ),
                              flex: 2,
                            )
                          ],
                        ),
                        SizedDivider(),
                        showRecentCmd == true
                            ? Column(
                                children: recentCommandsList(),
                              )
                            : Container(),
                        currentResponse == null
                            ? Container()
                            : Text(
                                "$currentResponse",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 30,
                                  fontFamily: 'Roboto',
                                ),
                                softWrap: true,
                                // textAlign: TextAlign.justify,
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SizedDivider extends StatelessWidget {
  const SizedDivider({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 20,
        ),
        Divider(
          color: Colors.black,
        ),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }
}
