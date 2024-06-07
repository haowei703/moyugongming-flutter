import 'dart:ui';

import 'package:flutter/material.dart';
import 'tab_icon_data.dart';
import 'bottom_nav_bar.dart';

class BottomBarFrame extends StatefulWidget {
  final List<TabIconData> tabIconList;
  final List<Widget> pages;
  final double height;

  /// 底部导航栏颜色
  final Color color;

  /// 是否显示导航项标签
  final bool showNavItemText;

  /// 是否开启亚克力效果
  final bool isAcrylicEnabled;

  const BottomBarFrame({
    super.key,
    required this.tabIconList,
    required this.pages,
    this.height = 80,
    this.isAcrylicEnabled = true,
    this.color = Colors.white,
    this.showNavItemText = true,
  });

  @override
  State<StatefulWidget> createState() => _BottomBarFrameState();
}

class _BottomBarFrameState extends State<BottomBarFrame> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = widget.pages;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(fit: StackFit.expand, children: [content(), bottom()]);
  }

  Widget content() {
    return Positioned.fill(
        child: Container(
            alignment: Alignment.center, child: _pages[_currentIndex]));
  }

  Widget bottom() {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    return Positioned(
        bottom: 0,
        width: width,
        height: widget.height,
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            Positioned.fill(
                child: ClipRRect(
                    child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                        child: Container(
                          decoration: BoxDecoration(
                              color: const Color.fromRGBO(180, 180, 180, 0.05),
                              border: Border(
                                  top: BorderSide(
                                      width: 1, color: Colors.grey.shade300))),
                        )))),
            bottomNavBar()
          ],
        ));
  }

  Widget bottomNavBar() {
    return Padding(
        padding: const EdgeInsets.fromLTRB(5, 10, 5, 5),
        child: BottomNavBar(
          changeIndex: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          tabIconDataList: widget.tabIconList,
        ));
  }
}
