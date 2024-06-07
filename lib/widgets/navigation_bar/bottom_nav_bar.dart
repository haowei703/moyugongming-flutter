import 'package:flutter/material.dart';
import 'tab_icon_data.dart';
import 'tab_icon.dart';

class BottomNavBar extends StatefulWidget {
  final Function(int index) changeIndex;

  final List<TabIconData> tabIconDataList;

  const BottomNavBar(
      {super.key, required this.changeIndex, required this.tabIconDataList});

  @override
  State<StatefulWidget> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    return SizedBox(
      width: width,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: widget.tabIconDataList.map((tabIconData) {
          if (tabIconData.index != _currentIndex) {
            setState(() {
              tabIconData.isSelected = false;
            });
          } else {
            tabIconData.isSelected = true;
          }
          return Expanded(
              child: TabIcon(
            tabIconData: tabIconData,
            onTap: () {
              widget.changeIndex(tabIconData.index);
              if (_currentIndex == tabIconData.index) return;
              setState(() {
                _currentIndex = tabIconData.index;
              });
            },
          ));
        }).toList(),
      ),
    );
  }
}
