import 'package:flutter/material.dart';

class LoadingDialog {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  static void hidden(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}
