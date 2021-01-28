import 'dart:async';

import 'package:flutter/services.dart';

class Webplugindemo {
  static const MethodChannel _channel = const MethodChannel('webplugindemo');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<String> get calculateResult async {
    final String version = await _channel.invokeMethod('getCalculateResult');
    return version;
  }

  static void showJSAlert(String message) {
    try {
      //result.success(any)
      _channel.invokeMethod('showJSAlert', {'message': message});
    } on PlatformException catch (e) {
      // result.error("failed", "failed unknow", "i don't know")
      print("PlatformException$e");
    } on MissingPluginException catch (e) {
      //result.notImplemented()
      print("MissingPluginException:$e");
    }
  }

  static void showAlert(String message) {
    try {
      //result.success(any)
      _channel.invokeMethod('showAlert', {'message': message});
    } on PlatformException catch (e) {
      // result.error("failed", "failed unknow", "i don't know")
      print("PlatformException$e");
    } on MissingPluginException catch (e) {
      //result.notImplemented()
      print("MissingPluginException:$e");
    }
  }

  static Future<String> jsCallFlutter(int a, int b) async {
    String result = "js call failed";
    try {
      //result.success(any)
      result =
      await _channel.invokeMethod('jsCallFlutter', {'a': a, 'b': b});
    } on PlatformException catch (e) {
      // result.error("failed", "failed unknow", "i don't know")
      print("PlatformException$e");
    } on MissingPluginException catch (e) {
      //result.notImplemented()
      print("MissingPluginException:$e");
    }
    return result;
  }
}
