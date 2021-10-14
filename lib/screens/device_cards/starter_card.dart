import 'package:flutter/material.dart';
import 'package:marbelous_esp32_app/screens/home_screen.dart';
import './../../components/round_button.dart';
import './../../constants.dart';
import './../../components/device_card.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class StarterCard extends StatefulWidget {
  // HomeScreen({Key? key}) : super(key: key);
  // static String id = "home_screen";
  StarterCard(
      {this.title,
      this.icon,
      this.type,
      this.ip,
      this.hasFinisher,
      this.hasSwitch});
  final String title;
  final String icon;
  final String type;
  final String ip;
  final bool hasSwitch;
  final bool hasFinisher;

  @override
  _StarterCardState createState() => _StarterCardState();
}

class _StarterCardState extends State<StarterCard> {
  final _isHours = true;

  final StopWatchTimer _stopWatchTimer = StopWatchTimer(
    mode: StopWatchMode.countUp,
    // onChange: (value) => print('onChange $value'),
    // onChangeRawSecond: (value) => print('onChangeRawSecond $value'),
    // onChangeRawMinute: (value) => print('onChangeRawMinute $value'),
  );

  //Starter Data
  int dropMarbles = 1;
  int dropMarbleInterval = 1;

  bool hasSwitch;
  bool hasFinisher;

  bool dropping;

  @override
  initState() {
    super.initState();
    setState(() {
      hasSwitch = widget.hasSwitch;
      hasFinisher = widget.hasFinisher;
    });
    // _stopWatchTimer.rawTime.listen((value) =>
    //     print('rawTime $value ${StopWatchTimer.getDisplayTime(value)}'));
    // _stopWatchTimer.minuteTime.listen((value) => print('minuteTime $value'));
    // _stopWatchTimer.secondTime.listen((value) => print('secondTime $value'));
    // _stopWatchTimer.records.listen((value) => print('records $value'));
  }

  @override
  void dispose() async {
    super.dispose();
    await _stopWatchTimer.dispose();
  }

  dropMarble() async {
    print(widget.ip);
    try {
      var url = Uri.parse(
          "http://${widget.ip}/control?command=drop_marble_${dropMarbles}x${dropMarbleInterval}_");
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            RoundedButton(
              title: "<<",
              onClick: () async {},
              color: Colors.blue[800],
            ),
            SizedBox(
              width: 5,
            ),
            RoundedButton(
              title: "Toggle",
              onClick: () async {},
              color: Colors.blue[900],
            ),
            SizedBox(
              width: 5,
            ),
            RoundedButton(
              title: ">>",
              onClick: () async {},
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
        hasSwitch
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
        hasFinisher
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
