import 'dart:async';
import 'dart:convert';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'package:secure_lock/Widgets/wave_animation.dart';
import 'package:secure_lock/home.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms/sms.dart';

class RegisterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final focus = FocusScope.of(context);

    return GestureDetector(
      onTap: () {
        focus.unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        resizeToAvoidBottomInset: false,
        body: Column(
          children: [
            const TopPart(),
            const ValidationPart(),
          ],
        ),
      ),
    );
  }
}

//-----------------------------------------------------------------------------------------------------------------------------------

// this is the  upper part of the UI which contain the NewAccount title title and wave animation.

class TopPart extends StatelessWidget {
  const TopPart({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Stack(
        children: [
          WaveAnimation(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              color: Colors.transparent,
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 100,
                  ),
                  const Text(
                    'New',
                    style: TextStyle(fontSize: 45),
                  ),
                  const Text(
                    'Account',
                    style: TextStyle(fontSize: 45),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//-----------------------------------------------------------------------------------------------------------------------------------
// lower part of the UI that contains the form and all its validations.

class ValidationPart extends StatefulWidget {
  const ValidationPart({
    Key key,
  }) : super(key: key);

  @override
  _ValidationPartState createState() => _ValidationPartState();
}


class _ValidationPartState extends State<ValidationPart> {
    SmsSender sender = new SmsSender();
     SmsMessage message;
    StreamSubscription<SmsMessageState> _stream;

    String mobileNo = '';
  String lockNo = '';
  String partNo = '';
  bool _autoValidate = false;

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // this function is used for validating our form and sending a message to set the user.

    void validateForm()  async{
    bool valid = _formKey.currentState.validate();
    if (valid) {
      _formKey.currentState.save();

      final prefs = await SharedPreferences.getInstance();

      if (mobileNo.isEmpty || lockNo.isEmpty|| partNo.isEmpty) {
        print('no input');
        return;
      } else {

        final String mysMessage='SET_NUM$partNo:+2$mobileNo';

        message = SmsMessage(lockNo, mysMessage);
        sender.sendSms(message);
        _stream=message.onStateChanged.listen(
              (state) {
            if (state == SmsMessageState.Sent) {
              print("SMS is sent!");
            } else if (state == SmsMessageState.Delivered)  {
              print("SMS is delivered!");
              BotToast.showText(
                  text: "done successfully"); //popup a text toast;
              final userData=json.encode({
                'mobileNumber':mobileNo,
                'lockNumber':'+2$lockNo',
                'partNumber':partNo
              });
               prefs.setString('userData', userData);
              print('done');
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => HomePage(),
              ));
            } else if (state == SmsMessageState.Fail) {
              print('fail');
              BotToast.showText(text: "failed");
            }
          },
        );
      }
    }
    else {
      /* in this part we are setting autoValidation to be true if the user first attempt
      contained error.
       */

      setState(() {
        _autoValidate = true;
      });
    }
  }


  /* dispose method is called once this widget is removed form flutter widget tree
  ('in our case when we move from SignUp screen to Home Screen ')

   we override this method in order to cancel the senderStream which track if message is sent and delivered or failed
   */
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    if(_stream!=null){
      _stream.cancel();
    }
    print('disposed');
  }

//-----------------------------------------------------------------------------------------------------------------------------------


  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: RepaintBoundary(
          child: Container(
            child: Form(
              key: _formKey,
              autovalidate: _autoValidate,
              child: KeyboardAvoider(
                autoScroll: true,
                child: Column(
                  children: [
                    TextFormField(
                      validator: (value) => value.isEmpty
                          ? 'please enter your phone number'
                          : null,
                      onSaved: (newValue) => mobileNo = newValue,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(labelText: 'Mobile number'),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      validator: (value) =>
                          value.isEmpty ? 'please enter lock number' : null,
                      onSaved: (newValue) => lockNo = newValue,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(labelText: 'lock number'),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      validator: (value) =>
                          value.isEmpty ? 'please enter part number' : null,
                      onSaved: (newValue) => partNo = newValue,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'part number'),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: Container(
                        decoration: const BoxDecoration(shape: BoxShape.circle),
                        width: double.infinity,
                        height: 40,
                        child: RaisedButton(
                          padding: const EdgeInsets.all(0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(120)),
                          onPressed: validateForm,
                          elevation: 4,
                          child: Center(
                            child: LayoutBuilder(
                              builder: (context, constraints) => Text(
                                'Register',
                                style: TextStyle(
                                    fontSize: constraints.maxHeight * 0.4),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


