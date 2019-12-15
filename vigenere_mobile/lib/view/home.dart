import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:vigenere_mobile/model/baseurl.dart';
import 'dart:convert';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String user = '';
  String send = '';
  String inbox = '';
  getPref() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (this.mounted) {
      setState(() {
        user = sharedPreferences.getString("username");
      });
    }
  }

  Future<void> _getData() async {
    final response = await http.post(Baseurl.getData, body: {"user": user});
    var data = jsonDecode(response.body);
    setState(() {
      send = data['send'].toString();
      inbox = data['inbox'].toString();
    });
  }

  @override
  void initState() {
    Future(() async {
      await getPref();
      _getData();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      child: Column(
        children: <Widget>[
          Flexible(
            flex: 4,
            child: GridView.count(
              crossAxisCount: 2,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    color: Colors.yellow[200],
                    child: Container(
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Image.asset(
                              'assets/padlock.png',
                              width: 56.0,
                              height: 56.0,
                            ),
                          ),
                          Text(
                            send,
                            style: TextStyle(fontSize: 24.0),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    color: Colors.yellow[200],
                    child: Container(
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Image.asset(
                              'assets/locked.png',
                              width: 48.0,
                              height: 56.0,
                            ),
                          ),
                          Text(
                            inbox,
                            style: TextStyle(fontSize: 24.0),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    ));
  }
}
