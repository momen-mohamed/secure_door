import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:secure_lock/register_page.dart';
import './Widgets/wave_animation.dart';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms/sms.dart';
import 'package:bot_toast/bot_toast.dart';

import 'model/user.dart';
import 'notification_plugin.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User user;
  String password = '';
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  SmsSender sender = new SmsSender();
  SmsReceiver receiver;
  SmsMessage message;
  bool _autoValidate = false;

  NotificationPlugin notificationPlugin;
  StreamSubscription<SmsMessage> _receiverStream;
  StreamSubscription<SmsMessageState> _senderStream;

  void closeAllStreams(){
   if(_receiverStream!=null){
     _receiverStream.cancel();
   }
   if(_senderStream!=null){
     _senderStream.cancel();
   }
   print('all streams in homePage closed');
  }


//-----------------------------------------------------------------------------------------------------------------------------------

  /* initState function is the a flutter function which is called when this page appears on the screen

     we override this function to get the user info using shared_preferences plugin ,start the receiver screen

     which listen to the incoming messages, and create out notification object to start triggering once the message is received

   */
  @override
  void initState() {
    // TODO: implement initState
    print('initState');
    getUserAndSetInformation();
    super.initState();
  }

//-----------------------------------------------------------------------------------------------------------------------------------

  // build function is the function called by flutter to build the UI Widgets.
  @override
  Widget build(BuildContext context) {
    final focus = FocusScope.of(context);
    return GestureDetector(
      onTap: () {
        if (focus.hasFocus) {
          focus.unfocus();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        resizeToAvoidBottomPadding: false,
        body: Column(
          children: [
            Expanded(
              child: HomeScreenTitleAndWaveAnimation(closeStreams: closeAllStreams,), // Upper part of the UI
            ),
            myForm() //Lower Part of the UI which consists of the form
          ],
        ),
      ),
    );
  }

//-----------------------------------------------------------------------------------------------------------------------------------


  // this is the second part of the UI which is our form with validations.
  Expanded myForm() {
    return Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                child: Column(
                  children: [
                    Form(
                      key: _formKey,
                      autovalidate: _autoValidate,
                      child: TextFormField(
                        validator: (value) => value.isEmpty
                            ? 'please enter a password'
                            : value.length < 4
                                ? 'number of characters limited to 4'
                                : null,
                        onSaved: (newValue) => password = newValue,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'password',
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    RaisedButton(
                      child: Text('Set Password'),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(120)),
                      onPressed: validateForm,
                    )
                  ],
                ),
              ),
            ),
          );
  }

//-----------------------------------------------------------------------------------------------------------------------------------

  /* this function is used when notification is clicked and we wanted to preform a specific action
  but its not used by us .
   */
  onNotificationClick(String payload) {}

//-----------------------------------------------------------------------------------------------------------------------------------

  /* this function is used to get user from shared preferences , initiate our 
   notificationPlugin class, and creating the receiver object used for listening to messages 
   */
  void getUserAndSetInformation() async {
    print('entering here');
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('userData')) {
      final content = prefs.getString('userData');
      user = User.fromJson(jsonDecode(content));
    }
    notificationPlugin = NotificationPlugin();

    notificationPlugin.setOnNotificationClick(onNotificationClick);

     receiver=SmsReceiver();
     _receiverStream=receiver.onSmsReceived.listen((SmsMessage msg) {
      print('home screen receiver');

      if (msg.address == user.lockNumber) {
        print('SAME NUMBER');
        notificationPlugin.showNotification(
            'Wrong password', 'Three Unauthorized attempts');
      }
    });

  }
//-----------------------------------------------------------------------------------------------------------------------------------


  // this function is used for validating our form and sending a message to set user password
  void validateForm() {
    bool _isValid = _formKey.currentState.validate();
    if (_isValid) {
      _formKey.currentState.save();
      if (password.isEmpty) {
        print('No password entered');
      } else {
        final String myMessage = 'SET_PASS:$password';
        print(myMessage);
        message = SmsMessage(user.lockNumber, myMessage); // creating the message
        sender.sendSms(message); // using SmsSender object to send the message
        _senderStream = message.onStateChanged.listen(
              (state) {
            if (state == SmsMessageState.Sent) {
              print("SMS is sent!");
            } else if (state == SmsMessageState.Delivered) {
              print("SMS is delivered!");
              BotToast.showText(
                  text: "done successfully"); //popup a text toast;
              print('done');
            } else if (state == SmsMessageState.Fail) {
              print('fail');
              BotToast.showText(text: "failed"); //showing as failed Toast to the user
            }
          },
        );
      }
    } else {
      /* in this part we are setting autoValidation to be true if the user first attempt
      contained error.
       */
      setState(() {
        _autoValidate = true;
      });
      return;
    }
  }
}


//-----------------------------------------------------------------------------------------------------------------------------------

// this is the  upper part of the UI which contain the HomeScreen title and the popUPMenu used to logout the user.
class HomeScreenTitleAndWaveAnimation extends StatelessWidget {
  final Function closeStreams;
   HomeScreenTitleAndWaveAnimation({
    Key key,
    @required this.closeStreams
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          const WaveAnimation(), //complex wave animation widget
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                color: Colors.transparent,
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // the PopupMenu used to logout the user.
                    PopupMenuButton<String>(
                      icon: Icon(Icons.menu),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: const Text('Logout'),
                          value: 'logout',
                        )
                      ],
                      onSelected: (value) async {
                        if (value == "logout") {
                          final prefs =
                              await SharedPreferences.getInstance();
                          prefs.remove('userData');
                          closeStreams();

                          Navigator.of(context)
                              .pushReplacement(MaterialPageRoute(
                            builder: (context) => RegisterPage(),
                          ));
                        }
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      'Home Page',
                      style: TextStyle(fontSize: 45),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


