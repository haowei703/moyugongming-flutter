import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moyugongming/utils/http_client_utils.dart';

class GenImageScreen extends StatefulWidget {
  const GenImageScreen({super.key});
  @override
  State<StatefulWidget> createState() => _GenImageScreenState();
}

class _GenImageScreenState extends State<GenImageScreen> {
  String? imageUrl;
  String? prompt;


  // Tex

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("文字转手语"),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                child: Container(
                  padding: EdgeInsets.all(30.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(color: Colors.black)),
                  child: Column(
                    children: [
                      TextFormField(
                        onChanged: (value) {
                          prompt = value;
                        },
                        decoration: InputDecoration(
                            hintText: "请输入您想要查看的手语关键词", helperText: "请描述详细"),
                      ),
                      ElevatedButton(onPressed: () async {
                        if(prompt != null){
                          await sendRequest(prompt: prompt!);
                        }
                      }, child: Text("确定"))
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(30.0),
                  child: Center(
                    child: imageUrl == null
                        ? CircularProgressIndicator()
                        : Container(
                            child: Image.network(imageUrl!),
                          ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> sendRequest({required String prompt}) async {
    String path = "getImage";
    Map<String, String> headers = {'Content-Type': 'application/json'};
    HttpClientUtils.sendRequestAsync(path,
        method: HttpMethod.POST, headers: headers, onSuccess: (response) {
      String url = response['data'];
      setState(() {
        imageUrl = url;
      });
    }, onError: (error) {});
  }
}
