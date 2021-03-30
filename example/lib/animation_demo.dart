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
  static const double CHEST_MAX_WIDTH = 100;
  static const double CHEST_MAX_HEIGHT = 120;
  Timer timer;
  final int tickDurantion = 100;
  int currentTick = 0;
  static const  int MIN_DROP_DURATION = 12, RANDOM_DROP_DURATION = 6;
  static const int MIN_CHEST_SCALE = 60, RANDOM_CHEST_SCALE = 40;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      screenHeight = MediaQuery.of(context).size.height;
      screenWidth = MediaQuery.of(context).size.width;
      initTreasureChests();
    });
  }

  @override
  void dispose() {
    super.dispose();
    listController.dispose();
    timer.cancel();
  }

  void addUFODropChest() {
    TreasureChestBean ufoDroped = new TreasureChestBean();
    double x=180,y=100;
    ufoDroped.position = Offset(x, y);
    ufoDroped.duration =
        (MIN_DROP_DURATION + _random.nextInt(RANDOM_DROP_DURATION)) * 1000;
    ufoDroped.scale = (MIN_CHEST_SCALE + _random.nextInt(RANDOM_CHEST_SCALE)) / 100;
    ufoDroped.id=0;
    ufoDroped.startValidMS=0;
    double speed = (screenHeight - y) / (ufoDroped.duration);
    ufoDroped.endValidMS=(screenHeight - y - CHEST_MAX_HEIGHT * ufoDroped.scale) ~/ speed;
    ufoDroped.chestMaxHeight=CHEST_MAX_HEIGHT;
    ufoDroped.chestMaxWidth=CHEST_MAX_WIDTH;
    chestList.add(ufoDroped);
  }

  void initTreasureChests() {
    addUFODropChest();
    for (int i = 1; i <= 10; i++) {
      TreasureChestBean treasure = new TreasureChestBean();
      double x = _random.nextDouble() * (screenWidth - CHEST_MAX_WIDTH);
      double y = _random.nextDouble() * screenHeight;
      int duration =
          (MIN_DROP_DURATION + _random.nextInt(RANDOM_DROP_DURATION)) * 1000;
      double scale = (MIN_CHEST_SCALE + _random.nextInt(RANDOM_CHEST_SCALE)) / 100;
      y = y / 2;
      y = -y - CHEST_MAX_HEIGHT;
      //unit d/millsecond
      double speed = (screenHeight - y) / (duration);
      int startValidMS = -y ~/ speed; //等价于(-y / speed).toInt()
      int endValidMS = (screenHeight - y - CHEST_MAX_HEIGHT * scale) ~/ speed;
      print("startValidMs:$startValidMS ,endValidMs:$endValidMS");
      print("y:$y,screenHeight:$screenHeight");
      treasure.position = Offset(x, y);
      treasure.duration = duration;
      treasure.scale = scale;
      treasure.id = i;
      treasure.startValidMS = startValidMS;
      treasure.endValidMS = endValidMS;
      treasure.chestMaxHeight=CHEST_MAX_HEIGHT;
      treasure.chestMaxWidth=CHEST_MAX_WIDTH;
      chestList.add(treasure);
    }
    //按尺寸大小排序,为了达到大的盖住小的效果
    chestList.sort((a, b) {
      if (a.scale > b.scale) {
        return 1;
      } else if (a.scale < b.scale) {
        return -1;
      } else {
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
    if (validList.length == 0) {
      Toast.show("没有宝箱可以抢!", context);
      return;
    }
    int randomI = _random.nextInt(validList.length);
    TreasureChestBean randomChest = validList[randomI];
    randomChest.opened = true;
    randomChest.position = Offset(randomChest.position.dx,
        randomChest.position.dy - (60 + 20)); //头像和分数的高度
    randomChest.duration = randomChest.duration - currentTick;
    for (int i = 0; i < chestList.length; i++) {
      if (chestList[i].id == randomChest.id) {
        print("selected one id:${randomChest.id}");
        setState(() {
          chestList[i] = randomChest;
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
        if(chestList[i].id==0){
          chestList[i].ufoDrop=true;
        }
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
