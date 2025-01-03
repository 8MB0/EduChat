import 'package:flutter/material.dart';

const textInputDecoration = InputDecoration(
    labelStyle:
        TextStyle(color: Color(0xFF2664C6), fontWeight: FontWeight.w300),
    focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF2664C6), width: 3)),
    enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF2664C6), width: 3)),
    errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF2664C6), width: 3)));

void nextScreen(context, page) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => page));
}

void nextScreenReplace(context, page) {
  Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (context) => page));
}

void showSnackbar(context, color, message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: const TextStyle(fontSize: 14),
      ),
      backgroundColor: color,
      duration: const Duration(seconds: 2),
      action: SnackBarAction(
        label: "OK",
        onPressed: () {},
        textColor: Colors.white,
      ),
    ),
  );
}
