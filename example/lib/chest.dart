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
  AnimationController animController;
  Animation<double> chestScaleAnim;
  Animation<double> avatarScaleAnim;
  Animation<double> scoreScaleAnim;
  Animation<double> chestOpacityAnim;
  Animation<double> avatarOpacityAnim;
  String chestAsset = 'assets/treasurechest.png';
  double chestWidth;
  double chestHeight;
  double avatarSize = 60;

  @override
  void initState() {
    super.initState();
    reset();
    chestScaleController =
        AnimationController(duration: Duration(milliseconds: 500), vsync: this);
    animController = AnimationController(
        duration: Duration(milliseconds: 4000), vsync: this);
    chestScaleController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          chestAsset = 'assets/treasurechest_open.png';
          // chestWidth = chestWidth * 1.66;
          // chestHeight = chestHeight * 1.06;
          animController.forward();
        });
      }
    });
    chestScaleAnim = Tween<double>(begin: 1, end: 1.2).animate(CurvedAnimation(
        parent: chestScaleController, curve: Curves.decelerate));

    avatarScaleAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: animController,
        curve: Interval(0, 0.1, curve: Curves.decelerate)));
    scoreScaleAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: animController,
        curve: Interval(0.1, 0.2, curve: Curves.decelerate)));
    chestOpacityAnim = Tween<double>(begin: 1, end: 0).animate(CurvedAnimation(
        parent: animController,
        curve: Interval(0.2, 0.3, curve: Curves.decelerate)));
    avatarOpacityAnim = Tween<double>(begin: 1, end: 0).animate(CurvedAnimation(
        parent: animController,
        curve: Interval(0.9, 1, curve: Curves.decelerate)));
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
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      top: widget.chestBean.position.dy,
      left: widget.chestBean.position.dx,
      duration: Duration(milliseconds: widget.chestBean.duration),
      child: Column(children: [
        FadeTransition(
          opacity: avatarOpacityAnim,
          child: ScaleTransition(
            scale: scoreScaleAnim,
            alignment: Alignment.center,
            child: Row(
              children: [
                Image.asset(
                  'treasurechest_score_add.png',
                  width: 10,
                  height: 20,
                  fit: BoxFit.fitWidth,
                ),
                Image.asset(
                  'treasurechest_score_2.png',
                  width: 10,
                  height: 20,
                  fit: BoxFit.fitWidth,
                ),
                Image.asset(
                  'treasurechest_score_0.png',
                  width: 10,
                  height: 20,
                  fit: BoxFit.fitWidth,
                )
              ],
            ),
          ),
        ),
        Container(
          width: chestWidth,
          height: chestHeight * 2,
          child: Stack(children: [
            Positioned(
              top: 0,
              child: FadeTransition(
                opacity: chestOpacityAnim,
                child: ScaleTransition(
                  scale: chestScaleAnim,
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
              child: FadeTransition(
                opacity: avatarOpacityAnim,
                child: ScaleTransition(
                  scale: avatarScaleAnim,
                  alignment: Alignment.center,
                  child: Image.asset(
                    'avatar.png',
                    width: avatarSize,
                    height: avatarSize,
                    fit: BoxFit.fitHeight,
                    alignment: Alignment.center,
                  ),
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}
