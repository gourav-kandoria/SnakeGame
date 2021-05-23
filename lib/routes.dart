import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tutorial/homepage.dart';
import 'package:tutorial/snakegameplay.dart';

abstract class Routes {
  static const snakegameplay = '/snakegameplay';
  static const homepage = '/homepage';
}


Route<dynamic> generateRoute(RouteSettings settings) {
  if(settings.name == Routes.homepage) {
    return MaterialPageRoute(builder: (BuildContext context) => HomePage());
  }

  if(settings.name == Routes.snakegameplay) {
    Map<String,int> args = settings.arguments;
    return MaterialPageRoute(
            builder: (BuildContext context) => SnakeGamePlay(level:args['level']) 
           );
  }

  else {
    return MaterialPageRoute(
      builder: (context) => Center(child: Text('Unknown Routes'))
    );
  }
}