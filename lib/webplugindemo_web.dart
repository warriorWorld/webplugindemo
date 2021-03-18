import 'dart:async';
import 'dart:collection';

// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html show window;
import 'dart:js' as js;
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

/// A web implementation of the Webplugindemo plugin.
class WebplugindemoWeb {
  static void registerWith(Registrar registrar) {
    final MethodChannel channel = MethodChannel(
      'webplugindemo',
      const StandardMethodCodec(),
      registrar,
    );
    final pluginInstance = WebplugindemoWeb();
    channel.setMethodCallHandler(pluginInstance.handleMethodCall);
  }

  void init() {
    js.context["multiplication"] = multiplication;
  }

  /// Handles method calls over the MethodChannel of this plugin.
  /// Note: Check the "federated" architecture for a new way of doing this:
  /// https://flutter.dev/go/federated-plugins
  Future<dynamic> handleMethodCall(MethodCall call) async {
    init();
    print("handleMethodCall method:${call.method}");
    switch (call.method) {
      case 'getPlatformVersion':
        return getPlatformVersion();
        break;
      case 'getCalculateResult':
        return getCalculateResult();
        break;
      case 'showAlert':
        print("showAlert");
        //必须与传值类型对应
        LinkedHashMap map = call.arguments;
        showAlert(map["message"]);
        break;
      case 'showJSAlert':
        print("showJSAlert");
        //必须与传值类型对应
        LinkedHashMap map = call.arguments;
        showJSAlert(map["message"]);
        break;
      case 'jsCallFlutter':
        print("jsCallFlutter");
        //必须与传值类型对应
        LinkedHashMap map = call.arguments;
        return jsCallFlutter(map["a"], map["b"]);
        break;
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details:
              'webplugindemo for web doesn\'t implement \'${call.method}\'',
        );
    }
  }

  /// Returns a [String] containing the version of the platform.
  Future<String> getPlatformVersion() {
    final version = html.window.navigator.userAgent;
    return Future.value(version);
  }

  Future<String> getCalculateResult() {
    var result = js.context["Math"].callMethod("pow", [3, 4]);
    return Future.value(result.toString());
  }

  //这里调用的是自己的js,位于location.js.需要在index.html中声明
  void showJSAlert(String message) {
    js.context.callMethod("alert", [message]);
  }

  void showAlert(String message) {
    html.window.alert(message);
  }

  Future<String> jsCallFlutter(int a, int b) {
    print("js call flutter $a*$b");
    int result = js.context.callMethod("multiplication", [a, b]);
    return Future.value(result.toString());
  }

  int multiplication(int a, int b) {
    print("$a*$b=");
    return a * b;
  }
}
