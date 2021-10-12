import 'package:flutter/material.dart';
import 'package:marbelous_esp32_app/screens/home_screen.dart';
import './../../components/round_button.dart';
import './../../constants.dart';
import './../../components/device_card.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class StarterCard extends StatefulWidget {
  // HomeScreen({Key? key}) : super(key: key);
  // static String id = "home_screen";
  StarterCard({this.title, this.icon, this.type, this.ip});
  final String title;
  final String icon;
  final String type;
  final String ip;

  @override
  _StarterCardState createState() => _StarterCardState();
}

class _StarterCardState extends State<StarterCard> {
  //Starter Data
  int dropMarbles = 1;
  int dropMarbleInterval = 1;

  dropMarble() async {
    print(widget.ip);
    try {
      var url = Uri.parse(
          "http://${widget.ip}/control?command=drop_marble_${dropMarbles}x${dropMarbleInterval}_");
      http.Response res = await http.get(url).timeout(Duration(seconds: 3));
      if (res.statusCode == 200 && res.body == "OK") {
        displaySnackBar("Command Sent Successfully");
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

  Widget starterData() {
    return Column(
      children: [
        RoundedButton(
          title: "Drop Marble",
          color: Colors.blue,
          onClick: () {
            dropMarble();
          },
        ),
        SizedBox(height: 10),
        BoldInfoText(text: "Count"),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
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
        BoldInfoText(text: "Interval"),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
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
      child: DeviceCard(
        title: widget.title,
        icon: widget.icon,
        data: starterData(),
      ),
    );
  }
}
