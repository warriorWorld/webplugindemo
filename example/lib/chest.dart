import 'package:flutter/material.dart';
import 'package:webplugindemo_example/treasurechest_bean.dart';

class ChestWidget extends StatefulWidget {
  final double chestMaxWidth = 100;
  final double chestMaxHeight = 120;
  TreasureChestBean chestBean;

  ChestWidget(TreasureChestBean bean) {
    chestBean = bean;
  }

  @override
  _ChestWidgetState createState() => _ChestWidgetState();
}

class _ChestWidgetState extends State<ChestWidget> {
  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      top: widget.chestBean.position.dy,
      left: widget.chestBean.position.dx,
      duration: Duration(seconds: widget.chestBean.duration),
      child: Image.asset(
        widget.chestBean.opened?'assets/treasurechest_open.png':'assets/treasurechest.png',
        width: widget.chestMaxWidth * widget.chestBean.scale,
        height: widget.chestMaxHeight * widget.chestBean.scale,
        fit: BoxFit.fitWidth,
        alignment: Alignment.topCenter,
      ),
    );
  }
}
