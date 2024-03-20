import 'package:flutter/material.dart';
import 'package:moyugongming/modules/bottom/tab_icons.dart';
import 'package:moyugongming/page/home.dart';
import 'package:moyugongming/page/profile.dart';
import 'package:moyugongming/widgets/my_app_bar.dart';

import 'bottom_bar.dart';
import 'tabIcon_data.dart';

class BottomPage extends StatefulWidget {
  final List<Widget> tabWidgets;

  const BottomPage({super.key, required this.tabWidgets});

  @override
  State<BottomPage> createState() => _BottomPageState();
}

class _BottomPageState extends State<BottomPage> {
  int _pageIndex = 0;

  late final List<Widget> tabWidgets;

  List<TabIconData> tabIconsList = <TabIconData>[
    TabIconData(
      name: '首页',
      imagePath: 'assets/img/home_tab/tab_1.png',
      selectedImagePath: 'assets/img/home_tab/tab_1s.png',
      index: 0,
      isSelected: true,
      animationController: null,
    ),
    TabIconData(
      name: '消息',
      imagePath: 'assets/img/home_tab/tab_2.png',
      selectedImagePath: 'assets/img/home_tab/tab_2s.png',
      index: 1,
      isSelected: false,
      animationController: null,
    ),
    TabIconData(
      name: '动态',
      imagePath: 'assets/img/home_tab/tab_3.png',
      selectedImagePath: 'assets/img/home_tab/tab_3s.png',
      index: 2,
      isSelected: false,
      animationController: null,
    ),
    TabIconData(
      name: '我的',
      imagePath: 'assets/img/home_tab/tab_4.png',
      selectedImagePath: 'assets/img/home_tab/tab_4s.png',
      index: 3,
      isSelected: false,
      animationController: null,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          content(),
          bottomBar(),
        ],
      ),
    );
  }

  Widget content() {
    return Positioned.fill(
      child: Container(
          alignment: Alignment.center, child: widget.tabWidgets[_pageIndex]),
    );
  }

  Widget bottomBar() {
    return Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        child: MyBottomAppBar(
          tabIconsList: tabIconsList,
          changeIndex: (index) => onClickBottomBar(index),
        ));
  }

  void onClickBottomBar(int index) {
    if (!mounted) return;

    setState(() => _pageIndex = index);
  }
}
