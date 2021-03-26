import 'dart:math';

import 'package:flutter/material.dart';
import 'package:webplugindemo_example/treasurechest_bean.dart';

class AnimationDemo extends StatefulWidget {
  @override
  _AnimationDemoState createState() => _AnimationDemoState();
}

class _AnimationDemoState extends State<AnimationDemo> {
  bool switchState = false;
  bool stopScroll = false;
  ScrollController listController = ScrollController();
  Random _random = new Random(DateTime.now().millisecondsSinceEpoch);
  List<TreasureChestBean> chestList = [];
  List<Widget> chestWidgets = List<Widget>();
  double screenHeight;
  double screenWidth;
  double chestMaxWidth = 100;
  double chestMaxHeight = 120;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      initTreasureChests();
    });
  }

  void initTreasureChests() {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    for (int i = 0; i < 10; i++) {
      TreasureChestBean treasure = new TreasureChestBean();
      double x = _random.nextDouble() * (screenWidth-chestMaxWidth/2);
      double y = _random.nextDouble() * screenHeight;
      int duration = 12 + _random.nextInt(6);
      double scale = (60 + _random.nextInt(40)) / 100;
      y = y / 2;
      y = -y - chestMaxHeight;
      treasure.position = Offset(x, y);
      treasure.duration = duration;
      treasure.scale = scale;
      chestList.add(treasure);
    }
    _getTresureWidgets(false);
  }

  void _getTresureWidgets(bool startMove) {
    for (int i = 0; i < chestList.length; i++) {
      chestWidgets.add(AnimatedPositioned(
        top: startMove ? screenHeight : chestList[i].position.dy,
        left: chestList[i].position.dx,
        duration: Duration(seconds: chestList[i].duration),
        child: Image.asset(
          'assets/treasurechest.png',
          width: chestMaxWidth * chestList[i].scale,
          height: chestMaxHeight * chestList[i].scale,
          fit: BoxFit.fitWidth,
          alignment: Alignment.topCenter,
        ),
      ));
    }
  }

  void _reset() {
    setState(() {
      listController.jumpTo(0);
      stopScroll = true;
      chestWidgets.clear();
      chestList.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildRepeatCloud(),
        Positioned(
          top: 30,
          left: 90,
          child: FlatButton(
              minWidth: 80,
              height: 50,
              color: Colors.blue,
              onPressed: () {
                if (switchState) {
                  _reset();
                  initTreasureChests();
                } else {
                  stopScroll = false;
                  _firstScroll();
                }
                switchState = !switchState;
              },
              child: Text("测试")),
        ),
        Stack(
          children: chestWidgets,
        )
      ],
    );
  }

  void _firstScroll() {
    listController
        .animateTo(1500,
            duration: Duration(milliseconds: 1800),
            curve: Curves.easeInOutCubic)
        .then((value) {
      Future.delayed(Duration(seconds: 1)).then((value) => _secondScroll());
    });
  }

  void _secondScroll() {
    listController
        .animateTo(listController.offset + 800,
            duration: Duration(milliseconds: 1000), curve: Curves.easeInOutQuad)
        .then((value) {
      setState(() {
        chestWidgets.clear();
        _getTresureWidgets(true);
      });
      _infinityScroll();
    });
  }

  void _infinityScroll() {
    listController
        // listController.position.maxScrollExtent
        .animateTo(listController.offset + 1000,
            duration: Duration(seconds: 10), curve: Curves.linear)
        .then((value) {
      print("continue");
      if (stopScroll) {
        return;
      }
      _infinityScroll();
    });
  }

  Widget listHead = ListTile(
      contentPadding: EdgeInsets.zero,
      minVerticalPadding: 0,
      title: Image.asset(
        'assets/bg_cloud.png',
        fit: BoxFit.fitWidth,
        alignment: Alignment.topCenter,
      ));
  Widget listRepeat = ListTile(
      contentPadding: EdgeInsets.zero,
      minVerticalPadding: 0,
      title: Image.asset(
        'assets/cloud_repeat.png',
        fit: BoxFit.fitWidth,
        alignment: Alignment.topCenter,
      ));

  Widget _buildRepeatCloud() {
    return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        addAutomaticKeepAlives: false,
        cacheExtent: 4000,
        //提前加载后边的(需要大于第一个图的高度)
        controller: listController,
        itemBuilder: (context, i) {
          if (i == 0) {
            return listHead;
          } else {
            return listRepeat;
          }
        });
  }
}
