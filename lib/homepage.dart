import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial/routes.dart';
import './globals.dart' as global;

class HomePage extends StatelessWidget {
  HomePage({Key key}) : super(key: key);

  Widget myButton(int level, BuildContext cntxt) {
    return Center(
      child: Container(
        margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
        width: 150,
        height: 48,
        child: MaterialButton(
          color: Colors.teal[300],
          elevation: 20,
          child: Text(
            'Level $level',
            textScaleFactor: 1.2,
          ),
          onPressed: () {
            Navigator.popAndPushNamed(cntxt, Routes.snakegameplay,
                arguments: {'level': level});
          },
        ),
      ),
    );
  }

  Widget createList(int levels, BuildContext cntxt) {
    List<Widget> tempList = [];
    for (int i = 1; i <= (levels + 1); i++) {
      tempList.add(myButton(i, cntxt));
    }
    return ListView(children: tempList);
  }

  Widget build(BuildContext context) {
    int levels = 0;
    Future<SharedPreferences> storageFuture = SharedPreferences.getInstance();
    // Future storageFuture = Future.delayed(Duration(milliseconds: 500),()=>SharedPreferences.getInstance());
    return FutureBuilder(
        future: storageFuture,
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasError) {
            // TODO implement message to user that they
            // couldn't access storeage that's why they are setting you to level 1.
            levels = 0;
          } else if (snapshot.hasData) {
            final SharedPreferences storage = snapshot.data;
            if (storage.containsKey(global.storageKey)) {
              levels = storage.getInt(global.storageKey);
            } else {
              storage.setInt(global.storageKey, 0);
              levels = 0;
            }
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: Container(
                    width: 40, height: 40, child: CircularProgressIndicator()));
          }
          return Column(
            children: <Widget>[
              Expanded(
                  flex: 2,
                  child: Center(
                      child: Text(
                    'Select a level to Play',
                    textScaleFactor: 2.0,
                  ))),
              Expanded(flex: 8, child: createList(levels, context)),
            ],
          );
        });
  }
}
