import 'dart:math';

import 'package:flutter/material.dart';
import 'package:webplugindemo_example/record/student_bean.dart';

enum AvatarAnimType { SCORE, AVATAR, NAME }

class RecordGame extends StatefulWidget {
  @override
  _RecordGameState createState() => _RecordGameState();
}

class _RecordGameState extends State<RecordGame> with TickerProviderStateMixin {
  static const ASSETS_PATH = '';
  double screenHeight = 0;
  double screenWidth = 0;
  static const double ANSWER_TOOL_HEIGHT = 100, ANSWER_TOOL_WIDTH = 66;
  static const int RECORD_ANIM_DURATION = 500;
  AnimationController recordAnimController;
  Animation<double> recordScaleAnim;
  double answerToolTop = -ANSWER_TOOL_HEIGHT;
  bool isRecordAnimReverse = false;
  List<StudentBean> studentList = [];
  double studentsBgWidth = 0, studentsBgHeight = 150;
  static const double AVATAR_SIZE = 70, //头像大小
      AVATAR_SPACE = 15, //列间距
      AVATAR_RUN_SPACE = 15, //行间距
      AVATAR_PADDING = 30, //列表上下padding
      AVATAR_ITEM_PADDING = 10, //item内部上下padding
      AVATAR_ITEM_RUN_PADDING = 15; //item内部左右padding
  AnimationController studentListAnimController;
  Animation<double> studentListScaleAnim, mvpScaleAnim;
  int studentAnimDuration = 1500;
  Random _random = new Random(DateTime.now().millisecondsSinceEpoch);

  @override
  void initState() {
    super.initState();
    initAnim();
    WidgetsBinding.instance.addPostFrameCallback((callback) {
      initViewSize();
    });
  }

  void initViewSize() {
    studentsBgWidth = screenWidth - 50;
    int rowCount, columnMaxCount;
    columnMaxCount = studentsBgWidth ~/
        (AVATAR_SPACE + AVATAR_SIZE + AVATAR_ITEM_RUN_PADDING * 2);
    rowCount = studentList.length ~/ columnMaxCount;
    if (studentList.length % columnMaxCount > 0) {
      rowCount++;
    }
    //行数*头像高度+行间距*(行数-1)+上下padding+item内部上下padding
    studentsBgHeight = rowCount * AVATAR_SIZE +
        (rowCount - 1) * AVATAR_RUN_SPACE +
        AVATAR_PADDING * 2 +
        rowCount * AVATAR_ITEM_PADDING * 2;
    print(
        "column max count:$columnMaxCount,row count:$rowCount,bg height:$studentsBgHeight");
  }

  void getStudentList(int lenth) {
    studentList.clear();
    for (int i = 0; i < lenth; i++) {
      StudentBean student = StudentBean();
      student.avatar = getAssetsPath('avatar.png');
      student.score = i * 10;
      student.name = 'student$i';
      studentList.add(student);
    }
    studentAnimDuration = 200 * studentList.length;
    studentListAnimController.duration =
        Duration(milliseconds: 500 + studentAnimDuration);
  }

  void initAnim() {
    recordAnimController = AnimationController(
        vsync: this, duration: Duration(milliseconds: RECORD_ANIM_DURATION));
    recordScaleAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: recordAnimController, curve: Curves.bounceOut));

    studentListAnimController = AnimationController(vsync: this);
    studentListScaleAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
            parent: studentListAnimController,
            curve: Interval(0, 0.1, curve: Curves.bounceOut)));
    mvpScaleAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: studentListAnimController,
        curve: Interval(0.1, 0.2, curve: Curves.bounceOut)));
  }

  void startRecord() {
    isRecordAnimReverse = false;
    recordAnimController.forward();
    setState(() {
      answerToolTop = 10;
    });
    Future.delayed(Duration(seconds: 3)).then((value) {
      isRecordAnimReverse = true;
      recordAnimController.reverse();
      setState(() {
        answerToolTop = -ANSWER_TOOL_HEIGHT;
      });
    });
  }

  void showAnswerResult() {
    Future.delayed(Duration(seconds: 4)).then((value) {
      getStudentList(_random.nextInt(32));
      initViewSize();
      setState(() {
      });
      studentListAnimController.forward();
    });
    Future.delayed(Duration(seconds: 10))
        .then((value) => studentListAnimController.reverse(from: 0.2));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Image.asset(
          getAssetsPath('bg_class.png'),
          width: screenWidth,
          height: screenHeight,
          fit: BoxFit.fill,
        ),
        Positioned(
          top: 30,
          left: 90,
          child: FlatButton(
              minWidth: 80,
              height: 50,
              color: Colors.blue,
              onPressed: () {
                startRecord();
                showAnswerResult();
              },
              child: Text("test")),
        ),
        AnimatedPositioned(
          right: 30,
          duration: Duration(milliseconds: RECORD_ANIM_DURATION),
          curve: isRecordAnimReverse ? Curves.bounceIn : Curves.bounceOut,
          top: answerToolTop,
          child: Image.asset(
            getAssetsPath('answer_tool.png'),
            width: ANSWER_TOOL_WIDTH,
            height: ANSWER_TOOL_HEIGHT,
            alignment: Alignment.topCenter,
          ),
        ),
        Positioned(
            bottom: 30,
            left: screenWidth / 2 - 97 / 2,
            child: ScaleTransition(
              scale: recordScaleAnim,
              alignment: Alignment.center,
              child: Image.asset(
                getAssetsPath('record.png'),
                width: 67,
                height: 97,
                alignment: Alignment.bottomCenter,
              ),
            )),
        Positioned(
          bottom: 30,
          left: screenWidth / 2 - studentsBgWidth / 2,
          width: studentsBgWidth,
          height: studentsBgHeight,
          child: ScaleTransition(
            scale: studentListScaleAnim,
            alignment: Alignment.center,
            child: Stack(
              children: [
                Container(
                  width: studentsBgWidth,
                  height: studentsBgHeight,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(50),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(AVATAR_PADDING),
                  child: Center(
                    child: Wrap(
                      spacing: AVATAR_SPACE,
                      // gap between adjacent chips
                      runSpacing: AVATAR_RUN_SPACE,
                      // gap between lines
                      alignment: WrapAlignment.center,
                      runAlignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: List.generate(studentList.length, (index) {
                        return getStudentItemTile(index);
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: studentsBgHeight + 10,
          child: ScaleTransition(
            scale: mvpScaleAnim,
            alignment: Alignment.center,
            child: Image.asset(
              getAssetsPath('mvp.png'),
              width: 300,
              height: 100,
              fit: BoxFit.fill,
            ),
          ),
        )
      ],
    );
  }

  Widget getStudentItemTile(int index) {
    return Stack(alignment: Alignment.center, children: [
      SizedBox(
        height: AVATAR_SIZE + AVATAR_ITEM_PADDING * 2,
        width: AVATAR_SIZE + AVATAR_ITEM_RUN_PADDING * 2,
      ),
      ScaleTransition(
        scale: getAvatarAnim(index, AvatarAnimType.AVATAR),
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: getAvatarRadius(index),
              backgroundImage: Image.asset(
                studentList[index].avatar,
                width: AVATAR_SIZE,
                height: AVATAR_SIZE,
                alignment: Alignment.center,
                fit: BoxFit.cover,
              ).image,
            ),
            Image.asset(
              getAvatarFrame(index),
              width: AVATAR_SIZE,
              height: AVATAR_SIZE,
              fit: BoxFit.contain,
            )
          ],
        ),
      ),
      Positioned(
        bottom: 0,
        child: ScaleTransition(
          scale: getAvatarAnim(index, AvatarAnimType.NAME),
          child: Stack(alignment: Alignment.center, children: [
            Image.asset(getNameFrame(index)),
            Text(
              studentList[index].name,
              style: TextStyle(color: Colors.white, fontSize: 12),
            )
          ]),
        ),
        width: 70,
        height: 20,
      ),
      Positioned(
          top: 0,
          right: 0,
          child: getScoreWidget(index, studentList[index].score))
    ]);
  }

  Animation<double> getAvatarAnim(int index, AvatarAnimType type) {
    double begin, end;
    //至少等背景出来后才开始所以不是1
    double beginEven = 0.85 / studentList.length;
    begin = 0.15 + index * beginEven;
    //实现交替动画效果
    double endEven = 1.2 / studentList.length;
    end = begin + endEven;
    if (end > 1) {
      end = 1;
    }
    //单个item再细分3部分动画
    double singleDuration = end - begin;
    double beginEven1 = singleDuration / 3;
    double endEven1 = endEven / 1.35 / 3;
    switch (type) {
      case AvatarAnimType.AVATAR:
        break;
      case AvatarAnimType.NAME:
        begin = begin + beginEven1;
        break;
      case AvatarAnimType.SCORE:
        begin = begin + beginEven1 * 2;
        break;
    }
    end = begin + endEven1;
    if (end > 1) {
      end = 1;
    }
    return Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: studentListAnimController,
        curve: Interval(begin, end, curve: Curves.bounceOut)));
  }

  Widget getScoreWidget(int index, int score) {
    String s = '+' + score.toString();
    List<String> scores = s.split('');
    return ScaleTransition(
      scale: getAvatarAnim(index, AvatarAnimType.SCORE),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(scores.length, (index) {
          return Image.asset(
            getSingleFigureImg(scores[index]),
            width: 15,
            height: 20,
            fit: BoxFit.fill,
            alignment: Alignment.center,
          );
        }),
      ),
    );
  }

  String getSingleFigureImg(String s) {
    switch (s) {
      case '+':
        return getAssetsPath('treasurechest_score_add.png');
      case '0':
        return getAssetsPath('treasurechest_score_0.png');
      case '1':
        return getAssetsPath('treasurechest_score_1.png');
      case '2':
        return getAssetsPath('treasurechest_score_2.png');
      case '3':
        return getAssetsPath('treasurechest_score_3.png');
      case '4':
        return getAssetsPath('treasurechest_score_4.png');
      case '5':
        return getAssetsPath('treasurechest_score_5.png');
      case '6':
        return getAssetsPath('treasurechest_score_6.png');
      case '7':
        return getAssetsPath('treasurechest_score_7.png');
      case '8':
        return getAssetsPath('treasurechest_score_8.png');
      case '9':
        return getAssetsPath('treasurechest_score_9.png');
      default:
        throw Exception('illegal parameter');
    }
  }

  String getAvatarFrame(int index) {
    switch (index) {
      case 0:
        return getAssetsPath('avatar_frame_gold.png');
      case 1:
        return getAssetsPath('avatar_frame_silver.png');
      case 2:
        return getAssetsPath('avatar_frame_copper.png');
      default:
        return getAssetsPath('avatar_fame.png');
    }
  }

  String getNameFrame(int index) {
    switch (index) {
      case 0:
        return getAssetsPath('name_bg_orange.png');
      case 1:
        return getAssetsPath('name_bg_blue.png');
      case 2:
        return getAssetsPath('name_bg_red.png');
      default:
        return getAssetsPath('name_bg_purple.png');
    }
  }

  double getAvatarRadius(int index) {
    switch (index) {
      case 0:
        return (AVATAR_SIZE - 12.5) / 2;
      case 1:
        return (AVATAR_SIZE - 12.5) / 2;
      case 2:
        return (AVATAR_SIZE - 14) / 2;
      default:
        return (AVATAR_SIZE - 10) / 2;
    }
  }

  String getAssetsPath(String path) {
    return ASSETS_PATH + path;
  }

  @override
  void dispose() {
    super.dispose();
    recordAnimController.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
  }
}
