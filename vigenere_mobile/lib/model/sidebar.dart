import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:vigenere_mobile/model/util.dart';

class Sidebar extends StatefulWidget {
  @override
  _SidebarState createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  String name;
  String email;
  getPref() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      name = sharedPreferences.getString("username");
      email = sharedPreferences.getString("email");
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
                    title: Text("Color"),
                    leading: Icon(Icons.color_lens),
                    onLongPress: () {},
                  ),
                  ListTile(
                    title: Text("About"),
                    leading: Icon(Icons.info_outline),
                    onLongPress: () {},
                  ),
                  ListTile(
                    title: Text("Logout"),
                    leading: Icon(Icons.exit_to_app),
                    onLongPress: () {},
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