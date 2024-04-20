import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TabIconData {
  final IconData icon;
  final IconData selectedIcon;
  bool isSelected;
  final int index;
  final String label;

  AnimationController? animationController;

  AnimationController? iconAnimationController;

  TabIconData({
    required this.label,
    required this.icon,
    required this.index,
    required this.selectedIcon,
    this.isSelected = false,
    this.animationController,
    this.iconAnimationController,
  });
}
