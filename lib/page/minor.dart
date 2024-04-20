import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moyugongming/model/enums/evalmode.dart';
import 'package:moyugongming/screens/evaluation.dart';
import 'package:moyugongming/widgets/transparent_button.dart';

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
        child: AppBar(
          backgroundColor: Theme.of(context).highlightColor,
          actions: [
            TextButton(onPressed: () {}, child: const Text("使用帮助")),
          ],
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: GridView(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
                mainAxisExtent: 80.0),
            children: [
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5)))),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const AudioEvalPage(evalMode: EvalMode.word)));
                  },
                  child: const Text("单词训练")),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5)))),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AudioEvalPage(
                                evalMode: EvalMode.sentence)));
                  },
                  child: const Text("句子训练")),
            ],
          ),
        ),
      ),
    );
  }
}
