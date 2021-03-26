import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'package:webplugindemo_example/treasurechest_bean.dart';

import 'chest.dart';

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
  double screenHeight;
  double screenWidth;
  double chestMaxWidth = 100;
  double chestMaxHeight = 120;
  Timer timer;
  int tickDurantion = 100;
  int currentTick = 0;

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
      double x = _random.nextDouble() * (screenWidth - chestMaxWidth);
      double y = _random.nextDouble() * screenHeight;
      int duration = 12 + _random.nextInt(6);
      double scale = (60 + _random.nextInt(40)) / 100;
      y = y / 2;
      y = -y - chestMaxHeight;
      //unit d/millsecond
      double speed = (screenHeight - y) / (duration * 1000);
      int startValidMS = -y ~/ speed;
      int endValidMS = (screenHeight - y - chestMaxHeight * scale) ~/ speed;
      print("startValidMs:$startValidMS ,endValidMs:$endValidMS");
      print("y:$y,screenHeight:$screenHeight");
      treasure.position = Offset(x, y);
      treasure.duration = duration;
      treasure.scale = scale;
      treasure.id=i;
      treasure.startValidMS=startValidMS;
      treasure.endValidMS=endValidMS;
      chestList.add(treasure);
    }
    //按尺寸大小排序,为了达到大的盖住小的效果
    chestList.sort((a,b){
      if(a.scale>b.scale){
        return 1;
      }else if(a.scale<b.scale){
        return -1;
      }else{
        return 0;
      }
    });
  }

  void _reset() {
    setState(() {
      listController.jumpTo(0);
      stopScroll = true;
      chestList.clear();
      timer.cancel();
      timer = null;
      currentTick = 0;
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
        Positioned(
          top: 30,
          right: 90,
          child: FlatButton(
              minWidth: 80,
              height: 50,
              color: Colors.orange,
              onPressed: () {
                _getOneValidChest();
              },
              child: Text("抢答")),
        ),
        Stack(
          children: chestList.map((item) => new ChestWidget(item)).toList(),
        )
      ],
    );
  }

  void _getOneValidChest() {
    List<TreasureChestBean> validList = [];
    for (int i = 0; i < chestList.length; i++) {
      TreasureChestBean item = chestList[i];
      if (!item.opened &&
          currentTick < item.endValidMS &&
          currentTick > item.startValidMS) {
        print("add one id:${item.id}");
        validList.add(item);
      }
    }
    if(validList.length==0){
      Toast.show("没有宝箱可以抢!", context);
      return;
    }
    int randomI = _random.nextInt(validList.length);
    TreasureChestBean randomChest = validList[randomI];
    randomChest.opened=true;
    for(int i=0;i<chestList.length;i++){
      if(chestList[i].id==randomChest.id){
        print("selected one id:${randomChest.id}");
        setState(() {
          chestList[i]=randomChest;
        });
        break;
      }
    }
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
      _startDropTresure();
      _infinityScroll();
    });
  }

  void _startDropTresure() {
    setState(() {
      for (int i = 0; i < chestList.length; i++) {
        Offset newPosition = Offset(chestList[i].position.dx, screenHeight);
        chestList[i].position = newPosition;
      }
    });
    timer =
        new Timer.periodic(new Duration(milliseconds: tickDurantion), (timer) {
      currentTick = tickDurantion * timer.tick;
      // print(currentTick);
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
        'assets/bg_cloud1.png',
        fit: BoxFit.fitWidth,
        alignment: Alignment.topCenter,
      ));
  Widget listRepeat = ListTile(
      contentPadding: EdgeInsets.zero,
      minVerticalPadding: 0,
      title: Image.asset(
        'assets/cloud_repeat1.png',
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
