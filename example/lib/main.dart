import 'package:flutter/foundation.dart';
import 'package:js/js.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:webplugindemo/webplugindemo.dart';
import 'package:webplugindemo_example/jshome.dart';
import 'package:webplugindemo_example/js_caller.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _calculResult = "获取js返回结果";
  String _jsCallResult = "js调用flutter方法";
  double divideHeight = 40;
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await Webplugindemo.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Plugin example app'),
          ),
          body: ListView(
            children: [
              SizedBox(
                height: divideHeight,
              ),
              Center(
                child: FlatButton(
                  onPressed: () {
                    // Webplugindemo.showAlert("call js method");
                    getPlatformVersion();
                  },
                  child: Text(_calculResult),
                  minWidth: 200,
                  height: 50,
                  color: Colors.redAccent,
                ),
              ),
              SizedBox(
                height: divideHeight,
              ),
              Center(
                child: FlatButton(
                  onPressed: () {
                    Webplugindemo.showJSAlert("call js method");
                  },
                  child: Text("调用js带参数方法"),
                  minWidth: 200,
                  height: 50,
                  color: Colors.redAccent,
                ),
              ),
              SizedBox(
                height: divideHeight,
              ),
              Center(
                child: FlatButton(
                  onPressed: () {
                    Webplugindemo.showAlert("call html method");
                  },
                  child: Text("调用html方法"),
                  minWidth: 200,
                  height: 50,
                  color: Colors.redAccent,
                ),
              ),
              SizedBox(
                height: divideHeight,
              ),
              Center(
                child: FlatButton(
                  onPressed: () {
                    getMultiplicationResult();
                  },
                  child: Text(_jsCallResult),
                  minWidth: 200,
                  height: 50,
                  color: Colors.redAccent,
                ),
              ),
              SizedBox(
                height: divideHeight,
              ),
              Center(
                child: FlatButton(
                  onPressed: () {
                    showJSAlert("message");
                  },
                  child: Text("调用指定JS"),
                  minWidth: 200,
                  height: 50,
                  color: Colors.redAccent,
                ),
              ),
              SizedBox(
                height: divideHeight,
              ),
              Center(
                child: FlatButton(
                  onPressed: () {
                    testThread();
                    // print(syncFibonacci(60));
                  },
                  child: Text("测试线程"),
                  minWidth: 200,
                  height: 50,
                  color: Colors.redAccent,
                ),
              ),
            ],
          )),
    );
  }

  void testThread() async {
    print(await compute(syncFibonacci, 60));
  }

  int syncFibonacci(int n) {
    return n < 2 ? n : syncFibonacci(n - 2) + syncFibonacci(n - 1);
  }

  void getMultiplicationResult() async {
    String result = await Webplugindemo.jsCallFlutter(5, 12);

    setState(() {
      _jsCallResult = result;
    });
  }

  void getPlatformVersion() async {
    String result = await Webplugindemo.calculateResult;
    setState(() {
      _calculResult = result;
    });
  }

  void showJSAlert(String message) async {
    String result = await showJSDialog(message);
    print(result);
  }
}
