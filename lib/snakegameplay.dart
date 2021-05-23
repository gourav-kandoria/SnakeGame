import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:swipedetector/swipedetector.dart';
import 'package:tutorial/game_controller.dart';

class SnakeGamePlay extends StatefulWidget {
  final int level;
  SnakeGamePlay({Key key, @required this.level}) : super(key: key);
  @override
  _SnakeGamePlayState createState() => _SnakeGamePlayState();
}

class _SnakeGamePlayState extends State<SnakeGamePlay> {
  int level;
  Widget view;
  bool _initialized;
  GameController gameController;
  _SnakeGamePlayState();
  @override
  initState() {
    super.initState();
    level = widget.level;
    _initialized = false;
  }

  Widget createView(
      {@required countVertical,
      @required countHorizontal,
      @required GameController gameController}) {
    print("entered createView");
    List<Widget> verticalList = [];
    for (var i = 0; i < countVertical; i++) {
      List<Widget> horizontalList = [];
      for (var j = 0; j < countHorizontal; j++) {
        horizontalList.add(Expanded(
          flex: 1,
          child: ScreenUnit(stream: gameController.getStream(i, j)),
        ));
      }
      verticalList.add(Expanded(
          flex: 1,
          child: Row(
            children: horizontalList,
          )));
    }
    return Column(
      children: verticalList,
    );
  }

  // Widget view;
  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    double p = MediaQuery.of(context).padding.top;
    h -= p;
    double removeH = h % 10;
    int countVertical = (h - removeH) ~/ 10;
    double removeW = w % 10;
    int countHorizontal = (w - removeW) ~/ 10;
    //   int countHorizontal = 40;
    //   int countVertical = 40;
    if (!_initialized) {
      _initialized = true;
      gameController = GameController(
          currentLevel: level, x: countVertical, y: countHorizontal);
      gameController.stateListener.listen((value) {
        if (value == GameState.over) {
          value = GameState.over;
          setState(() {});
        }
      });
      gameController.initializeDisplay();
      view = KeyedSubtree(
        key: GlobalKey(),
        child: Scaffold(
          body: SwipeDetector(
            swipeConfiguration: SwipeConfiguration(
              horizontalSwipeMinVelocity: 50,
              horizontalSwipeMaxHeightThreshold: 30,
              verticalSwipeMinVelocity: 50,
              verticalSwipeMaxWidthThreshold: 30,
            ),
            child: SafeArea(
              child: createView(
                countVertical: countVertical,
                countHorizontal: countHorizontal,
                gameController: gameController,
              ),
            ),
            onSwipeUp: () {
              gameController.handleGesture(Direction.up);
            },
            onSwipeDown: () {
              gameController.handleGesture(Direction.down);
            },
            onSwipeLeft: () {
              gameController.handleGesture(Direction.left);
            },
            onSwipeRight: () {
              gameController.handleGesture(Direction.right);
            },
          ),
        ),
      );
    }
    if (gameController.getGameState() == GameState.over) {
      return Stack(
        children: <Widget>[
          view,
          Center(
              child: Container(
            child: Text(
              'Game Over',
              textScaleFactor: 2,
            ),
          )),
        ],
      );
    } else if (gameController.getGameState() == GameState.notStarted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Timer(Duration(seconds: 2), () => gameController.start());
      });
      return view;
    }
    return Center(child: Container(child: Text('error')));
  }
}

class ScreenUnit extends StatefulWidget {
  final Stream<Status> stream;
  ScreenUnit({@required this.stream, Key key}) : super(key: key);

  _ScreenUnitState createState() {
    var stateObject = _ScreenUnitState();
    return stateObject;
  }
}

class _ScreenUnitState extends State<ScreenUnit> {
  Stream<Status> _stream;
  Status _status = Status.open;
  @override
  void initState() {
    super.initState();
    _stream = widget.stream;
    _stream.listen((status) {
      setState(() {
        this._status = status;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    print("i am here\n");
    if (_status == Status.open) {
      return Container(
        color: Colors.white,
      );
    } else if (_status == Status.snake) {
      return Container(
        color: Colors.green,
      );
    } else if (_status == Status.closedWall) {
      return Container(
        color: Colors.black87,
      );
    } else if (_status == Status.openWall) {
      return Container(
        color: Colors.grey.shade100,
      );
    } else {
      return Container(
        color: Colors.pink,
      );
    }
  }
}
