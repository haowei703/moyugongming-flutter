import 'package:flutter/material.dart';

class FloatingWidget extends StatelessWidget {
  const FloatingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        //悬浮窗被点击
      },
      child: Container(
        color: Colors.cyanAccent,
        width: 50,
        height: 50,
        child: const Center(
          child: Text("Floating"),
        ),
      ),
    );
  }
}