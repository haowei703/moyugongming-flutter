import 'package:flutter/material.dart';
import 'package:moyugongming/page/home.dart';
import 'package:moyugongming/screens/evaluation.dart';

class MinorPage extends StatefulWidget {
  const MinorPage({super.key});

  @override
  State<StatefulWidget> createState() => _MinorPageState();
}

class _MinorPageState extends State<MinorPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(200),
        child: AppBar(),
      ),
      body: Center(
        child: GridView(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              mainAxisExtent: 80.0),
          children: [
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AudioEvalPage()));
                },
                child: Container()),
            Text("123")
          ],
        ),
      ),
    );
  }
}
