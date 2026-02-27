import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void showErrorToast(String message) {
Fluttertoast.showToast(
  msg: message,
  toastLength: Toast.LENGTH_LONG,
  gravity: ToastGravity.TOP,
  timeInSecForIosWeb: 5,
  backgroundColor: const Color.fromARGB(255, 227, 108, 108),
  textColor: Colors.white
  );
}