import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vigenere_mobile/model/form.dart';
import 'package:http/http.dart' as http;
import 'package:vigenere_mobile/model/baseurl.dart';
import 'package:vigenere_mobile/view/dashboard.dart';
import 'package:vigenere_mobile/model/util.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ifa TA',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Ifa App'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

enum LoginStatus { notSignIn, signIn }

class _MyHomePageState extends State<MyHomePage> {
  LoginStatus _loginStatus = LoginStatus.notSignIn;
  String _username = '', _password = '';
  final _key = new GlobalKey<FormState>();
  bool _validate = false;
  bool _secureText = true;

  showHide() {
    setState(() {
      _secureText = !_secureText;
    });
  }

  login() async {
    if (_key.currentState.validate()) {
      _key.currentState.save();
      print(_username);
      print(_password);
      final response = await http.post(Baseurl.login,
          body: {'username': _username, 'password': _password});
      var datauser = jsonDecode(response.body);
      int value = datauser[0]['value'];
      String username = datauser[0]['username'];
      String email = datauser[0]['email'];
      String hp = datauser[0]['hp'];
      if (value == 1) {
        setState(() {
          _loginStatus = LoginStatus.signIn;
          savePref(value, username, email, hp);
        });
      } else {
        print(value);
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: new Text("Login"),
              content: new Text("Username atau Password Anda Salah!"),
              actions: <Widget>[
                new FlatButton(
                  child: new Text("Close"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  savePref(int value, String username, String email, String hp) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var util = new Util.initialized();
    setState(() {
      util.setUsername(username);
      sharedPreferences.setInt("value", value);
      sharedPreferences.setString("username", username);
      sharedPreferences.setString("email", email);
      sharedPreferences.setString("hp", hp);
      sharedPreferences.commit();
    });
    print(util.getUsername());
  }

  var value;
  getPref() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      value = sharedPreferences.getInt('value');

      _loginStatus = value == 1 ? LoginStatus.signIn : LoginStatus.notSignIn;
    });
  }

  // signOut() async {
  //   SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  //   setState(() {
  //     Util.user = "";
  //     sharedPreferences.setInt("value", null);
  //     sharedPreferences.setString("username", null);
  //     sharedPreferences.setString("email", null);
  //     sharedPreferences.setString("hp", null);
  //     sharedPreferences.commit();
  //     _loginStatus = LoginStatus.notSignIn;
  //   });
  // }

  @override
  void initState() {
    super.initState();
    getPref();
  }

  @override
  Widget build(BuildContext context) {
    switch (_loginStatus) {
      case LoginStatus.notSignIn:
        return Scaffold(
          resizeToAvoidBottomPadding: false,
          appBar: AppBar(
            title: Text(widget.title),
          ),
          body: SafeArea(
            child: Stack(children: <Widget>[
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(50.0),
                  child: Container(
                    child: SizedBox(
                      height: 270.0,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Form(
                            key: _key,
                            autovalidate: _validate,
                            child: Column(
                              children: <Widget>[
                                // username(_username),
                                // password(_password, _secureText, showHide),
                                TextFormField(
                                    validator: valUser,
                                    onSaved: (String val) {
                                      _username = val;
                                    },
                                    decoration:
                                        InputDecoration(labelText: "Username")),
                                TextFormField(
                                    validator: valPass,
                                    onSaved: (String val) {
                                      return _password = val;
                                    },
                                    obscureText: _secureText,
                                    decoration: InputDecoration(
                                        suffixIcon: IconButton(
                                          onPressed: showHide,
                                          icon: Icon(_secureText
                                              ? Icons.visibility_off
                                              : Icons.visibility),
                                        ),
                                        labelText: "Password")),
                                SizedBox(
                                  height: 20.0,
                                ),
                                InkWell(
                                  child: Container(
                                    width: double.infinity,
                                    height: 30.0,
                                    decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius:
                                            BorderRadius.circular(15.0)),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: login,
                                        child: Center(
                                          child: Text(
                                            "Login",
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
                                SizedBox(
                                  height: 10.0,
                                ),
                                InkWell(
                                  onTap: () {
                                    print("daftar");
                                  },
                                  child: Center(
                                    child: Text(
                                      "Daftar akun baru?",
                                      style: TextStyle(
                                          color: Colors.blue,
                                          fontSize: 15,
                                          letterSpacing: 1.0),
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
                ),
              ),
            ]),
          ),
        );
        break;
      case LoginStatus.signIn:
        return Dashboard();
        break;
      default:
        return Container();
        break;
    }
  }
}
