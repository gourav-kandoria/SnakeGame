import 'package:flutter/material.dart';
import 'package:random_color/random_color.dart';

class Screen2 extends StatelessWidget {
  Widget createhListView(double width) {
    List<Widget> temp = [];
    for (var i = 0; i < 15; i++) {
      temp.add(Container(
          width: width,
          child: Center(
            child: MyButton(i),
          )));
    }
    return ListView(
      scrollDirection: Axis.horizontal,
      children: temp,
    );
  }

  Widget createvListView({double height, double width}) {
    List<Widget> temp = [];
    for (var i = 0; i < 20; i++) {
      temp.add(Container(
        height: height / 6,
        child: createhListView(width / 4),
      ));
    }
    return ListView(
      children: temp,
    );
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    double p = MediaQuery.of(context).padding.top;
    return Scaffold(
      body: SafeArea(
        child: createvListView(height: h - p, width: w),
      ),
    );
  }
}

class MyButton extends StatefulWidget {
  final num;
  MyButton(this.num, {Key key}) : super(key: key);

  @override
  MyButtonState createState() => MyButtonState(num);
}

class MyButtonState extends State<MyButton>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final int num;
  Color color;
  double width;
  bool longPress;
  bool doublePress;

  AnimationController _controller0;
  AnimationController _controller;

  var modifyTween;
  var rotateTween;
  var colorTween;

  MyButtonState(this.num);

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    color = RandomColor().randomColor();
    width = 95;
    longPress = false;
    doublePress = false;

    _controller0 = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );

    modifyTween = Tween<double>(
      begin: 95,
      end: 50,
    ).animate(
        CurvedAnimation(parent: _controller0, curve: Curves.easeInOutBack))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && width == 50)
          longPress == true ? _controller.repeat() : _controller.forward();
      })
      ..addListener(() {
        setState(() {
          width = modifyTween.value;
        });
      });

    createColorAndRotateTween();
  }

  void createColorAndRotateTween() {
    Color beginColor = color;
    Color endColor = beginColor;
    while (endColor == beginColor) {
      endColor = RandomColor().randomColor();
    }

    _controller = AnimationController(
      duration: Duration(milliseconds: 3000),
      vsync: this,
    );

    colorTween =
        ColorTween(begin: beginColor, end: endColor).animate(_controller)
          ..addListener(() {
            setState(() {
              color = colorTween.value;
            });
          });

    rotateTween = Tween<double>(begin: 1.0, end: 4.0).animate(_controller)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller0.reverse().then((value) {
            if (doublePress) _controller0.forward();
          });
          _controller.dispose();
          createColorAndRotateTween();
        }
      });
  }

  Widget build(BuildContext context) {
    super.build(context);

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return GestureDetector(
        onTap: () {
          _controller0.forward();
        },
        onLongPress: () {
          longPress = true;
          _controller0.forward();
        },
        onDoubleTap: () {
          doublePress = true;
          _controller0.forward();
        },
        child: RotationTransition(
          turns: rotateTween,
          child: Container(
            alignment: Alignment.center,
            height: width,
            width: width,
            color: color,
            child: Text(
              '',
              style: TextStyle(color: Colors.black, fontSize: 20),
            ),
          ),
        ),
      );
    });
  }
}
