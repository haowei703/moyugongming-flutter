import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:moyugongming/widgets/transparent_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/log_util.dart';

class PersonInfoScreen extends StatefulWidget {
  const PersonInfoScreen({super.key});

  @override
  State<PersonInfoScreen> createState() => _PersonInfoScreenState();
}

class _PersonInfoScreenState extends State<PersonInfoScreen> {
  String? _userName;
  String? _phoneNumber;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
        future: _readUserInfo(),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(); // 显示加载指示器
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}'); // 显示错误信息
          } else {
            return Scaffold(
              appBar: AppBar(
                flexibleSpace: Stack(
                  children: <Widget>[
                    const Positioned.fill(
                      child: Image(
                        image: AssetImage("assets/background/background.png"),
                        fit: BoxFit.cover,
                      ),
                    ),
                    ClipRRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                        child: Container(
                          color: Colors.black12.withOpacity(0.2),
                        ),
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.transparent,
                // elevation: 1,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back,
                      size: 20, color: Colors.black87),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                title: const Text(
                  "个人信息",
                  style: TextStyle(fontSize: 16),
                ),
              ),
              body: Center(
                child: Container(
                  color: const Color.fromRGBO(239, 239, 239, 1),
                  height: double.infinity,
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.white60),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TransparentButton(
                                  onPressed: () {},
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    child: Row(
                                      children: [
                                        Text("用户名"),
                                        Expanded(
                                            child: Align(
                                          alignment: Alignment.centerRight,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Text(_userName != null
                                                  ? _userName!
                                                  : ""),
                                              SizedBox(width: 10),
                                              Icon(
                                                  Icons
                                                      .arrow_forward_ios_outlined,
                                                  size: 15)
                                            ],
                                          ),
                                        ))
                                      ],
                                    ),
                                  )),
                              TransparentButton(
                                  onPressed: () {},
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    child: Row(
                                      children: [
                                        Text("手机号"),
                                        Expanded(
                                            child: Align(
                                          alignment: Alignment.centerRight,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(_phoneNumber != null
                                                  ? _phoneNumber!
                                                  : ""),
                                              SizedBox(width: 10),
                                              Icon(
                                                  Icons
                                                      .arrow_forward_ios_outlined,
                                                  size: 15)
                                            ],
                                          ),
                                        ))
                                      ],
                                    ),
                                  )),
                            ],
                          )),
                      const SizedBox(height: 10),
                      SizedBox(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0))),
                          child: const Text("退出登录"),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          }
        });
  }

  // sharded_preferences读取用户信息和设置信息
  Future<void> _readUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userName = prefs.getString("userName");
    String? phoneNumber = prefs.getString("phoneNumber");

    if (userName != null && phoneNumber != null) {
      _userName = userName;
      _phoneNumber = phoneNumber;
      LogUtil.init(title: "读取用户信息", isDebug: true, limitLength: 200);
      LogUtil.d("userName:$userName,phoneNumber$phoneNumber");
    }
  }
}
