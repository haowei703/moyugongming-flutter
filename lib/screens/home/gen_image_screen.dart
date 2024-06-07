import 'package:flutter/material.dart';

class GenImageScreen extends StatefulWidget {
  const GenImageScreen({super.key});
  @override
  State<StatefulWidget> createState() => _GenImageScreenState();
}

class _GenImageScreenState extends State<GenImageScreen> {
  String? imageUrl;
  String? prompt;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("文字转手语"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                child: Container(
                  padding: const EdgeInsets.all(30.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(color: Colors.black)),
                  child: Column(
                    children: [
                      TextFormField(
                        onChanged: (value) {
                          prompt = value;
                        },
                        decoration: const InputDecoration(
                            hintText: "请输入您想要查看的手语关键词", helperText: "请描述详细"),
                      ),
                      ElevatedButton(
                          onPressed: () async {
                            if (prompt != null) {

                            }
                          },
                          child: const Text("确定"))
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Center(
                    child: imageUrl == null
                        ? const CircularProgressIndicator()
                        : Image.network(imageUrl!),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
