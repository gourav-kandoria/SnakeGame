import 'dart:async';
import 'dart:collection';
import 'dart:core';
import "package:flutter/foundation.dart";
import 'package:shared_preferences/shared_preferences.dart';
import './globals.dart' as global;

class Point {
  int x;
  int y;
  Point(this.x, this.y);
  @override
  String toString() {
    return '{x: $x, y: $y}';
  }
}

enum Status { open, closedWall, openWall, food, snake }

enum Direction { up, down, left, right }

enum GameState { voide, notStarted, active, paused, over }

int getSpeed(int level) {
  return 100000;
}

Map<int, int> levelToLength = {
  1: 10,
  2: 15,
  3: 20,
  4: 20,
  5: 25,
};

class GameController {
  final int x;
  final int y;

  int _currentLevel;
  SharedPreferences _storage;
  GameState _gameState = GameState.voide;
  bool _pauseRequest = false;
  Direction _currentDirection;
  Direction _futureDirection;

  List<List<StreamController<Status>>> _streamMatrix;
  List<List<Status>> _statusMatrix;

  List<Point> _snake = [];
  Queue<Direction> _moves = Queue();

  // ignore: close_sinks
  StreamController<GameState> _stateStream;
  Stream<GameState> stateListener;

  Stream<Status> getStream(int x, int y) {
    return _streamMatrix[x][y].stream;
  }

  void _intializeStatusandStream() {
    _stateStream = StreamController<GameState>();
    stateListener = _stateStream.stream;

    _streamMatrix = [];
    _statusMatrix = [];

    for (var i = 0; i < x; i++) {
      _statusMatrix.add([]);
      _streamMatrix.add([]);
      for (var j = 0; j < y; j++) {
        _statusMatrix[i].add(Status.open);
        _streamMatrix[i].add(StreamController<Status>());
      }
    }
  }

  GameController(
      {@required currentLevel,
      @required this.x,
      @required this.y,
      /*@required*/ storage}) {
    _currentLevel = currentLevel;
    _storage = storage;
    _intializeStatusandStream();
    _gameState = GameState.voide;
  }

  // trasition 1, 5, 7
  GameState getGameState() {
    return _gameState;
  }

  bool initializeDisplay() {
    if (_gameState != GameState.voide &&
        _gameState != GameState.paused &&
        _gameState != GameState.over) return false;
    renderLayout();
    changeState(GameState.notStarted);
    return true;
  }

  // transition 2
  bool start() {
    if (_gameState != GameState.notStarted) return false;
    _currentDirection = Direction.up;
    Timer(Duration(microseconds: getSpeed(_currentLevel)), _intervalFunction);
    changeState(GameState.active);
    return true;
  }

  // transition 3
  bool pause() {
    if (_gameState != GameState.active) return false;
    _pauseRequest = true;
    while (_gameState != GameState.paused) {}
    _pauseRequest = false;
    return true;
  }

  // transition 4
  bool resume() {
    if (_gameState != GameState.paused) return false;
    Timer(Duration(microseconds: getSpeed(_currentLevel)), _intervalFunction);
    changeState(GameState.active);
    return true;
  }

  // used in the function initializeDisplay
  void renderLayout() {
    for (var i = 1; i < (x - 1); i++) {
      for (var j = 1; j < (y - 1); j++) {
        _statusMatrix[i][j] = Status.open;
        _streamMatrix[i][j].sink.add(Status.open);
      }
    }
    if (_currentLevel == 1) {
      for (var j = 0; j < y; j++) {
        _statusMatrix[0][j] = Status.closedWall;
        _streamMatrix[0][j].sink.add(Status.closedWall);
        _statusMatrix[x - 1][j] = Status.closedWall;
        _streamMatrix[x - 1][j].sink.add(Status.closedWall);
      }
      for (var i = 1; i < (x - 1); i++) {
        _statusMatrix[i][0] = Status.closedWall;
        _streamMatrix[i][0].sink.add(Status.closedWall);
        _statusMatrix[i][y - 1] = Status.closedWall;
        _streamMatrix[i][y - 1].sink.add(Status.closedWall);
      }
    }
    var tempY = y ~/ 2;
    // adding snake and changing status matrix
    _snake.add(Point(x - 4, tempY));
    _statusMatrix[x - 4][tempY] = Status.snake;
    _snake.add(Point(x - 3, tempY));
    _statusMatrix[x - 2][tempY] = Status.snake;
    _snake.add(Point(x - 2, tempY));
    _statusMatrix[x - 2][tempY] = Status.snake;
    // adding statuses to the sinks
    _streamMatrix[x - 4][tempY].sink.add(Status.snake);
    _streamMatrix[x - 3][tempY].sink.add(Status.snake);
    _streamMatrix[x - 2][tempY].sink.add(Status.snake);
  }

  void _intervalFunction() {
    Point head = _snake.first;
    Point tail = _snake.last;
    if (_pauseRequest == true) {
      changeState(GameState.paused);
      return;
    }

    if (_moves.isEmpty)
      _futureDirection = _currentDirection;
    else
      _futureDirection = _moves.removeFirst();

    Point futureHead = getFutureHead(head, _futureDirection);
    final Status futureState = _statusMatrix[futureHead.x][futureHead.y];
    if (futureState == Status.closedWall || futureState == Status.snake) {
      changeState(GameState.over);
      print("game is over");
      return;
    } else {
      if (futureState == Status.openWall) {
        futureHead = _circulateIt(futureHead);
      }
      _statusMatrix[futureHead.x][futureHead.y] = Status.snake;
      _streamMatrix[futureHead.x][futureHead.y].sink.add(Status.snake);
      _snake.insert(0, futureHead);

      bool lengthChanged = true;
      if (futureState != Status.food) {
        _statusMatrix[tail.x][tail.y] = Status.open;
        _streamMatrix[tail.x][tail.y].sink.add(Status.open);
        _snake.removeLast();
        lengthChanged = false;
      }
      if (lengthChanged) {
        if (_snake.length == levelToLength[_currentLevel] + 1) {
          _storage.setInt(global.storageKey, _currentLevel + 1);
        }
      }
    }

    _currentDirection = _futureDirection;
    Timer(Duration(microseconds: getSpeed(_currentLevel)), _intervalFunction);
  }

  Point getFutureHead(Point h, Direction d) {
    if (d == Direction.up) {
      return Point(h.x - 1, h.y);
    } else if (d == Direction.right) {
      return Point(h.x, h.y + 1);
    } else if (d == Direction.left) {
      return Point(h.x, h.y - 1);
    } else {
      // d == Direction.down
      return Point(h.x + 1, h.y);
    }
  }

  Point _circulateIt(Point p) {
    if (p.y == 0)
      return Point(p.x, y - 2);
    else if (p.y == y - 1)
      return Point(p.x, 1);
    else if (p.x == 0)
      return Point(x - 2, p.y);
    else //(p.x == x-1)
      return Point(1, p.y);
  }

  void changeState(GameState gameState) {
    _gameState = gameState;
    _stateStream.sink.add(_gameState);
  }

  void handleGesture(Direction direction) {
    _moves.add(direction);
  }

  void closeSinks() {
    _stateStream.sink.close();
    for (var i = 0; i < x; i++) {
      for (var j = 0; j < y; j++) {
        _streamMatrix[i][j].sink.close();
      }
    }
  }
}
