import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:vigenere_mobile/model/form.dart';
import 'package:http/http.dart' as http;
import 'package:vigenere_mobile/model/baseurl.dart';

class Signup extends StatefulWidget {
  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  String username = '', email = '', mobilenum = '', password = '', value = '';
  final _keySignUp = new GlobalKey<FormState>();
  bool _validate = false;
  bool _secureText = true;
  showHide() {
    setState(() {
      _secureText = !_secureText;
    });
  }

  signup() async {
    if (_keySignUp.currentState.validate()) {
      _keySignUp.currentState.save();
      final response = await http.post(Baseurl.signup, body: {
        'username': username,
        'email': email,
        'hp': mobilenum,
        'password': password
      });
      var dataset = jsonDecode(response.body);
      String message = dataset['message'];
      String value = dataset['value'];
      print(message);
      if (value == '1') {
        _keySignUp.currentState.reset();
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(message),
          action: SnackBarAction(
            label: 'Ok',
            textColor: Colors.white,
            onPressed: () {
              _scaffoldKey.currentState.mounted;
            },
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ));
      } else {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(message),
          action: SnackBarAction(
            label: 'Ok',
            textColor: Colors.white,
            onPressed: () {
              _scaffoldKey.currentState.mounted;
            },
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ));
      }
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      // appBar: AppBar(
      //   title: Text('Sign Up'),
      // ),
      body: new SafeArea(
          child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Center(
                child: Padding(
                    padding: EdgeInsets.only(top: 50.0),
                    child: Image.asset(
                      "assets/cryptography.png",
                      height: 100.0,
                    )),
              ),
              SizedBox(
                height: 10,
              ),
              Center(
                  child: Text(
                "SIGN UP",
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              )),
              Expanded(
                child: Container(),
              ),
              Image.asset('assets/image_02.png', color: Colors.grey)
            ],
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 200, 16, 16),
              child: Container(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _keySignUp,
                      autovalidate: _validate,
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            validator: valUser,
                            onSaved: (String val) {
                              username = val;
                            },
                            decoration: InputDecoration(
                                labelText: "Username",
                                border: OutlineInputBorder()),
                          ),
                          SizedBox(height: 8.0),
                          TextFormField(
                            validator: valEmail,
                            onSaved: (String val) {
                              email = val;
                            },
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                                labelText: "Email",
                                border: OutlineInputBorder()),
                          ),
                          SizedBox(height: 4.0),
                          TextFormField(
                            validator: valPhone,
                            onSaved: (String val) {
                              mobilenum = val;
                            },
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                                labelText: "Mobile number",
                                border: OutlineInputBorder()),
                          ),
                          SizedBox(height: 8.0),
                          TextFormField(
                            validator: valPass,
                            onSaved: (String val) {
                              password = val;
                            },
                            obscureText: _secureText,
                            decoration: InputDecoration(
                                suffixIcon: IconButton(
                                  onPressed: showHide,
                                  icon: Icon(_secureText
                                      ? Icons.visibility_off
                                      : Icons.visibility),
                                ),
                                labelText: "Password",
                                border: OutlineInputBorder()),
                          ),
                          SizedBox(height: 8.0),
                          InkWell(
                            child: Container(
                              width: double.infinity,
                              height: 56.0,
                              decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(4.0)),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: signup,
                                  child: Center(
                                    child: Text(
                                      "Create account",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          letterSpacing: 1.0),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      )),
    );
  }
}
