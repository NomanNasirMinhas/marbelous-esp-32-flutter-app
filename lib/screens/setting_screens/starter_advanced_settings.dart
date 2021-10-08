import 'package:flutter/material.dart';
import 'package:marbelous_esp32_app/components/round_button.dart';
import 'package:marbelous_esp32_app/constants.dart';
import 'package:marbelous_esp32_app/screens/setting_screens/starter_common_settings.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:udp/udp.dart';
// import './../constants.dart';
import 'package:localstore/localstore.dart';
import 'dart:io';
import 'package:localstorage/localstorage.dart';

class StarterAdvancedSettings extends StatefulWidget {
  // StarterAdvancedSettings({Key? key}) : super(key: key);
  static String id = "starter_advanced_settings";

  @override
  _AdvancedSettingsState createState() => _AdvancedSettingsState();
}

class _AdvancedSettingsState extends State<StarterAdvancedSettings> {
  final cmdTextController = TextEditingController();
  int autoOffBatt = 0;
  int autoOffUSB = 0;
  int keepAliveInterval = 0;
  String MQTT_pass;
  String MQTT_cmd1;
  String MQTT_url1;
  String MQTT_cmd2;
  String MQTT_url2;
  String trigerUL;
  bool wifiEnabled;
  String cmdToDropMarble;
  bool shutdownSoundEnabled;

  displaySnackBar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  cancel() {
    displaySnackBar("Device Not Added");
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Advanced Settings',
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
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: new Image.asset('assets/img/starter.png'),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(),
                    ),
                    Expanded(
                      flex: 5,
                      child: InfoText(
                        text:
                            "Here you can find the advanced settings from the starter. Change them as you like and press 'Save' to save them into the device or 'Back' button to go to homepage.",
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 30,
                ),
                SizedDivider(),
                Column(
                  children: [
                    Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        BoldInfoText(
                          text: "Auto-Off after [",
                        ),
                        SizedBox(
                          width: 70,
                          child: TextField(
                            // maxLength: 3,
                            controller: cmdTextController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.left,
                            style: boldInfoText,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  try {
                                    autoOffBatt = int.parse(value);
                                  } on Exception catch (e) {
                                    // TODO
                                    setState(() {
                                      autoOffBatt = 0;
                                    });
                                    print(value);
                                    print(e);
                                  }
                                });
                              }
                            },
                            decoration:
                                settingInputField.copyWith(hintText: "0-600"),
                          ),
                        ),
                        BoldInfoText(
                          text: "] minutes inactivity.",
                        ),
                      ],
                    ),
                    InfoText(
                      text: "(when operating on internal batteries)",
                    )
                  ],
                ),
                SizedDivider(),
                Column(
                  children: [
                    Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        BoldInfoText(
                          text: "Auto-Off after [",
                        ),
                        SizedBox(
                          width: 70,
                          child: TextField(
                            // maxLength: 3,
                            controller: cmdTextController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.left,
                            style: boldInfoText,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  try {
                                    autoOffBatt = int.parse(value);
                                  } on Exception catch (e) {
                                    // TODO
                                    setState(() {
                                      autoOffBatt = 0;
                                    });
                                    print(value);
                                    print(e);
                                  }
                                });
                              }
                            },
                            decoration:
                                settingInputField.copyWith(hintText: "0-600"),
                          ),
                        ),
                        BoldInfoText(
                          text: "] minutes inactivity.",
                        ),
                      ],
                    ),
                    InfoText(
                      text: "(when operating on external USB supply)",
                    )
                  ],
                ),
                SizedDivider(),
                Column(
                  children: [
                    Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        BoldInfoText(
                          text: "Keep Alive interval [",
                        ),
                        SizedBox(
                          width: 70,
                          child: TextField(
                            // maxLength: 3,
                            controller: cmdTextController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.left,
                            style: boldInfoText,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  try {
                                    autoOffBatt = int.parse(value);
                                  } on Exception catch (e) {
                                    // TODO
                                    setState(() {
                                      autoOffBatt = 0;
                                    });
                                    print(value);
                                    print(e);
                                  }
                                });
                              }
                            },
                            decoration:
                                settingInputField.copyWith(hintText: "0-600"),
                          ),
                        ),
                        BoldInfoText(
                          text: "] seconds.",
                        ),
                      ],
                    ),
                    InfoText(
                      text: "(to keep powerbank 'alive')",
                    )
                  ],
                ),
                SizedDivider(),
                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    BoldInfoText(
                      text: "MQTT Password:",
                    ),
                    SizedBox(
                      width: 200,
                      child: TextField(
                        // maxLength: 3,
                        controller: cmdTextController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.left,
                        style: boldInfoText,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              try {
                                autoOffBatt = int.parse(value);
                              } on Exception catch (e) {
                                // TODO
                                setState(() {
                                  autoOffBatt = 0;
                                });
                                print(value);
                                print(e);
                              }
                            });
                          }
                        },
                        decoration: settingInputField.copyWith(hintText: ""),
                      ),
                    ),
                  ],
                ),
                SizedDivider(),
                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    BoldInfoText(
                      text: "MQTT Command1 [",
                    ),
                    SizedBox(
                      width: 75,
                      child: TextField(
                        // maxLength: 3,
                        controller: cmdTextController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.left,
                        style: boldInfoText,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              try {
                                autoOffBatt = int.parse(value);
                              } on Exception catch (e) {
                                // TODO
                                setState(() {
                                  autoOffBatt = 0;
                                });
                                print(value);
                                print(e);
                              }
                            });
                          }
                        },
                        decoration: settingInputField.copyWith(hintText: ""),
                      ),
                    ),
                    BoldInfoText(
                      text: "] URL1: [",
                    ),
                    SizedBox(
                      width: 75,
                      child: TextField(
                        // maxLength: 3,
                        controller: cmdTextController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.left,
                        style: boldInfoText,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              try {
                                autoOffBatt = int.parse(value);
                              } on Exception catch (e) {
                                // TODO
                                setState(() {
                                  autoOffBatt = 0;
                                });
                                print(value);
                                print(e);
                              }
                            });
                          }
                        },
                        decoration: settingInputField.copyWith(hintText: ""),
                      ),
                    ),
                    BoldInfoText(
                      text: "]",
                    ),
                  ],
                ),
                SizedDivider(),
                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    BoldInfoText(
                      text: "MQTT Command2 [",
                    ),
                    SizedBox(
                      width: 75,
                      child: TextField(
                        // maxLength: 3,
                        controller: cmdTextController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.left,
                        style: boldInfoText,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              try {
                                autoOffBatt = int.parse(value);
                              } on Exception catch (e) {
                                // TODO
                                setState(() {
                                  autoOffBatt = 0;
                                });
                                print(value);
                                print(e);
                              }
                            });
                          }
                        },
                        decoration: settingInputField.copyWith(hintText: ""),
                      ),
                    ),
                    BoldInfoText(
                      text: "] URL2: [",
                    ),
                    SizedBox(
                      width: 75,
                      child: TextField(
                        // maxLength: 3,
                        controller: cmdTextController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.left,
                        style: boldInfoText,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              try {
                                autoOffBatt = int.parse(value);
                              } on Exception catch (e) {
                                // TODO
                                setState(() {
                                  autoOffBatt = 0;
                                });
                                print(value);
                                print(e);
                              }
                            });
                          }
                        },
                        decoration: settingInputField.copyWith(hintText: ""),
                      ),
                    ),
                    BoldInfoText(
                      text: "]",
                    ),
                  ],
                ),
                SizedDivider(),
                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    BoldInfoText(
                      text: "Trigger URL after drop marble [",
                    ),
                    SizedBox(
                      width: 100,
                      child: TextField(
                        // maxLength: 3,
                        controller: cmdTextController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.left,
                        style: boldInfoText,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              try {
                                autoOffBatt = int.parse(value);
                              } on Exception catch (e) {
                                // TODO
                                setState(() {
                                  autoOffBatt = 0;
                                });
                                print(value);
                                print(e);
                              }
                            });
                          }
                        },
                        decoration: settingInputField.copyWith(hintText: ""),
                      ),
                    ),
                    BoldInfoText(
                      text: "]",
                    ),
                  ],
                ),
                SizedDivider(),
                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    BoldInfoText(
                      text: "Wifi Enabled",
                    ),
                    SizedBox(
                      width: 100,
                    ),
                    wifiEnabled == true
                        ? GestureDetector(
                            onTap: () {
                              setState(() {
                                wifiEnabled = false;
                              });
                            },
                            child: CheckedBox(),
                          )
                        : GestureDetector(
                            onTap: () {
                              setState(() {
                                wifiEnabled = true;
                              });
                            },
                            child: UnCheckedBox(),
                          )
                  ],
                ),
                SizedDivider(),
                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    BoldInfoText(
                      text: "Command to drop marble [",
                    ),
                    SizedBox(
                      width: 100,
                      child: TextField(
                        // maxLength: 3,
                        controller: cmdTextController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.left,
                        style: boldInfoText,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              try {
                                autoOffBatt = int.parse(value);
                              } on Exception catch (e) {
                                // TODO
                                setState(() {
                                  autoOffBatt = 0;
                                });
                                print(value);
                                print(e);
                              }
                            });
                          }
                        },
                        decoration: settingInputField.copyWith(hintText: ""),
                      ),
                    ),
                    BoldInfoText(
                      text: "]",
                    ),
                  ],
                ),
                SizedDivider(),
                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    BoldInfoText(
                      text: "Shutdown alert sound enabled",
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    shutdownSoundEnabled == true
                        ? GestureDetector(
                            onTap: () {
                              setState(() {
                                shutdownSoundEnabled = false;
                              });
                            },
                            child: CheckedBox(),
                          )
                        : GestureDetector(
                            onTap: () {
                              setState(() {
                                shutdownSoundEnabled = true;
                              });
                            },
                            child: UnCheckedBox(),
                          )
                  ],
                ),
                SizedDivider(),
                SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    RoundedButton(
                      color: Colors.orange[800],
                      title: "Back",
                      onClick: () {
                        Navigator.pop(context);
                      },
                    ),
                    RoundedButton(
                      color: Colors.green[800],
                      title: "Save",
                      onClick: () {
                        // Navigator.pop(context);
                      },
                    ),
                  ],
                ),
                SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
        ));
  }
}

class SizedDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SizedBox(
        height: 1,
        child: Container(
          color: Colors.grey,
        ),
      ),
    );
  }
}

class InfoText extends StatelessWidget {
  final String text;
  InfoText({this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      softWrap: true,
      style: infoText,
      textAlign: TextAlign.justify,
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

class CheckedBox extends StatelessWidget {
  final String title;
  CheckedBox({this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(width: 2, color: Colors.black),
            // color: Colors.green[800],
          ),
          height: 20,
          width: 20,
          child: Icon(
            Icons.check_circle,
            color: Colors.green,
          ),
        ),
        title == null ? Container() : BoldInfoText(text: title),
      ],
    );
  }
}

class UnCheckedBox extends StatelessWidget {
  final String title;
  UnCheckedBox({this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(width: 2, color: Colors.black),
            // color: Colors.white,
          ),
          height: 20,
          width: 20,
          child: Icon(
            Icons.cancel_rounded,
            color: Colors.red[900],
          ),
        ),
        title == null ? Container() : BoldInfoText(text: title),
      ],
    );
  }
}
