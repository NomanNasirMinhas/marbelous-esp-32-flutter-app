import 'package:flutter/material.dart';
import './../../components/round_button.dart';
import './../../constants.dart';
import './../../components/device_card.dart';
import 'package:http/http.dart' as http;

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
  int dropMarbles = 0;
  int dropMarbleInterval = 0;

  dropMarble() async {
    print(widget.ip);
    try {
      var url = Uri.parse(
          "http://${widget.ip}/control?command=drop_marble_${dropMarbles}x${dropMarbleInterval}_");
      http.Response res = await http.get(url);
      if (res.statusCode == 200) {
        displaySnackBar("Command Sent Successfully");
      } else {
        displaySnackBar("Command Sending Failed");
      }
    } on Exception catch (e) {
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
      child: DeviceCard(
        title: widget.title,
        icon: widget.icon,
        data: starterData(),
      ),
    );
  }
}
