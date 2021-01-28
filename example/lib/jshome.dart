import 'package:flutter/material.dart';
import 'dart:js' as js;

/**
 * 参考
 * https://www.it610.com/article/1280448506485555200.htm
 * 官方给开发者提供了js与dart交互的api：
 * https://api.flutter.dev/flutter/dart-js/dart-js-library.html
 */
class JSHomePage extends StatefulWidget {
  JSHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<JSHomePage> {
  /**
   * 调用js
   */
  void _callJS() {
    js.context.callMethod("alert");
  }

  /**
   * 调用js
   */
  void _jsCallFlutter() {
//    等于js调用：flutter.flutterMoth();
    js.context.callMethod("flutterMethod", [""]);
  }

  /**
   * 调用js并且传递参数
   */
  void _callJSAndParameter() {
    //等于js调用： alert("我是来自dart的方法");
    js.context.callMethod("alert", ["我是来自dart的方法"]);
  }

  /**
   * 调用js传参数返回数据
   */
  void _callJSAndParameterAndReturn() {
    //等于js调用：var a = Math.pow(3,4);
    var callMethod = js.context["Math"].callMethod("pow", [3, 4]);
    js.context.callMethod("alert", [callMethod.toString()]);
    print("普通调用" + callMethod.toString());
  }

/*这里需要webView注册
   *JavascriptInterface 名为Obtain，并提供getA方法
   * 详细使用请百度android与js交互
   */
  void getNativeProperty() {
    //等于js调用：Obtain。getA()
    var text = js.context["obtain"].callMethod("getProperty", ["账号信息"]);
    js.context.callMethod("alert", [text.toString()]);
  }

  /**
   * 调用日志，这里其实不必用这个了，因为fltter print，就等价于这个
   */
  void jsConsoleLog() {
    //等于调用js：  console.log("我是dart 打印的js日志")
    js.context['console'].callMethod("log", ["我是dart 打印的js日志"]);
  }

  /**
   * flutter方法用于让js调用
   */
  void flutterMethod() {
    js.context.callMethod("alert", ["我来自flutter"]);
    print("高级调用js调用flutter");
  }

  @override
  Widget build(BuildContext context) {
    js.context["flutterMethod"] = flutterMethod;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              child: Text(
                '呼叫js',
              ),
              onPressed: _callJS,
            ),
            RaisedButton(
                child: Text(
                  '呼叫js并传参数',
                ),
                onPressed: _callJSAndParameter),
            RaisedButton(
                child: Text(
                  '呼叫js传参数并返回数据',
                ),
                onPressed: _callJSAndParameterAndReturn),
            RaisedButton(
                child: Text(
                  'js打印日志',
                ),
                onPressed: jsConsoleLog),
            RaisedButton(
                child: Text(
                  'js 呼叫Flutter',
                ),
                onPressed: _jsCallFlutter),
            RaisedButton(
                child: Text(
                  '获取原生数据（需要客户端支持）',
                ),
                onPressed: getNativeProperty)
          ],
        ),
      ),
    );
  }
}
