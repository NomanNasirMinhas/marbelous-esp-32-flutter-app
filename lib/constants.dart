import 'package:flutter/material.dart';

const backgroundColor = Color(0xFF0374A0);
const headingText = TextStyle(fontSize: 40, fontFamily: 'Bebas');
const buttonStyle = TextStyle(
  color: Colors.white,
  fontFamily: 'Roboto',
  fontWeight: FontWeight.bold,
  decoration: TextDecoration.underline,
  fontStyle: FontStyle.italic,
);
BoxDecoration deviceCard = BoxDecoration(
  gradient: LinearGradient(
    colors: [
      const Color(0xFFF9FDFC),
      const Color(0xFFDDFCF6),
    ],
    transform: GradientRotation(60),
    begin: const FractionalOffset(0.0, 0.0),
    end: const FractionalOffset(1.0, 0.0),
    stops: [0.0, 1.0],
    tileMode: TileMode.clamp,
  ),
  color: Color(0xFF001BAA),
  border: Border.all(
    color: Colors.black,
    width: 2,
  ),
  borderRadius: BorderRadius.circular(12),
);

const kTextFieldDecoration = InputDecoration(
  hintText: 'http://IP:Port/command_parameter',
  // hintStyle: TextStyle(color: Colors.g),
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.grey, width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(10.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.black, width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(10.0)),
  ),
);

const recordTextStyle = TextStyle(
  color: Colors.white,
  fontSize: 18,
  fontFamily: "Roboto",
  fontWeight: FontWeight.bold,
);

const headerTextStyle = TextStyle(
  color: Colors.white,
  fontSize: 16,
  fontFamily: "Roboto",
  fontWeight: FontWeight.bold,
  fontStyle: FontStyle.italic,
);

const statsHeaderStyle = TextStyle(
  color: Colors.white,
  fontSize: 20,
  fontFamily: "Roboto",
  fontWeight: FontWeight.bold,
  // fontStyle: FontStyle.italic,
);

const recordCardTextType = TextStyle(
  fontSize: 16,
  fontFamily: "Roboto",
  color: Colors.white,
);
