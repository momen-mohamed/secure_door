import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';

import 'package:secure_lock/home.dart';
import 'package:secure_lock/lifecycle_manager.dart';
import 'package:secure_lock/register_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

//-----------------------------------------------------------------------------------------------------------------------------------

// main function is the start point of flutter application
void main() {
  runApp(MyApp());
}
//-----------------------------------------------------------------------------------------------------------------------------------

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // object created from LieCycleManager class to track the lifecycle of the application
    return LifeCycleManager(

    child: MaterialApp(
        builder: BotToastInit(),
        navigatorObservers: [BotToastNavigatorObserver()],
        title: 'Flutter Demo',

//-----------------------------------------------------------------------------------------------------------------------------------
        // setting the colors and theme of the app
        theme: ThemeData(
            backgroundColor: Color(0xff363A46),
            scaffoldBackgroundColor: Color(0xff363A46),
            brightness: Brightness.dark,
            primarySwatch: Colors.orange,
            accentColor: Color(0xffF7AC1B),
            visualDensity: VisualDensity.adaptivePlatformDensity,
            buttonTheme: ButtonThemeData(
              buttonColor: Color(0xffF7AC1B).withOpacity(0.96),
            )),
//-----------------------------------------------------------------------------------------------------------------------------------

        // determine if the user is Registered or not in order to redirect the user to the correct screen.
        home: FutureBuilder<SharedPreferences>(
          future: SharedPreferences.getInstance(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(body: Center(child: CircularProgressIndicator()));
            } else {
              return snapshot.data.containsKey('userData')
                  ? HomePage()
                  : RegisterPage();
            }
          },
        ),
      ),
    );
  }

}
