import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:marbelous_esp32_app/screens/home_screen.dart';
import 'package:marbelous_esp32_app/utilities/device_class.dart';
import './../../components/round_button.dart';
import './../../constants.dart';
import './../../components/device_card.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:http/http.dart' as http;
import 'package:udp/udp.dart';
import 'package:localstore/localstore.dart';

class StarterCard extends StatefulWidget {
  // HomeScreen({Key? key}) : super(key: key);
  // static String id = "home_screen";
  StarterCard({this.title, this.icon, this.type});
  final String title;
  final String icon;
  final String type;

  @override
  _StarterCardState createState() => _StarterCardState();
}

class _StarterCardState extends State<StarterCard> {
  final _isHours = true;
  var receiver;
  String switch_ip;
  String starter_ip;

  final StopWatchTimer _stopWatchTimer = StopWatchTimer(
    mode: StopWatchMode.countUp,
    // onChange: (value) => print('onChange $value'),
    // onChangeRawSecond: (value) => print('onChangeRawSecond $value'),
    // onChangeRawMinute: (value) => print('onChangeRawMinute $value'),
  );

  //Starter Data
  int dropMarbles = 1;
  int dropMarbleInterval = 1;

  bool hasSwitch = false;
  bool hasFinisher = false;

  bool dropping;

  scanNetwork() async {
    final db = Localstore.instance;
    print("Scanning Network");

    final items = await db.collection('marbelous_devices').get();
    if (items == null) {
      print("No Devices Found");
    } else {
      print("${items.length} Devices Found");
      items.forEach((key, value) {
        if (value['type'] == "starter") {
          setState(() {
            starter_ip = value['ip'];
          });
        }

        if (value['type'] == "finisher") {
          setState(() {
            hasFinisher = true;
          });
        }

        if (value['type'] == "switch") {
          setState(() {
            hasSwitch = true;
            switch_ip = value['ip'];
          });
        }
      });
    }

    print('Done');
  }

  @override
  initState() {
    super.initState();
    scanNetwork();
    startUDPServer();
    // _stopWatchTimer.rawTime.listen((value) =>
    //     print('rawTime $value ${StopWatchTimer.getDisplayTime(value)}'));
    // _stopWatchTimer.minuteTime.listen((value) => print('minuteTime $value'));
    // _stopWatchTimer.secondTime.listen((value) => print('secondTime $value'));
    // _stopWatchTimer.records.listen((value) => print('records $value'));
  }

  startUDPServer() async {
    try {
      // print("Starting search for $deviceToAdd");
      receiver = await UDP.bind(Endpoint.any(port: Port(65000)));

      await receiver.listen((datagram) {
        var str = String.fromCharCodes(datagram.data);
        var tokens = str.split("=");
        if (tokens[0].trim() == "device_msg") {
          var command = tokens[1].split(":");
          if (command[0] == "finisher_finish") {
            _stopWatchTimer.onExecute.add(StopWatchExecute.stop);
            setState(() {
              dropping = false;
            });
            displaySnackBar("Finisher Sent finished command");
          }
        }
      });
    } on Exception catch (e) {
      // TODO
      print(e.toString());
    }
  }

  @override
  void dispose() async {
    super.dispose();
    await _stopWatchTimer.dispose();
    // receiver.close();
  }

  dropMarble() async {
    try {
      var url = Uri.parse(
          "http://${starter_ip}/control?command=drop_marble_${dropMarbles}x${dropMarbleInterval}_");
      http.Response res = await http.get(url).timeout(Duration(seconds: 3));
      if (res.statusCode == 200 && res.body == "OK") {
        displaySnackBar("Command Sent Successfully");
        setState(() {
          dropping = true;
        });
        _stopWatchTimer.onExecute.add(StopWatchExecute.reset);
        _stopWatchTimer.onExecute.add(StopWatchExecute.start);
      } else {
        displaySnackBar("Command Sending Failed");
      }
    } on TimeoutException catch (e) {
      displaySnackBar("Command Timeout");
    } on Error catch (e) {
      print(e);
      displaySnackBar("Command Sending Error");
    }
  }

  displaySnackBar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Widget switchData() {
    return Column(
      children: [
        BoldInfoText(text: "Lane Switch"),
        SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            RoundedButton(
              title: "<<",
              onClick: () async {
                try {
                  var url = Uri.parse(
                      "http://$switch_ip/control?command=laneswitch_left");
                  http.Response res =
                      await http.get(url).timeout(Duration(seconds: 3));
                } on Exception catch (e) {
                  displaySnackBar("Finisher Command Exception");
                }
              },
              color: Colors.blue[800],
            ),
            SizedBox(
              width: 5,
            ),
            RoundedButton(
              title: "Toggle",
              onClick: () async {
                try {
                  var url = Uri.parse(
                      "http://$switch_ip/control?command=laneswitch_toggle");
                  http.Response res =
                      await http.get(url).timeout(Duration(seconds: 3));
                } on Exception catch (e) {
                  displaySnackBar("Finisher Command Exception");
                }
              },
              color: Colors.blue[900],
            ),
            SizedBox(
              width: 5,
            ),
            RoundedButton(
              title: ">>",
              onClick: () async {
                try {
                  var url = Uri.parse(
                      "http://$switch_ip/control?command=laneswitch_right");
                  http.Response res =
                      await http.get(url).timeout(Duration(seconds: 3));
                } on Exception catch (e) {
                  displaySnackBar("Finisher Command Exception");
                }
              },
              color: Colors.blue[800],
            ),
          ],
        ),
      ],
    );
  }

  Widget finisherData() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: StreamBuilder<int>(
        stream: _stopWatchTimer.rawTime,
        initialData: _stopWatchTimer.rawTime.value,
        builder: (context, snap) {
          final value = snap.data;
          final displayTime =
              StopWatchTimer.getDisplayTime(value, hours: _isHours);
          return Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  displayTime,
                  style: const TextStyle(
                      fontSize: 40,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget starterData() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          // mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(
              width: 75,
              child: BoldInfoText(text: "Count"),
            ),
            RoundedButton(
              title: " - ",
              color: Colors.blue[300],
              onClick: () {
                if (dropMarbles > 1) {
                  setState(() {
                    dropMarbles--;
                  });
                }
              },
            ),
            SizedBox(
              width: 10,
            ),
            Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2)),
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Text(this.dropMarbles.toString()),
              ),
            ),
            SizedBox(
              width: 10,
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
          // mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(
              width: 75,
              child: BoldInfoText(text: "Interval"),
            ),
            RoundedButton(
              title: " - ",
              color: Colors.blue[300],
              onClick: () {
                if (dropMarbleInterval > 1) {
                  setState(() {
                    dropMarbleInterval--;
                  });
                }
              },
            ),
            SizedBox(
              width: 10,
            ),
            Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2)),
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Text(this.dropMarbleInterval.toString()),
              ),
            ),
            SizedBox(
              width: 10,
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
        SizedBox(height: 10),
        dropping == true
            ? RoundedButton(
                title: "Stop",
                color: Colors.red,
                onClick: () async {
                  _stopWatchTimer.onExecute.add(StopWatchExecute.stop);
                  setState(() {
                    dropping = false;
                  });
                },
              )
            : RoundedButton(
                title: "Drop Marble",
                color: Colors.blue,
                onClick: () {
                  dropMarble();
                },
              ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DeviceCard(
          title: widget.title,
          icon: widget.icon,
          data: starterData(),
        ),
        SizedBox(
          height: 20,
        ),
        hasSwitch == true
            ? Column(
                children: [
                  DeviceCard(
                    title: "LaneSwitch",
                    icon: 'assets/img/switch.png',
                    data: switchData(),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              )
            : Container(),
        hasFinisher == true
            ? DeviceCard(
                title: "Finisher",
                icon: 'assets/img/finisher.png',
                data: finisherData(),
              )
            : Container(),
        SizedBox(height: 10),
      ],
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
      // textAlign: TextAlign.justify,
    );
  }
}
