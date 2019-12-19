import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vigenere_mobile/model/util.dart';

class Sidebar extends StatefulWidget {
  @override
  _SidebarState createState() => _SidebarState();
}

enum LoginStatus { notSignIn, signIn }

class _SidebarState extends State<Sidebar> {
  LoginStatus loginStatus = LoginStatus.notSignIn;
  var util = new Util.initialized();
  String name;
  String email;
  getPref() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      name = sharedPreferences.getString("username");
      email = sharedPreferences.getString("email");
    });
  }

  signOut() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    setState(() {
      util.setUsername('');
      sharedPreferences.setInt("value", null);
      sharedPreferences.setString("username", null);
      sharedPreferences.setString("email", null);
      sharedPreferences.setString("hp", null);
      // sharedPreferences.commit();
      loginStatus = LoginStatus.notSignIn;
      Navigator.pop(context);
      Navigator.pushReplacementNamed(context, '/main');
    });
  }

  @override
  void initState() {
    super.initState();
    getPref();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        child: ListView(
          children: <Widget>[
            new UserAccountsDrawerHeader(
              accountName: Text(
                name ?? "none",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                    color: Colors.black),
              ),
              accountEmail:
                  Text(email ?? "none", style: TextStyle(color: Colors.black)),
              currentAccountPicture: Image.asset("assets/muaz.png"),
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/tech.jpg"), fit: BoxFit.cover)),
            ),
            new SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  ListTile(
                    title: Text("About"),
                    leading: Icon(Icons.info_outline),
                    onLongPress: () {},
                  ),
                  ListTile(
                    title: Text("Logout"),
                    leading: Icon(Icons.exit_to_app),
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            // return object of type Dialog
                            return AlertDialog(
                              title: new Text("Exit"),
                              content: new Text("Do you really want to exit?"),
                              actions: <Widget>[
                                // usually buttons at the bottom of the dialog
                                new FlatButton(
                                  child: new Text("Cancel"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                new FlatButton(
                                  child: new Text("Yes"),
                                  onPressed: signOut,
                                )
                              ],
                            );
                          });
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
