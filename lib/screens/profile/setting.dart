import 'package:flutter/material.dart';
import '../../widgets/button/transparent_button.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("设置"),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: Container(
        height: double.infinity,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Color.fromRGBO(249, 249, 249, 1)
        ),
        child: SingleChildScrollView(
          physics: ScrollPhysics(

          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
                padding: EdgeInsets.zero,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10), color: Colors.white),
                child: Column(children: [
                  TransparentButton(
                    onPressed: () {},
                    child: Container(
                        height: 40,
                        padding: EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.settings_outlined,
                                size: 20, color: Colors.black87),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              "设置",
                              style: TextStyle(fontSize: 13, color: Colors.black87),
                            ),
                            Expanded(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Icon(
                                    Icons.arrow_forward_ios_outlined,
                                    size: 16,
                                    color: Colors.black87,
                                  ),
                                ))
                          ],
                        )),
                  ),
                ])),
          ),
        ),
      ),
    );
  }
}
