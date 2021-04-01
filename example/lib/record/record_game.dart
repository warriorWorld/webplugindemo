import 'package:flutter/material.dart';
import 'package:webplugindemo_example/record/student_bean.dart';

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

  @override
  void initState() {
    super.initState();
    getStudentList();
    initAnim();
  }

  void getStudentList() {
    for (int i = 0; i < 21; i++) {
      StudentBean student = StudentBean();
      student.avatar = getAssetsPath('avatar.png');
      student.score = i * 10;
      student.name = 'student$i';
      studentList.add(student);
    }
  }

  void initAnim() {
    recordAnimController = AnimationController(
        vsync: this, duration: Duration(milliseconds: RECORD_ANIM_DURATION));
    recordScaleAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: recordAnimController, curve: Curves.bounceOut));
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

  @override
  Widget build(BuildContext context) {
    return Stack(
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
            left: screenWidth / 2 - 134 / 2,
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
        Positioned(bottom: 30, child: Center(child: GridView()))
      ],
    );
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
