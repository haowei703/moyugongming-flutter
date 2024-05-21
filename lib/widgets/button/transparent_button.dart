import 'package:flutter/material.dart';

class TransparentButton extends StatefulWidget {
  final Widget child;
  final Function onPressed;

  const TransparentButton({super.key, required this.child, required this.onPressed});

  @override
  State<TransparentButton> createState() => _TransparentButtonState();
}

class _TransparentButtonState extends State<TransparentButton> {
  Color _backgroundColor = Colors.transparent;

  void _changeBackgroundColor() {
    setState(() {
      _backgroundColor = const Color.fromRGBO(229, 229, 229, 1); // 在点击时将背景颜色设为灰色
    });

    widget.onPressed(); // 触发按钮点击事件

    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        _backgroundColor = Colors.transparent; // 恢复背景颜色为透明
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _changeBackgroundColor,
      child: Container(
        padding: EdgeInsets.zero,
        color: _backgroundColor, // 使用动态的背景颜色
        child: Center(
          child: widget.child,
        ),
      ),
    );
  }
}
