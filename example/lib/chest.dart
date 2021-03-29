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

class _ChestWidgetState extends State<ChestWidget>
    with TickerProviderStateMixin {
  AnimationController chestScaleController;
  Animation<double> scaleAnim;
  String chestAsset = 'assets/treasurechest.png';
  double chestWidth;
  double chestHeight;
  double avatarSize = 60;
  double chestOpacity = 1;

  @override
  void initState() {
    super.initState();
    reset();
    chestScaleController =
        AnimationController(duration: Duration(milliseconds: 500), vsync: this);
    chestScaleController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          chestAsset = 'assets/treasurechest_open.png';
          // chestWidth = chestWidth * 1.66;
          // chestHeight = chestHeight * 1.06;
          chestOpacity = 0;
        });
      }
    });
    scaleAnim = Tween<double>(begin: 1, end: 1.2).animate(CurvedAnimation(
        parent: chestScaleController, curve: Curves.decelerate));
  }

  void open() {
    chestScaleController.forward();
  }

  @override
  void didUpdateWidget(covariant ChestWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.chestBean.opened) {
      open();
    }
  }

  void reset() {
    chestAsset = 'assets/treasurechest.png';
    chestWidth = widget.chestMaxWidth * widget.chestBean.scale;
    chestHeight = widget.chestMaxHeight * widget.chestBean.scale;
    avatarSize = avatarSize * widget.chestBean.scale;
    chestOpacity = 1;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      top: widget.chestBean.position.dy,
      left: widget.chestBean.position.dx,
      duration: Duration(seconds: widget.chestBean.duration),
      child: Container(
        width: chestWidth,
        height: chestHeight * 2,
        child: Stack(children: [
          Positioned(
            top: 0,
            child: AnimatedOpacity(
              opacity: chestOpacity,
              duration: Duration(milliseconds: 500),
              child: ScaleTransition(
                scale: scaleAnim,
                alignment: Alignment.center,
                child: Image.asset(
                  chestAsset,
                  width: chestWidth,
                  height: chestHeight,
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                ),
              ),
            ),
          ),
          Positioned(
            left: chestWidth / 2 - avatarSize / 2,
            child: Image.asset(
              'treasurechest_avatarframe.png',
              width: avatarSize,
              height: avatarSize,
              fit: BoxFit.fitHeight,
              alignment: Alignment.center,
            ),
          ),
        ]),
      ),
    );
  }
}
