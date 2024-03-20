import 'package:flutter/cupertino.dart';

class SSLSlideTransition extends AnimatedWidget{
  final bool transformHitTests;
  final Widget child;
  final AxisDirection direction;
  late final Tween<Offset> tween;
  SSLSlideTransition({
    Key? key,
    required Animation<double> position,
    this.transformHitTests = true,
    this.direction = AxisDirection.down,//将参数变为枚举类型
    required this.child,
  }):super(key: key, listenable: position){
    //构造函数中根据变量修改参数，此时不能使用const修饰构造函数否则会报错
    switch (direction){
      case AxisDirection.up:
        tween = Tween(begin: const Offset(0, 1), end: const Offset(0, 0));
        break;
      case AxisDirection.right:
        tween = Tween(begin: const Offset(-1, 0), end: const Offset(0, 0));
        break;
      case AxisDirection.down:
        tween = Tween(begin: const Offset(0, -1), end: const Offset(0, 0));
        break;
      case AxisDirection.left:
        tween = Tween(begin: const Offset(1, 0), end: const Offset(0, 0));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    final position = listenable as Animation<double>;
    Offset offset = tween.evaluate(position);
    if (position.status == AnimationStatus.reverse){
      switch (direction){
        case AxisDirection.up:
          offset = Offset(offset.dx, -offset.dy);
          break;
        case AxisDirection.right:
          offset = Offset(-offset.dx, offset.dy);
          break;
        case AxisDirection.down:
          offset = Offset(offset.dx, -offset.dy);
          break;
        case AxisDirection.left:
          offset = Offset(-offset.dx, offset.dy);
          break;
      }
    }
    return FractionalTranslation(
      translation: offset,
      transformHitTests: transformHitTests,
      child: child,
    );
  }
}