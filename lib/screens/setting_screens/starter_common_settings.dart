import 'package:flutter/material.dart';
import 'package:marbelous_esp32_app/components/round_button.dart';
import 'package:marbelous_esp32_app/screens/setting_screens/starter_advanced_settings.dart';
import 'package:marbelous_esp32_app/utilities/colors_class.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:udp/udp.dart';
import '../../constants.dart';
import 'package:localstore/localstore.dart';
import 'dart:io';
import 'package:localstorage/localstorage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:loading_overlay/loading_overlay.dart';

class StarterCommonSettings extends StatefulWidget {
  // StarterCommonSettings({Key? key}) : super(key: key);
  static String id = "starter_common_settings";

  @override
  _CommonSettingsState createState() => _CommonSettingsState();
}

class _CommonSettingsState extends State<StarterCommonSettings> {
  bool loading = false;
  List<RGBColor> colors = [];
  List<Widget> idleArrowBoxes = [];
  List<Widget> dropArrowBoxes = [];
  TextEditingController cmdTextController;
  String starter_ip;

  String idleActiveColor = "";
  String dropActiveColor = "";
  RGBColor idleColor = new RGBColor(name: 'red', red: 255, green: 0, blue: 0);
  RGBColor dropColor = new RGBColor(name: 'red', red: 255, green: 0, blue: 0);
  bool beatingLEDactive = false;
  bool autoOffSoundActive = false;
  int dropMarbleSound = 0;
  double wheelSpeed = 1;
  String name = "";

  BoxDecoration inactiveBox = BoxDecoration(
      border: Border.all(
    width: 1,
    color: Colors.black,
  ));

  BoxDecoration activeBox = BoxDecoration(
    border: Border.all(
      width: 3,
      color: Colors.black,
    ),
  );

  addColors() {
    RGBColor red = new RGBColor(name: 'red', red: 255, green: 0, blue: 0);
    RGBColor orange =
        new RGBColor(name: 'orange', red: 255, green: 165, blue: 0);
    RGBColor yellow =
        new RGBColor(name: 'yellow', red: 255, green: 255, blue: 0);
    RGBColor green = new RGBColor(name: 'green', red: 0, green: 128, blue: 0);
    RGBColor blue = new RGBColor(name: 'blue', red: 0, green: 0, blue: 255);
    RGBColor voilet =
        new RGBColor(name: 'voilet', red: 238, green: 130, blue: 238);
    RGBColor white =
        new RGBColor(name: 'white', red: 255, green: 255, blue: 255);

    colors.add(red);
    colors.add(orange);
    colors.add(yellow);
    colors.add(green);
    colors.add(blue);
    colors.add(voilet);
    colors.add(white);
  }

  fetchCurrentSettings() async {
    var url = Uri.parse("http://$starter_ip/control?command=getCommonSettings");
    http.Response res = await http.get(url);
    if (res.statusCode == 200) {
      //commonSettings=breating_active:val,arrow_color_idle:R-G-B,arrow_color_dropmarble:R-G-B,dropmarble_sound:val,auto_off_sound:val,wheel_speed:val,device_name:val

    } else {}
  }

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

  List<Widget> getIdleArrowColor() {
    if (colors.length == 0) {
      addColors();
    }

    if (idleArrowBoxes.length == 0) {
      for (int i = 0; i < 7; i++) {
        setState(() {
          idleArrowBoxes.add(
            GestureDetector(
              onTap: () {
                setState(() {
                  idleActiveColor = colors[i].name;
                });
                print("$idleActiveColor = ${colors[i].name} Selected");
              },
              child: Container(
                decoration:
                    idleActiveColor == colors[i].name ? activeBox : inactiveBox,
                child: GestureDetector(
                  child: ColorBox(
                    color: colors[i],
                  ),
                ),
              ),
            ),
          );
        });
      }
    }
    return idleArrowBoxes;
  }

  List<Widget> getDropArrowColor() {
    if (colors.length == 0) {
      addColors();
    }

    if (dropArrowBoxes.length == 0) {
      for (int i = 0; i < 7; i++) {
        setState(() {
          dropArrowBoxes.add(
            GestureDetector(
              onTap: () {
                setState(() {
                  dropActiveColor = colors[i].name;
                });
              },
              child: Container(
                decoration:
                    dropActiveColor == colors[i].name ? activeBox : inactiveBox,
                child: ColorBox(
                  color: colors[i],
                ),
              ),
            ),
          );
        });
      }
    }
    return dropArrowBoxes;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context).settings.arguments as Map;
    setState(() {
      starter_ip = arguments['starter_ip'];
    });
    List<String> settings_commands = [
      "http://$starter_ip/control?command=breating_active&state=${beatingLEDactive == true ? 1 : 0}",
      "http://$starter_ip/control?command=arrow_color_idle&R=${idleColor.red}&G=${idleColor.green}&B=${idleColor.blue}",
      "http://$starter_ip/control?command=arrow_color_dropmarble&R=${dropColor.red}&G=${dropColor.green}&B=${dropColor.blue}",
      "http://$starter_ip/control?command=dropmarble_sound&state=$dropMarbleSound",
      "http://$starter_ip/control?command=auto_off_sound&state=${autoOffSoundActive == true ? 1 : 0}",
      "http://$starter_ip/control?command=wheel_speed&data=$wheelSpeed",
      "http://$starter_ip/control?command=device_name&data=$name"
    ];
    addColors();

    Future<void> storeSettings() async {
      try {
        final db = Localstore.instance;

        await db
            .collection('starter_common_settings')
            .doc('starter_common_settings')
            .set({
          'beatingLEDactive': beatingLEDactive,
          // 'idleColor': new RGBColor(
          //     blue: idleColor.blue,
          //     red: idleColor.red,
          //     green: idleColor.green,
          //     name: "arrow_color_idle"),
          // 'dropColor': new RGBColor(
          //     blue: dropColor.blue,
          //     red: dropColor.red,
          //     green: dropColor.green,
          //     name: "arrow_color_dropmarble"),
          'dropMarbleSound': dropMarbleSound,
          'autoOffSoundActive': autoOffSoundActive,
          'wheelSpeed': wheelSpeed,
          'name': name
        });
      } on Exception catch (e) {
        print(e.toString());
        cancel();
      }
    }

    saveSettings() async {
      setState(() {
        loading = true;
      });
      await storeSettings();
      try {
        settings_commands.forEach((element) async {
          var url = Uri.parse(element.trim());
          http.Response res = await http.get(url).timeout(Duration(seconds: 3));
          if (res.statusCode == 200) {
            print("OK Cmd = $element");
          } else {
            print("Failed Cmd = $element");
          }
        });
        setState(() {
          loading = false;
        });
        displaySnackBar("Settings Updated");
        Navigator.pop(context);
      } on TimeoutException catch (e) {
        displaySnackBar("Command Timeout");
      } on Error catch (e) {
        print(e);
        setState(() {
          loading = false;
        });
        displaySnackBar("Error in Updating Settings");
      }
    }

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
                SizedBox(
                  height: 30,
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
                            "Here you can find the settings from the starter. Change them as you like and press 'Save' to save them into the device. For advanced settings please press 'Advanced Settings', or 'Back' button to go to previous page.",
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 30,
                ),
                SizedDivider(),
                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: BoldInfoText(
                        text: "Breathing LED's Active",
                      ),
                    ),
                    Expanded(
                      child: beatingLEDactive == true
                          ? GestureDetector(
                              onTap: () {
                                setState(() {
                                  beatingLEDactive = false;
                                });
                              },
                              child: CheckedBox())
                          : GestureDetector(
                              onTap: () {
                                setState(() {
                                  beatingLEDactive = true;
                                });
                              },
                              child: UnCheckedBox()),
                    )
                  ],
                ),
                SizedDivider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      flex: 1,
                      child: BoldInfoText(text: "Arrow Color (Idle)"),
                    ),
                    Expanded(
                      flex: 2,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          //0
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                idleActiveColor = colors[0].name;
                                idleColor = colors[0];
                              });
                              print(
                                  "$idleActiveColor = ${colors[0].name} Selected");
                            },
                            child: Container(
                              decoration: idleActiveColor == colors[0].name
                                  ? activeBox
                                  : inactiveBox,
                              child: GestureDetector(
                                child: ColorBox(
                                  color: colors[0],
                                ),
                              ),
                            ),
                          ),
                          //1
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                idleActiveColor = colors[1].name;
                                idleColor = colors[1];
                              });
                              print(
                                  "$idleActiveColor = ${colors[1].name} Selected");
                            },
                            child: Container(
                              decoration: idleActiveColor == colors[1].name
                                  ? activeBox
                                  : inactiveBox,
                              child: GestureDetector(
                                child: ColorBox(
                                  color: colors[1],
                                ),
                              ),
                            ),
                          ),
                          //2
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                idleActiveColor = colors[2].name;
                                idleColor = colors[2];
                              });
                              print(
                                  "$idleActiveColor = ${colors[2].name} Selected");
                            },
                            child: Container(
                              decoration: idleActiveColor == colors[2].name
                                  ? activeBox
                                  : inactiveBox,
                              child: GestureDetector(
                                child: ColorBox(
                                  color: colors[2],
                                ),
                              ),
                            ),
                          ),
                          //3
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                idleActiveColor = colors[3].name;
                                idleColor = colors[3];
                              });
                              print(
                                  "$idleActiveColor = ${colors[3].name} Selected");
                            },
                            child: Container(
                              decoration: idleActiveColor == colors[3].name
                                  ? activeBox
                                  : inactiveBox,
                              child: GestureDetector(
                                child: ColorBox(
                                  color: colors[3],
                                ),
                              ),
                            ),
                          ),
                          //4
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                idleActiveColor = colors[4].name;
                                idleColor = colors[4];
                              });
                              print(
                                  "$idleActiveColor = ${colors[4].name} Selected");
                            },
                            child: Container(
                              decoration: idleActiveColor == colors[4].name
                                  ? activeBox
                                  : inactiveBox,
                              child: GestureDetector(
                                child: ColorBox(
                                  color: colors[4],
                                ),
                              ),
                            ),
                          ),
                          //5
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                idleActiveColor = colors[5].name;
                                idleColor = colors[5];
                              });
                              print(
                                  "$idleActiveColor = ${colors[5].name} Selected");
                            },
                            child: Container(
                              decoration: idleActiveColor == colors[5].name
                                  ? activeBox
                                  : inactiveBox,
                              child: GestureDetector(
                                child: ColorBox(
                                  color: colors[5],
                                ),
                              ),
                            ),
                          ),
                          //6
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                idleActiveColor = colors[6].name;
                                idleColor = colors[6];
                              });
                              print(
                                  "$idleActiveColor = ${colors[6].name} Selected");
                            },
                            child: Container(
                              decoration: idleActiveColor == colors[6].name
                                  ? activeBox
                                  : inactiveBox,
                              child: GestureDetector(
                                child: ColorBox(
                                  color: colors[6],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedDivider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      flex: 1,
                      child: BoldInfoText(text: "Arrow Color (Drop Marble)"),
                    ),
                    Expanded(
                      flex: 2,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          //0
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                dropActiveColor = colors[0].name;
                                dropColor = colors[0];
                              });
                            },
                            child: Container(
                              decoration: dropActiveColor == colors[0].name
                                  ? activeBox
                                  : inactiveBox,
                              child: GestureDetector(
                                child: ColorBox(
                                  color: colors[0],
                                ),
                              ),
                            ),
                          ),
                          //1
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                dropActiveColor = colors[1].name;
                                dropColor = colors[1];
                              });
                            },
                            child: Container(
                              decoration: dropActiveColor == colors[1].name
                                  ? activeBox
                                  : inactiveBox,
                              child: GestureDetector(
                                child: ColorBox(
                                  color: colors[1],
                                ),
                              ),
                            ),
                          ),
                          //2
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                dropActiveColor = colors[2].name;
                                dropColor = colors[2];
                              });
                            },
                            child: Container(
                              decoration: dropActiveColor == colors[2].name
                                  ? activeBox
                                  : inactiveBox,
                              child: GestureDetector(
                                child: ColorBox(
                                  color: colors[2],
                                ),
                              ),
                            ),
                          ),
                          //3
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                dropActiveColor = colors[3].name;
                                dropColor = colors[3];
                              });
                            },
                            child: Container(
                              decoration: dropActiveColor == colors[3].name
                                  ? activeBox
                                  : inactiveBox,
                              child: GestureDetector(
                                child: ColorBox(
                                  color: colors[3],
                                ),
                              ),
                            ),
                          ),
                          //4
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                dropActiveColor = colors[4].name;
                                dropColor = colors[4];
                              });
                            },
                            child: Container(
                              decoration: dropActiveColor == colors[4].name
                                  ? activeBox
                                  : inactiveBox,
                              child: GestureDetector(
                                child: ColorBox(
                                  color: colors[4],
                                ),
                              ),
                            ),
                          ),
                          //5
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                dropActiveColor = colors[5].name;
                                dropColor = colors[5];
                              });
                            },
                            child: Container(
                              decoration: dropActiveColor == colors[5].name
                                  ? activeBox
                                  : inactiveBox,
                              child: GestureDetector(
                                child: ColorBox(
                                  color: colors[5],
                                ),
                              ),
                            ),
                          ),
                          //6
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                dropActiveColor = colors[6].name;
                                dropColor = colors[6];
                              });
                            },
                            child: Container(
                              decoration: dropActiveColor == colors[6].name
                                  ? activeBox
                                  : inactiveBox,
                              child: GestureDetector(
                                child: ColorBox(
                                  color: colors[6],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedDivider(),
                Row(
                  children: [
                    Expanded(
                      child: BoldInfoText(
                        text: "Drop Marble Sound: ",
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          //Off
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                dropMarbleSound = 0;
                              });
                            },
                            child: (dropMarbleSound == 0)
                                ? CheckedBox(
                                    title: "Off",
                                  )
                                : UnCheckedBox(
                                    title: "Off",
                                  ),
                          ),
                          //1
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                dropMarbleSound = 1;
                              });
                            },
                            child: (dropMarbleSound == 1)
                                ? CheckedBox(
                                    title: "1",
                                  )
                                : UnCheckedBox(
                                    title: "1",
                                  ),
                          ),
                          //2
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                dropMarbleSound = 2;
                              });
                            },
                            child: (dropMarbleSound == 2)
                                ? CheckedBox(
                                    title: "2",
                                  )
                                : UnCheckedBox(
                                    title: "2",
                                  ),
                          ),
                          //3
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                dropMarbleSound = 3;
                              });
                            },
                            child: (dropMarbleSound == 3)
                                ? CheckedBox(
                                    title: "3",
                                  )
                                : UnCheckedBox(
                                    title: "3",
                                  ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                SizedDivider(),
                Row(
                  children: [
                    Expanded(
                      child: BoldInfoText(
                        text: "Auto-Off Sound Active",
                      ),
                    ),
                    Expanded(
                      child: autoOffSoundActive == true
                          ? GestureDetector(
                              onTap: () {
                                setState(() {
                                  autoOffSoundActive = false;
                                });
                              },
                              child: CheckedBox(),
                            )
                          : GestureDetector(
                              onTap: () {
                                setState(() {
                                  autoOffSoundActive = true;
                                });
                              },
                              child: UnCheckedBox(),
                            ),
                    )
                  ],
                ),
                SizedDivider(),
                Row(
                  children: [
                    Expanded(
                      child: BoldInfoText(
                        text: "Wheel Speed: ",
                      ),
                    ),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Colors.teal[700],
                          inactiveTrackColor: Colors.teal[100],
                          trackShape: RoundedRectSliderTrackShape(),
                          trackHeight: 4.0,
                          thumbShape:
                              RoundSliderThumbShape(enabledThumbRadius: 12.0),
                          thumbColor: Colors.tealAccent,
                          overlayColor: Colors.teal.withAlpha(32),
                          overlayShape:
                              RoundSliderOverlayShape(overlayRadius: 28.0),
                          tickMarkShape: RoundSliderTickMarkShape(),
                          activeTickMarkColor: Colors.teal[700],
                          inactiveTickMarkColor: Colors.teal[100],
                          valueIndicatorShape:
                              PaddleSliderValueIndicatorShape(),
                          valueIndicatorColor: Colors.tealAccent,
                          valueIndicatorTextStyle: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        child: Slider(
                          value: wheelSpeed,
                          min: 1,
                          max: 3,
                          divisions: 2,
                          label: '$wheelSpeed',
                          onChanged: (value) {
                            setState(
                              () {
                                wheelSpeed = value;
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                SizedDivider(),
                Column(
                  children: [
                    BoldInfoText(
                      text: "Name: ${name == null ? 'Not Set' : '$name'}",
                    ),
                    TextField(
                      controller: cmdTextController,
                      // keyboardType: TextInputType.number,
                      textAlign: TextAlign.left,
                      style: boldInfoText,
                      onChanged: (value) {
                        setState(() {
                          name = value;
                        });
                      },
                      decoration: kTextFieldDecoration.copyWith(
                          hintText: "Enter New Name"),
                    )
                  ],
                ),
                SizedDivider(),
                SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RoundedButton(
                      color: Colors.orange[800],
                      title: "Back",
                      onClick: () {
                        Navigator.pop(context);
                      },
                    ),
                    RoundedButton(
                      color: Colors.teal[800],
                      title: "Advanced Settings",
                      onClick: () {
                        Navigator.popAndPushNamed(
                          context,
                          StarterAdvancedSettings.id,
                          arguments: {'starter_ip': starter_ip},
                        );
                      },
                    ),
                    RoundedButton(
                      color: Colors.green[800],
                      title: "Save",
                      onClick: () {
                        saveSettings();
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
          height: 30,
          width: 30,
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
          height: 30,
          width: 30,
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

class ColorBox extends StatelessWidget {
  ColorBox({this.color});

  // Function onClick;
  RGBColor color;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      width: 20,
      color: Color.fromRGBO(color.red, color.green, color.blue, 1.0),
    );
  }
}
