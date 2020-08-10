
import 'package:flutter/material.dart';

//-----------------------------------------------------------------------------------------------------------------------------------


/* this class is created to track the life cycle of the application

  lifeCycle state of the application are:
  inactive:: called when something appears over the application such as permission AlertDialog.
  paused:: called when we exit the app but keep it running in the background.
  resumed:: called when the user return back to the application.
  detached:: called when the application is killed either by the user or the OS.

 */
//-----------------------------------------------------------------------------------------------------------------------------------


class LifeCycleManager extends StatefulWidget {
  final Widget child;

  LifeCycleManager({this.child});

  @override
  _LifeCycleManagerState createState() => _LifeCycleManagerState();
}

class _LifeCycleManagerState extends State<LifeCycleManager>
    with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {

    super.didChangeAppLifecycleState(state);
    print('lifeCycleState = $state');

    switch (state) {
      case AppLifecycleState.resumed:
        print(state);
        break;
      case AppLifecycleState.inactive:
        print(state);
        break;
      case AppLifecycleState.paused:
        print(state);
        break;
      case AppLifecycleState.detached:
        print(state);
        break;
    }
  }
}
