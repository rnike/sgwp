import 'dart:ui';
import 'package:flame/components/component.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

//
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
    super.resize(size);
  }
}



class Background extends Component {
  @override
  void render(Canvas c) {
    if (GameValues.gameSize == null) return;

    //背景尺寸，使用 BaseGame resize 的值
    final backgroundSize = Offset.zero & GameValues.gameSize;
    
    //畫出簡單的純藍色背景
    c.drawRect(backgroundSize, Paint()..color = Colors.blue);
  }
  @override
  void update(double t) {
    // TODO: implement update
  }
}

//通用變數放一起
class GameValues {
  static Size gameSize;
  static int score;
  static int heightScore;
}

enum ObjectType { people, goods }

class GameObject extends Component {
  static const Size OBJ_SIZE = Size(50,50);
  final ObjectType type;
  GameObject(this.type);
  @override
  void render(Canvas c) {
    // TODO: implement render
  }

  @override
  void update(double t) {
    // TODO: implement update
  }
}


//人出得去
class People extends GameObject {
  People({ObjectType type=ObjectType.people}) : super(type);
}

//貨進得來
class Goods extends GameObject {
  Goods({ObjectType type=ObjectType.goods}) : super(type);
}
