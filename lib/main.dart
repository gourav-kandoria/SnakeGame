import 'package:flutter/material.dart';
import 'package:tutorial/routes.dart';
import 'package:tutorial/snakegameplay.dart';
import './homepage.dart';
import './z_animation.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      color: Colors.white,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: SnakeGamePlay(
          level: 1,
        ),
      ),
      onGenerateRoute: generateRoute,
    );
  }
}

class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  Widget button;

  Widget createButton() {
    return MaterialButton(
      onPressed: () {
        setState(() {});
      },
      child: Text('Press me'),
    );
  }

  @override
  void initState() {
    super.initState();
    button = createButton();
  }

  @override
  Widget build(BuildContext context) {
    return Center(child: button);
  }
}
