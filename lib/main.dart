import 'package:flutter/material.dart';
import 'package:moyugongming/page/home.dart';
import 'package:moyugongming/page/minor.dart';
import 'package:moyugongming/screens/login.dart';
import 'package:moyugongming/page/profile.dart';
import 'package:moyugongming/page/community.dart';
import 'package:moyugongming/widgets/my_app_bar.dart';


import 'modules/bottom/bottom_page.dart';

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
        primaryColor: Color.fromRGBO(240, 244, 255, 1),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      home: BottomNavigationBar(title: "默语共鸣"),
    );
  }
}

class BottomNavigationBar extends StatefulWidget {
  const BottomNavigationBar({super.key, required this.title});

  final String title;

  @override
  State<BottomNavigationBar> createState() => _BottomNavigationBarState();
}

class _BottomNavigationBarState extends State<BottomNavigationBar> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: BottomPage(
        tabWidgets: [
          HomePage(title: "主页"),
          MinorPage(),
          CommunityPage(),
          ProfilePage(),
        ],
      ),
    );
  }
}
