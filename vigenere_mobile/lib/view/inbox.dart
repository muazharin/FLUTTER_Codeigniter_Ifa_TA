import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vigenere_mobile/model/baseurl.dart';
import 'package:vigenere_mobile/model/listinbox.dart';

class Inbox extends StatefulWidget {
  @override
  _InboxState createState() => _InboxState();
}

class _InboxState extends State<Inbox> {
  String user = '';
  getPref() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (this.mounted) {
      setState(() {
        user = sharedPreferences.getString("username");
      });
    }
  }

  @override
  void initState() {
    Future(() async {
      await getPref();
      _getDataInbox();
    });
    super.initState();
  }

  var loading = false;
  var notfound = false;
  final listinbox = new List<Listinbox>();
  final GlobalKey<RefreshIndicatorState> _refresh =
      new GlobalKey<RefreshIndicatorState>();
  Future<void> _getDataInbox() async {
    listinbox.clear();
    setState(() {
      loading = true;
      notfound = false;
    });

    final response =
        await http.post(Baseurl.getDataInbox, body: {"penerima": user});
    if (response.contentLength == 2) {
      setState(() {
        loading = false;
        notfound = true;
      });
    } else {
      final data = jsonDecode(response.body);
      data.forEach((api) {
        final ok = new Listinbox(api['pengirim'], api['kunci'], api['foto'],
            api['pesan'], api['ket']);
        listinbox.add(ok);
      });
      setState(() {
        loading = false;
        notfound = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: RefreshIndicator(
      onRefresh: _getDataInbox,
      key: _refresh,
      child: SafeArea(
        child: Container(
          child: loading
              ? Center(child: CircularProgressIndicator())
              : notfound
                  ? Center(child: Text("No Data Found!"))
                  : ListView.separated(
                      separatorBuilder: (context, ind) => Divider(
                        color: Colors.black26,
                      ),
                      itemCount: listinbox == null ? 0 : listinbox.length,
                      itemBuilder: (context, i) {
                        final res = listinbox[i];
                        return Container(
                          child: Column(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: InkWell(
                                  onTap: () {},
                                  child: Container(
                                    child: Row(
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            width: 35.0,
                                            height: 35.0,
                                            decoration: BoxDecoration(
                                                shape: BoxShape.rectangle,
                                                image: new DecorationImage(
                                                    fit: BoxFit.cover,
                                                    image: AssetImage(
                                                        "assets/locked.png"))),
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                res.pengirim,
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(res.kunci + ' | ' + res.ket),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    ),
        ),
      ),
    ));
  }
}
