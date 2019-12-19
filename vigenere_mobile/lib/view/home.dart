import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:vigenere_mobile/model/baseurl.dart';
import 'dart:convert';
import 'package:carousel_pro/carousel_pro.dart';

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

  Future<List> _getRecent() async {
    final source = await http.post(Baseurl.getRecent, body: {"user": user});
    var data = json.decode(source.body);
    return data;
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
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Carousel(
                boxFit: BoxFit.cover,
                autoplay: true,
                animationCurve: Curves.fastOutSlowIn,
                animationDuration: Duration(milliseconds: 1500),
                dotSize: 4.0,
                showIndicator: true,
                indicatorBgPadding: 7.0,
                // dotIncreasedColor: Color(0xFFFF335C),
                dotBgColor: Colors.transparent,
                dotVerticalPadding: 4.0,
                // dotPosition: DotPosition.topRight,
                images: [
                  NetworkImage(
                      'https://www.plixer.com/wp-content/uploads/2018/12/quantum-cryptography.jpg'),
                  NetworkImage(
                      'https://www.nist.gov/sites/default/files/images/2018/04/09/18itl003_lightweight_2_cryptography.png'),
                  NetworkImage(
                      'https://www.ie.edu/insights/wp-content/uploads/2017/05/Prueba-y-aprendizaje-transformacion-cultural-en-la-era-digital.jpg'),
                  NetworkImage(
                      'https://www.cloudmanagementinsider.com/wp-content/uploads/2019/10/cloud-cryptography.jpg'),
                  NetworkImage(
                      'https://cdn.i-scmp.com/sites/default/files/styles/1200x800/public/d8/images/methode/2019/10/27/2fdbd224-f8a6-11e9-87ad-fce8e65242a6_image_hires_185343.JPG?itok=wpwtDjlB&v=1572173629')
                ],
              ),
            ),
          ),
          Flexible(
            flex: 1,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: <Widget>[
                            // Image.asset('assets/padlock.png',
                            //     width: 40.0, height: 40.0),
                            Icon(Icons.send),
                            SizedBox(
                              width: 50.0,
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
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.inbox),
                            SizedBox(
                              width: 50.0,
                            ),
                            Text(
                              inbox,
                              style: TextStyle(fontSize: 24.0),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Recent :',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0))
              ],
            ),
          )),
          Flexible(
            flex: 3,
            child: FutureBuilder<List>(
              future: _getRecent(),
              builder: (context, snapshot) {
                if (snapshot.hasError) print(snapshot.error);
                return Center(
                  child: snapshot.hasData
                      ? new ItemList(
                          list: snapshot.data,
                        )
                      : new Center(
                          child: new CircularProgressIndicator(),
                        ),
                );
              },
            ),
          )
        ],
      ),
    ));
  }
}

class ItemList extends StatelessWidget {
  final List list;
  ItemList({this.list});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Container(
        child: Card(
          child: new ListView.separated(
            separatorBuilder: (context, ind) => Divider(
              color: Colors.black26,
            ),
            itemCount: list == null ? 0 : list.length,
            itemBuilder: (context, i) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    child: Center(
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(child: Text(list[i]['pengirim'])),
                              Expanded(child: Text('|')),
                              Expanded(child: Text(list[i]['penerima'])),
                              Expanded(child: Text('|')),
                              Expanded(child: Text(list[i]['tipe'])),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
