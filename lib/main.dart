import 'dart:math';

import 'package:flame/components/component.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

///通用變數放外面
MyGame myGame;
int score = 0;

// 應用程式初始化
void main() {

  // 設定應用程式為全螢幕
  Flame.util.fullScreen();
  Flame.util.setOrientation(DeviceOrientation.portraitUp);

  // 設定應用程式方向
  SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp,DeviceOrientation.portraitDown]);
  
  // 為了能取得遊戲參數，將 MyGame 新增至通用變數
  myGame = MyGame();

  //拖曳辨識器
  var drag = VerticalDragGestureRecognizer();
  drag.onUpdate = myGame.dragUpdate;

  //啟動
  runApp(myGame.widget);
  
  // addGestureRecognizer 一定要加在 runApp 的後面，否則會出現錯誤訊息
  Flame.util.addGestureRecognizer(drag);
}



//我的遊戲
class MyGame extends BaseGame {

  ///新建 MyGame 這個物件時一定會跑到的方法，所以把初始化寫在這邊
  MyGame() {
    init();
  }

  ///遊戲初始化
  init() async {
    add(Scoreboard());
    add(GameObject());
  }
  
  dragUpdate(DragUpdateDetails detail){
    components.where((x)=>x is GameObject).where((x)=>!(x as GameObject).isAway).forEach((x){
        GameObject obj = x;

        // 不要移動還沒畫出來的矩形
        if(obj.rect == null)return;
        
        // 增加移動量到 verticalPosition
        obj.verticalPosition += detail.delta.dy;
        
        // 定義一個距離
        final distance = 200.0;
        
        // 貨出得去，人進得來
        if(obj.type == ObjectType.goods){
          if(obj.verticalPosition < -distance){
            obj.isAway = true;
            add(GameObject());
            score ++;
          }
        }else{
          if(obj.verticalPosition > distance){
            obj.isAway = true;
            add(GameObject());
            score ++;
          }
        }
    });
  }

}

///物件類別
enum ObjectType {
  ///人
  people,
  ///貨
  goods
}

///遊戲物件
class GameObject extends Component {

  ///遊戲物件大小
  static const Size OBJ_SIZE = Size(80, 80);
  
  ///遊戲物件類別
  ObjectType type;

  //判斷是否進來或出去了
  bool isAway = false;
 
  GameObject(){
    //新增的時候隨機賦予它 貨 or 人的屬性 
    Random random = new Random();
    var randInt = random.nextInt(10);
    type = randInt.isOdd? ObjectType.goods:ObjectType.people;
  }

  /// 遊戲物件的位置，初始為 0
  double verticalPosition = 0;
  
  /// 這個物件的矩形，render 和 update 都會用到
  Rect rect;

  /// 表示這個物件是否需要被刪除
  bool isDestroied = false;

  ///修改這個方法，讓 MyGame 在 update 的時候可以正確地移除這個物件
  @override
  bool destroy() {
    return isDestroied;
  }
  
  /// 「把東西畫出來」的程式碼就放 render
  ///
  /// 舉例：
  ///
  /// c.畫矩形(位置0,0 ＆ 大小50x50 的矩形，顏色白色);
  ///
  /// 換算成程式碼
  /// 
  /// ```dart
  /// c.drawRect(Offset.zero & Size(50,50), Paint()..color=Colors.white);
  /// ```
  @override
  void render(Canvas c) {

    // 計算座標
    final center = myGame.size.center(Offset(0,verticalPosition)-OBJ_SIZE.center(Offset.zero));

    // 計算矩形
    rect = center & OBJ_SIZE;
    
    // 畫矩形
    c.drawRect(rect, Paint()..color=type==ObjectType.goods?Colors.green:Colors.blue);

  }
  /// update 這個方法會被 Flame 定期呼叫
  ///
  /// 參數的變動可以放這裡，每次 update 時就會更新那個參數，
  ///
  /// 與 render 搭配可以實作一個會變動的物件
  ///
  /// 舉例：
  /// 如果大小超過50x50大小就變回1x1，此外每次update長寬都增加1
  /// 換算成程式碼 (大小參數名稱 s 定義在 Component 裡 初始值 為 Size(50,50))
  /// ```dart
  /// if( s.width > 50){
  ///   s = Size(1,1);
  ///} else {
  ///   s = Size( s.width+1, s.height+1);
  ///}
  /// ```
  @override
  void update(double t) {
    if(!isAway&&verticalPosition !=0){
      // 如果還沒進來或出去且物件不在中心點的話做以下動作

      // 定義一個速度
      var speed = t * 500;

      if(verticalPosition.abs()< speed){
        // 如果物件位置的絕對值小於這個速度，就讓它等於 0
        verticalPosition = 0;
      }else{
        // 反之則讓它以 speed 的速度趨向 0
        verticalPosition += verticalPosition<0? speed:-speed;
      }
    }else if(isAway && !isDestroied){
      //在物件被標記移除前，如果進來就讓它更進來,如果出去就讓它更出去

      // 定義一個速度
      var speed = t * 500;
      if(verticalPosition<0){
        //更出去
        verticalPosition -= speed;
      }else{
        //更進來
        verticalPosition += speed;
      }
      
      //如果超出螢幕範圍，則標記移除它
      if(rect.height+rect.top <0 || rect.top> myGame.size.height){
        isDestroied = true;
      }
    }
  }
}


//分數
class Scoreboard extends Component{
  @override
  void render(Canvas c) {

    // 建立一個文字筆刷
    final painter = TextPainter(
        text: TextSpan(
            style: TextStyle(color: Colors.white,fontSize: 16),
            text: score.toString()),
        textScaleFactor: 2,
        textDirection: TextDirection.ltr);

    // layout 文字筆刷
    painter.layout();

    // 找出畫面正上方的起始點
    final position = myGame.size.topCenter(Offset(-painter.width/2,0));
    
    // 使用文字筆刷繪製在正上方
    painter.paint(c,position);
  }

  @override
  void update(double t) {
    //這個元件目前好像不需要 update
  }
}




class Background extends Component {
  @override
  void render(Canvas c) { 

    //背景的尺寸，使用 BaseGame resize 的值
    final backgroundSize = Offset.zero & myGame.size;

    //畫出簡單的純藍色背景
    c.drawRect(backgroundSize, Paint()..color = Colors.blue);
  }

  @override
  void update(double t) {
    // 在這個專案中背景沒有什麼需要更新的
  }
}

