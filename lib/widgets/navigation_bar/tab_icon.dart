import 'package:flutter/material.dart';
import 'tab_icon_data.dart';

class TabIcon extends StatefulWidget {
  final TabIconData tabIconData;
  final Function onTap;

  const TabIcon({
    super.key,
    required this.tabIconData,
    required this.onTap,
  });

  @override
  State<StatefulWidget> createState() => _TabIconState();
}

class _TabIconState extends State<TabIcon> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => widget.onTap(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Icon(widget.tabIconData.icon,
                  color: widget.tabIconData.isSelected
                      ? const Color.fromRGBO(1, 152, 253, 0.8)
                      : Colors.black87),
            ),
            const SizedBox(height: 2),
            Expanded(
              flex: 1,
              child: Text(
                widget.tabIconData.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 10,
                    color: widget.tabIconData.isSelected
                        ? const Color.fromRGBO(1, 152, 253, 0.8)
                        : Colors.black87,
                    fontWeight: FontWeight.w100,
                    decoration: TextDecoration.none),
              ),
            )
          ],
        ),
      ),
    );
  }
}
