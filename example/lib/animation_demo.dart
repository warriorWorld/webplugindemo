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

class _AnimationDemoState extends State<AnimationDemo>
    with SingleTickerProviderStateMixin {
  bool switchState = false;
  bool stopScroll = false;
  ScrollController listController = ScrollController();
  Random _random = new Random(DateTime.now().millisecondsSinceEpoch);
  List<TreasureChestBean> chestList = [];
  double screenHeight = 0;
  double screenWidth = 0;
  static const double CHEST_MAX_WIDTH = 150;
  static const double CHEST_MAX_HEIGHT = 180;
  Timer timer;
  final int tickDurantion = 80;
  int currentTick = 0;
  static const int GAME_DURATION = 30;
  int maxY = 1500; //箱子Y轴生成的随机范围 越大Y轴上越分散
  static const int BASE_SPEED = 100;
  static const int RANDOM_DROP_DURATION = 5;
  static const int MIN_CHEST_SCALE = 60, RANDOM_CHEST_SCALE = 40;
  List<ChestWidget> chests = [];
  double readyWidth = 200, readyHeight = 100;
  double readyTop;
  double countdownHeight = 200, countdownWidth = 100;
  AnimationController countdownController;
  Animation<double> scaleAnim;
  String countdownImg = 'three.png';

  @override
  void initState() {
    super.initState();
    initAnim();
    Future.delayed(Duration.zero, () {
      screenHeight = MediaQuery.of(context).size.height;
      screenWidth = MediaQuery.of(context).size.width;
      maxY = BASE_SPEED * GAME_DURATION - screenHeight.toInt();
      print("screen height:$screenHeight ,max y:$maxY");
      readyTop = -readyHeight;
      initTreasureChests();
      // initChests();
    });
  }

  void initAnim() {
    countdownController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));
    scaleAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: countdownController,
        curve: Interval(0, 0.3, curve: Curves.decelerate)));
  }

  @override
  void dispose() {
    super.dispose();
    listController.dispose();
    timer.cancel();
  }

  void addUFODropChest() {
    TreasureChestBean ufoDroped = new TreasureChestBean();
    double x = 180, y = 100;
    ufoDroped.position = Offset(x, y);
    ufoDroped.scale =
        (MIN_CHEST_SCALE + _random.nextInt(RANDOM_CHEST_SCALE)) / 100;
    ufoDroped.id = 0;
    ufoDroped.startValidMS = 0;
    double distance = screenHeight - y;
    int duration =
        (distance ~/ BASE_SPEED + _random.nextInt(RANDOM_DROP_DURATION)) * 1000;
    double actualSpeed = distance / duration;
    ufoDroped.duration = duration;
    ufoDroped.endValidMS =
        (screenHeight - y - CHEST_MAX_HEIGHT * ufoDroped.scale) ~/ actualSpeed;
    ufoDroped.chestMaxHeight = CHEST_MAX_HEIGHT;
    ufoDroped.chestMaxWidth = CHEST_MAX_WIDTH;
    chestList.add(ufoDroped);
  }

  void initTreasureChests() {
    addUFODropChest();
    for (int i = 1; i <= 15; i++) {
      TreasureChestBean treasure = new TreasureChestBean();
      double x = _random.nextDouble() * (screenWidth - CHEST_MAX_WIDTH);
      double y = _random.nextDouble() * maxY;
      double scale =
          (MIN_CHEST_SCALE + _random.nextInt(RANDOM_CHEST_SCALE)) / 100;
      // y = y / 2;
      y = -y - CHEST_MAX_HEIGHT;
      //unit d/millsecond
      double distance = screenHeight - y;
      int duration =
          (distance ~/ BASE_SPEED + _random.nextInt(RANDOM_DROP_DURATION)) *
              1000;
      double actualSpeed = distance / duration;
      print("speed:$actualSpeed");
      int startValidMS = -y ~/ actualSpeed; //等价于(-y / speed).toInt()
      int endValidMS =
          (screenHeight - y - CHEST_MAX_HEIGHT * scale) ~/ actualSpeed;
      print("startValidMs:$startValidMS ,endValidMs:$endValidMS");
      print("y:$y,screenHeight:$screenHeight");
      treasure.position = Offset(x, y);
      treasure.duration = duration;
      treasure.scale = scale;
      treasure.id = i;
      treasure.startValidMS = startValidMS;
      treasure.endValidMS = endValidMS;
      treasure.chestMaxHeight = CHEST_MAX_HEIGHT;
      treasure.chestMaxWidth = CHEST_MAX_WIDTH;
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

  void initChests() {
    chests = chestList.map((item) => new ChestWidget(item)).toList();
  }

  void _reset() {
    setState(() {
      listController.jumpTo(0);
      stopScroll = true;
      chestList.clear();
      timer.cancel();
      timer = null;
      currentTick = 0;
      readyTop = -readyHeight;
      countdownHeight = 200;
      countdownWidth = 100;
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
              child: Text("test")),
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
              child: Text("grab")),
        ),
        AnimatedPositioned(
            left: screenWidth / 2 - readyWidth / 2,
            top: readyTop,
            curve: Curves.bounceIn,
            width: readyWidth,
            height: readyHeight,
            child: Image.asset(
              'ready.png',
              alignment: Alignment.topCenter,
            ),
            duration: Duration(milliseconds: 500)),
        Positioned(
            top: screenHeight / 2 - countdownHeight / 2,
            left: screenWidth / 2 - countdownWidth / 2,
            child: ScaleTransition(
              scale: scaleAnim,
              alignment: Alignment.center,
              child: Image.asset(
                countdownImg,
                width: countdownWidth,
                height: countdownHeight,
              ),
            )),
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
      Toast.show("no valid chest!", context);
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
    countdown();
    listController.animateTo(1500,
        duration: Duration(milliseconds: 1800), curve: Curves.easeInOutCubic);
  }

  void countdown() {
    setState(() {
      readyTop = 0;
    });
    countdownController.repeat();
    Future.delayed(Duration(seconds: 1)).then((value) {
      setState(() {
        countdownImg = 'two.png';
      });
    });
    Future.delayed(Duration(seconds: 2)).then((value) {
      setState(() {
        countdownImg = 'one.png';
        readyTop = -readyHeight;
      });
    });
    Future.delayed(Duration(seconds: 3)).then((value) {
      setState(() {
        countdownWidth = 400;
        countdownImg = 'go.png';
      });
      _secondScroll();
    });
    Future.delayed(Duration(seconds: 4)).then((value) {
      countdownController.reset();
      // countdownController.dispose();
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
        chestList[i].startDrop = true;
        if (chestList[i].id == 0) {
          chestList[i].ufoDrop = true;
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
