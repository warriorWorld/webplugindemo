import 'package:flutter/material.dart';

class TreasureChestBean {
  int id;
  Offset position;
  double endY;
  int duration;
  double chestMaxWidth;
  double chestMaxHeight;
  double scale;
  //显示在屏幕上的起止时间
  int startValidMS;
  int endValidMS;
  bool startDrop=false;
  bool opened=false;
  bool ufoDrop=false;
}
