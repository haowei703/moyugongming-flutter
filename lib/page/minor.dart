import 'package:flutter/material.dart';

class MinorPage extends StatefulWidget {
  const MinorPage({super.key});

  @override
  State<StatefulWidget> createState() => _MinorPageState();
}

class _MinorPageState extends State<MinorPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("次页"),
      ),
    );
  }
}
