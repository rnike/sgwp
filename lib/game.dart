import 'dart:ui';
import 'package:flame/components/component.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class MyGame extends BaseGame {
  MyGame() {
    init();
  }
  init() async {
    add(Background());
  }

  @override
  void resize(Size size) {
    GameValues.gameSize = size;
  }
}

class Background extends Component {
  @override
  void render(Canvas c) {
    if (GameValues.gameSize == null) return;
    c.drawRect(Offset.zero & GameValues.gameSize, Paint()..color = Colors.blue);
  }
  @override
  void update(double t) {
    // TODO: implement update
  }
}

class GameValues {
  static Size gameSize;
  static int score;
  static int heightScore;
}

class GameObject extends Component {
  static const double WIDTH = 50;
  static const double HEIGHT = 50;

  @override
  void render(Canvas c) {
    // TODO: implement render
  }

  @override
  void update(double t) {
    // TODO: implement update
  }
}

enum ObjectType { people, goods }

//人出得去
class People extends GameObject {}

//貨進得來
class Goods extends GameObject {}
