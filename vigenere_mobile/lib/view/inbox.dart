import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vigenere_mobile/model/baseurl.dart';
import 'package:vigenere_mobile/model/form.dart';
import 'package:vigenere_mobile/model/listinbox.dart';
import 'package:vigenere_mobile/view/photoview.dart';

class Inbox extends StatefulWidget {
  @override
  _InboxState createState() => _InboxState();
}

class _InboxState extends State<Inbox> {
  var waktu = 0;
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
        final ok = new Listinbox(api['id'], api['pengirim'], api['kunci'],
            api['tipe'], api['str'], api['pesan'], api['ket']);
        listinbox.add(ok);
      });
      setState(() {
        loading = false;
        notfound = false;
      });
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _keyKey = new GlobalKey<FormState>();
  bool _validateSend = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
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
                            String pws = '';
                            void generateKey() async {
                              if (_keyKey.currentState.validate()) {
                                _keyKey.currentState.save();
                                if (pws != res.kunci) {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: new Text('Warning'),
                                          content: new Text('Incorrect Key'),
                                          actions: <Widget>[
                                            new FlatButton(
                                              child: new Text("Close"),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ],
                                        );
                                      });
                                } else {
                                  var tStart = new Stopwatch()..start();
                                  final gen = await http.post(Baseurl.gen,
                                      body: {
                                        'id': res.id,
                                        'nama': user,
                                        'tipe': res.tipe,
                                        'str': res.str,
                                        'key': pws
                                      });
                                  var enc = jsonDecode(gen.body);
                                  waktu = tStart.elapsedMilliseconds;
                                  String end = enc['result'];
                                  Navigator.pop(context);
                                  if (res.tipe == 'img') {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Detail'),
                                            content: SingleChildScrollView(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  Expanded(
                                                    child: RaisedButton(
                                                      child: Text(
                                                          'Show The Picture'),
                                                      onPressed: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    new Photos(
                                                                        end),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                  Text('\nTo :'),
                                                  Text('\t' + res.pengirim),
                                                  Text('\nKey :'),
                                                  Text('\t' + res.kunci),
                                                  Text('\nMessage :'),
                                                  Text('\t' + res.pesan),
                                                  Text('\nTime execution :'),
                                                  Text('\t $waktu ms'),
                                                ],
                                              ),
                                            ),
                                            actions: <Widget>[
                                              new FlatButton(
                                                child: new Text("Close"),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            ],
                                          );
                                        });
                                  } else if (res.tipe == 'text') {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Detail'),
                                            content: SingleChildScrollView(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  Text('To :'),
                                                  Text('\t' + res.pengirim),
                                                  Text('\nKey :'),
                                                  Text('\t' + res.kunci),
                                                  Text('\nMessage :'),
                                                  Text('\t' + res.pesan),
                                                  Text('\nText :'),
                                                  Text('\t' + end),
                                                  Text('\nTime execution :'),
                                                  Text('\t $waktu ms'),
                                                ],
                                              ),
                                            ),
                                            actions: <Widget>[
                                              new FlatButton(
                                                child: new Text("Close"),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            ],
                                          );
                                        });
                                  }
                                }
                              }
                            }

                            return Container(
                              child: Column(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: InkWell(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: new Text("Detail"),
                                              content: new Form(
                                                key: _keyKey,
                                                autovalidate: _validateSend,
                                                child: SingleChildScrollView(
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: <Widget>[
                                                      TextFormField(
                                                        validator: valKey,
                                                        onSaved: (String val) {
                                                          pws = val;
                                                        },
                                                        decoration: InputDecoration(
                                                            labelText: "Key",
                                                            border:
                                                                OutlineInputBorder()),
                                                      ),
                                                      SizedBox(
                                                        height: 8.0,
                                                      ),
                                                      InkWell(
                                                        child: Container(
                                                          width:
                                                              double.infinity,
                                                          height: 56.0,
                                                          decoration: BoxDecoration(
                                                              color:
                                                                  Colors.blue,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          4.0)),
                                                          child: Material(
                                                            color: Colors
                                                                .transparent,
                                                            child: InkWell(
                                                              onTap:
                                                                  generateKey,
                                                              child: Center(
                                                                child: Text(
                                                                  "Generate",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          15,
                                                                      letterSpacing:
                                                                          1.0),
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
                                              actions: <Widget>[
                                                new FlatButton(
                                                  child: new Text("Close"),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      child: Container(
                                        child: Row(
                                          children: <Widget>[
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
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
                                                  Text(res.tipe +
                                                      ' | ' +
                                                      res.kunci),
                                                ],
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return AlertDialog(
                                                        title: Text('Delete'),
                                                        content: new Text(
                                                            'Do you want to delete this data?'),
                                                        actions: <Widget>[
                                                          new FlatButton(
                                                            child: new Text(
                                                                "Cancel"),
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                          ),
                                                          new FlatButton(
                                                            child:
                                                                new Text("Yes"),
                                                            onPressed:
                                                                () async {
                                                              Navigator.pop(
                                                                  context);
                                                              final source =
                                                                  await http.post(
                                                                      Baseurl
                                                                          .deleteInbox,
                                                                      body: {
                                                                    'id_send':
                                                                        res.id
                                                                  });
                                                              var resSend =
                                                                  jsonDecode(
                                                                      source
                                                                          .body);
                                                              String varSend =
                                                                  resSend[
                                                                      'result'];
                                                              _scaffoldKey
                                                                  .currentState
                                                                  .showSnackBar(
                                                                      SnackBar(
                                                                content: Text(
                                                                    varSend),
                                                                action:
                                                                    SnackBarAction(
                                                                  label: 'Ok',
                                                                  textColor:
                                                                      Colors
                                                                          .white,
                                                                  onPressed:
                                                                      () {
                                                                    _scaffoldKey
                                                                        .currentState
                                                                        .mounted;
                                                                  },
                                                                ),
                                                                backgroundColor:
                                                                    Colors
                                                                        .green,
                                                                duration:
                                                                    Duration(
                                                                        seconds:
                                                                            3),
                                                              ));
                                                            },
                                                          ),
                                                        ],
                                                      );
                                                    });
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child:
                                                    Icon(Icons.delete_outline),
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
