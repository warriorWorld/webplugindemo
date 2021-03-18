@JS()
library caller;

import 'package:js/js.dart';

@JS('showJSDialog')
external Future<String> showJSDialog(String message);