import 'package:flutter/material.dart';
import 'package:marbelous_esp32_app/components/round_button.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:udp/udp.dart';
import '../../constants.dart';
import 'package:localstore/localstore.dart';
import 'dart:io';
import 'package:localstorage/localstorage.dart';

class GlobalSettings extends StatefulWidget {
  // GlobalSettings({Key? key}) : super(key: key);
  static String id = "global_settings";

  @override
  _GlobalSettingsState createState() => _GlobalSettingsState();
}

class _GlobalSettingsState extends State<GlobalSettings> {
  TextEditingController cmdTextController;
  String wifi_ssd;
  String wifi_password;
  String hue_bridge_ip;
  final db = Localstore.instance;
  displaySnackBar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> storeSettings() async {
    try {
      final db = Localstore.instance;

      await db.collection('global_settings').doc('global_settings').set({
        'wifi_ssd': wifi_ssd,
        'wifi_password': wifi_password,
        'hue_bridge_ip': hue_bridge_ip,
      });
    } on Exception catch (e) {
      print(e.toString());
      cancel();
    }
  }

  saveSettings() async {
    await storeSettings();
    await db.collection('global_settings').doc("global_settings").set({
      'wifi_ssd': wifi_ssd,
      'wifi_password': wifi_password,
      'hue_bridge_ip': hue_bridge_ip,
    });
    displaySnackBar("Settings Updated");
    Navigator.pop(context);
  }

  cancel() {
    displaySnackBar("Settings Not Saved.");
    Navigator.pop(context);
  }

  getCurrentGlobalSettings() async {
    var settings =
        await db.collection('global_settings').doc("global_settings").get();
    if (settings != null) {
      setState(() {
        wifi_ssd = settings['wifi_ssd'];
        wifi_password = settings['wifi_password'];
        hue_bridge_ip = settings['hue_bridge_ip'];
      });
    } else {
      displaySnackBar("No Global Settings Found");
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentGlobalSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Global Settings',
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
                Text(
                  "Here you can find the global settings from the App. Change them if needed and press 'Save'. Press 'Back' to go to main-menu.",
                  softWrap: true,
                  style: infoText,
                ),
                SizedBox(
                  height: 30,
                ),
                SizedDivider(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Wifi SSID: ${wifi_ssd == null ? 'Not Set' : '$wifi_ssd'}",
                      style: boldInfoText,
                    ),
                    TextField(
                      controller: cmdTextController,

                      // keyboardType: TextInputType.number,
                      textAlign: TextAlign.left,
                      style: boldInfoText,
                      onChanged: (value) {
                        setState(() {
                          wifi_ssd = value;
                        });
                      },
                      decoration: kTextFieldDecoration.copyWith(
                          hintText: "Enter New SSID"),
                    )
                  ],
                ),
                SizedDivider(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Wifi Password: ${wifi_password == null ? 'Not Set' : 'Set'}",
                      style: boldInfoText,
                    ),
                    TextField(
                      controller: cmdTextController,
                      // keyboardType: TextInputType.number,
                      obscureText: true,
                      textAlign: TextAlign.left,
                      style: boldInfoText,
                      onChanged: (value) {
                        setState(() {
                          wifi_password = value;
                        });
                      },
                      decoration: kTextFieldDecoration.copyWith(
                          hintText: "Enter New Password"),
                    )
                  ],
                ),
                SizedDivider(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hue Bridge IP: ${hue_bridge_ip == null ? 'Not Set' : '$hue_bridge_ip'}",
                      style: boldInfoText,
                    ),
                    TextField(
                      controller: cmdTextController,
                      // keyboardType: TextInputType.number,
                      textAlign: TextAlign.left,
                      style: boldInfoText,
                      onChanged: (value) {
                        setState(() {
                          hue_bridge_ip = value;
                        });
                      },
                      decoration: kTextFieldDecoration.copyWith(
                          hintText: "Enter new Hue Bridge IP"),
                    )
                  ],
                ),
                SizedDivider(),
                SizedBox(
                  height: 30,
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey[400],
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "All components need to know the SSID and password from your local WIFI network. If there is already a component that is connected to Wifi, then you can 'broadcast' the credentials to other components without needing to enter them manually.",
                          softWrap: true,
                          style: infoText,
                          textAlign: TextAlign.justify,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                "All components need to know the SSID and password from your local WIFI network. If there is already a component that is connected to Wifi, then you can 'broadcast' the credentials to other components without needing to enter them manually.",
                                softWrap: true,
                                style: infoText,
                                textAlign: TextAlign.justify,
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              flex: 1,
                              child: RoundedButton(
                                color: Colors.blue[800],
                                title: "Broadcast",
                                onClick: () {},
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: RoundedButton(
                          color: Colors.orange[700],
                          title: "Back",
                          onClick: () {
                            cancel();
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: RoundedButton(
                          color: Colors.green[800],
                          title: "Save",
                          onClick: () {
                            saveSettings();
                          },
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 30,
                )
              ],
            ),
          ),
        ));
  }
}

class SizedDivider extends StatelessWidget {
  const SizedDivider({
    Key key,
  }) : super(key: key);

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
