import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moyugongming/screens/home/home_screen.dart';
import 'package:moyugongming/screens/minor/minor_screen.dart';
import 'package:moyugongming/screens/profile/profile.dart';
import 'package:moyugongming/screens/community/community_screen.dart';
import 'package:moyugongming/widgets/navigation_bar/navigation_bar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '默语共鸣',
      theme: ThemeData(
        primarySwatch: Colors.cyan,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        iconTheme: const IconThemeData(
          color: Colors.blueAccent
        )
      ),
      home: const HomeFrame(),
    );
  }
}

class HomeFrame extends StatefulWidget {
  const HomeFrame({super.key});

  @override
  State<HomeFrame> createState() => _HomeFrameState();
}

class _HomeFrameState extends State<HomeFrame> {
  // 底部导航栏图标
  late List<TabIconData> _tabIconDataList;

  @override
  void initState() {
    super.initState();
    _tabIconDataList = <TabIconData>[
      TabIconData(
          label: "首页",
          icon: CupertinoIcons.home,
          selectedIcon: CupertinoIcons.house_fill,
          index: 0),
      TabIconData(
          label: "语训",
          icon: CupertinoIcons.mic,
          selectedIcon: CupertinoIcons.mic_solid,
          index: 1),
      TabIconData(
          label: "社区",
          icon: Icons.shop_outlined,
          selectedIcon: Icons.shop,
          index: 2),
      TabIconData(
          label: "个人主页",
          icon: CupertinoIcons.profile_circled,
          selectedIcon: CupertinoIcons.profile_circled,
          index: 3),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BottomBarFrame(tabIconList: _tabIconDataList, pages: const <Widget>[
        HomePage(title: "主页"),
        MinorPage(),
        CommunityPage(),
        ProfilePage()
      ]),
    );
  }
}
