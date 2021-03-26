import 'package:flutter/material.dart';

class LayoutDemo extends StatefulWidget {
  @override
  _LayoutDemoState createState() => _LayoutDemoState();
}

class _LayoutDemoState extends State<LayoutDemo> {
  @override
  Widget build(BuildContext context) {
    return Align(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.red,
      ),
      alignment: Alignment.bottomLeft,
    );
  }
}
