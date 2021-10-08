import 'package:flutter/material.dart';
import 'package:localstore/localstore.dart';
import 'package:marbelous_esp32_app/utilities/device_msg_class.dart';
import 'package:udp/udp.dart';
import 'package:network_info_plus/network_info_plus.dart';

class MessageRecvr {
  final db = Localstore.instance;
  var receiver;
  final info = NetworkInfo();

  startListeningForMessages() async {
    try {
      print("Listening for messages");
      receiver = await UDP.bind(Endpoint.any(port: Port(65000)));
      var wifi = await info.getWifiIP();

      print("UDP Server Started");
      await receiver.listen((datagram) async {
        var str = String.fromCharCodes(datagram.data);
        var tokens = str.split("=");
        if (tokens[0].trim() == "device_msg") {
          var msg = tokens[1].split("_");
          DeviceMessage new_msg =
              new DeviceMessage(type: msg[0], message: msg[1]);
          String id = db.collection('marbelous_devices').doc().id;
          await db
              .collection('marbelous_devices')
              .doc(id)
              .set({'type': new_msg.type, 'message': new_msg.message});
          print("Message Recieved");
        }
      });
    } on Exception catch (e) {
      // TODO
      print(e.toString());
    }
  }
}
