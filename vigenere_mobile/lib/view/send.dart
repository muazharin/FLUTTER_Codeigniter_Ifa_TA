import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vigenere_mobile/model/form.dart';
import 'package:http/http.dart' as http;
import 'package:vigenere_mobile/model/baseurl.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Img;
import 'dart:math' as Math;
import 'package:async/async.dart';
import 'package:vigenere_mobile/model/listkirim.dart';
import 'package:vigenere_mobile/view/photoview.dart';

class Send extends StatefulWidget {
  @override
  _SendState createState() => _SendState();
}

class _SendState extends State<Send> with SingleTickerProviderStateMixin {
  bool isOpened = false;
  AnimationController _animationController;
  Animation<Color> _buttonColor;
  Animation<double> _animateIcon;
  Animation<double> _translateButton;
  Curve _curve = Curves.easeOut;
  double _fabHeight = 56.0;

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
      _getDataKirim();
    });
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500))
          ..addListener(() {
            setState(() {});
          });
    _animateIcon =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _buttonColor = ColorTween(
      begin: Colors.blue,
      end: Colors.red,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.00,
        1.00,
        curve: Curves.linear,
      ),
    ));
    _translateButton = Tween<double>(
      begin: _fabHeight,
      end: -14.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.0,
        0.75,
        curve: _curve,
      ),
    ));
    super.initState();
  }

  var loading = false;
  var notfound = false;
  final listkirim = new List<Listkirim>();
  final GlobalKey<RefreshIndicatorState> _refresh =
      new GlobalKey<RefreshIndicatorState>();
  Future<void> _getDataKirim() async {
    listkirim.clear();
    setState(() {
      loading = true;
      notfound = false;
    });

    final response =
        await http.post(Baseurl.getDataKirim, body: {"pengirim": user});
    if (response.contentLength == 2) {
      setState(() {
        loading = false;
        notfound = true;
      });
    } else {
      final data = jsonDecode(response.body);
      data.forEach((api) {
        final ok = new Listkirim(api['id'], api['penerima'], api['kunci'],
            api['tipe'], api['str'], api['pesan'], api['ket']);
        listkirim.add(ok);
      });
      setState(() {
        loading = false;
        notfound = false;
      });
    }
  }

  final _keySend = new GlobalKey<FormState>();
  final _keyKey = new GlobalKey<FormState>();
  final _keySendB = new GlobalKey<FormState>();
  bool _validateSend = false;
  String to = '', key = '', message = '', txt = '';

  File _image;

  Future getImageGallery() async {
    var imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    int rand = new Math.Random().nextInt(100000);

    Img.Image image = Img.decodeImage(imageFile.readAsBytesSync());
    Img.Image smallerImg = Img.copyResize(image, width: 500);

    var compressImg = new File("$path/image_$rand.jpg")
      ..writeAsBytesSync(Img.encodeJpg(smallerImg, quality: 85));

    setState(() {
      _image = compressImg;
    });
  }

  Future getImageCamera() async {
    var imageFile = await ImagePicker.pickImage(source: ImageSource.camera);
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    int rand = new Math.Random().nextInt(100000);

    Img.Image image = Img.decodeImage(imageFile.readAsBytesSync());
    Img.Image smallerImg = Img.copyResize(image, width: 500);

    var compressImg = new File("$path/image_$rand.jpg")
      ..writeAsBytesSync(Img.encodeJpg(smallerImg, quality: 85));

    setState(() {
      _image = compressImg;
    });
  }

  sendImage() async {
    if (_keySend.currentState.validate()) {
      _keySend.currentState.save();
      try {
        var stream = http.ByteStream(DelegatingStream.typed(_image.openRead()));
        var length = await _image.length();
        var uri = Uri.parse(Baseurl.sendImage);
        var request = http.MultipartRequest("POST", uri);
        request.fields['pengirim'] = user;
        request.fields['penerima'] = to;
        request.fields['kunci'] = key;
        request.fields['pesan'] = message;
        request.fields['ket'] = "belum dibaca";
        request.files.add(http.MultipartFile("image", stream, length,
            filename: path.basename(_image.path)));
        var response = await request.send();
        if (response.contentLength != 2) {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  content: new Text('Upload image successfully'),
                  actions: <Widget>[
                    new FlatButton(
                      child: new Text("Close"),
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          _image = null;
                        });
                        Navigator.pop(context);
                        Navigator.pushReplacementNamed(context, '/dashboard');
                      },
                    ),
                  ],
                );
              });
        } else {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  content: new Text('Upload image failed'),
                  actions: <Widget>[
                    new FlatButton(
                      child: new Text("Close"),
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          _image = null;
                        });
                        Navigator.pop(context);
                        Navigator.pushReplacementNamed(context, '/dashboard');
                      },
                    ),
                  ],
                );
              });
        }
      } catch (e) {
        debugPrint("Error $e");
      }
    }
  }

  dialogContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          padding:
              EdgeInsets.only(top: 16.0, bottom: 16.0, left: 16.0, right: 16.0),
          margin: EdgeInsets.only(top: 10.0, left: 10.0),
          decoration: new BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0,
                    offset: const Offset(0.0, 10.0))
              ]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Flexible(
                child: Column(
                  children: <Widget>[
                    Flexible(
                      flex: 4,
                      child: Form(
                        key: _keySend,
                        autovalidate: _validateSend,
                        child: ListView(
                          children: <Widget>[
                            Center(
                              child: _image == null
                                  ? Container(
                                      height: 150.0,
                                      color: Colors.grey[300],
                                      child: Center(
                                        child: Text("No Image Selected!"),
                                      ),
                                    )
                                  : Image.file(
                                      _image,
                                      height: 150.0,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: RaisedButton(
                                    onPressed: getImageGallery,
                                    child: Icon(Icons.image),
                                  ),
                                ),
                                SizedBox(
                                  width: 5.0,
                                ),
                                Expanded(
                                  child: RaisedButton(
                                    onPressed: getImageCamera,
                                    child: Icon(Icons.camera_alt),
                                  ),
                                )
                              ],
                            ),
                            TextFormField(
                              validator: valTo,
                              onSaved: (String val) {
                                to = val;
                              },
                              decoration: InputDecoration(
                                  labelText: "To",
                                  border: OutlineInputBorder()),
                            ),
                            SizedBox(
                              height: 5.0,
                            ),
                            TextFormField(
                              validator: valKey,
                              onSaved: (String val) {
                                key = val;
                              },
                              decoration: InputDecoration(
                                  labelText: "Key",
                                  border: OutlineInputBorder()),
                            ),
                            SizedBox(
                              height: 5.0,
                            ),
                            TextFormField(
                              validator: valMessage,
                              onSaved: (String val) {
                                message = val;
                              },
                              maxLines: 5,
                              decoration: InputDecoration(
                                  labelText: "Message",
                                  border: OutlineInputBorder()),
                            ),
                            SizedBox(
                              height: 8.0,
                            ),
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
                                    onTap: sendImage,
                                    child: Center(
                                      child: Text(
                                        "Send",
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
                    )
                  ],
                ),
              )
            ],
          ),
        ),
        InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            child: Center(
              child: Text("X"),
            ),
            width: 30.0,
            height: 30.0,
            decoration: new BoxDecoration(
                border: Border.all(width: 1),
                borderRadius: BorderRadius.circular(500.0),
                shape: BoxShape.rectangle,
                color: Colors.white),
          ),
        )
      ],
    );
  }

  sendText() async {
    if (_keySendB.currentState.validate()) {
      _keySendB.currentState.save();
      final res = await http.post(Baseurl.sendText, body: {
        'text': txt,
        'pengirim': user,
        'penerima': to,
        'kunci': key,
        'pesan': message,
        'ket': 'belum dibaca'
      });
      var data = jsonDecode(res.body);
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              // title: new Text('Warning'),
              content: new Text(data['message']),
              actions: <Widget>[
                new FlatButton(
                  child: new Text("Close"),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, '/dashboard');
                  },
                ),
              ],
            );
          });
    }
  }

  dialogContentB(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          padding:
              EdgeInsets.only(top: 16.0, bottom: 16.0, left: 16.0, right: 16.0),
          margin: EdgeInsets.only(top: 10.0, left: 10.0),
          decoration: new BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0,
                    offset: const Offset(0.0, 10.0))
              ]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Flexible(
                child: Column(
                  children: <Widget>[
                    Flexible(
                      flex: 4,
                      child: Form(
                        key: _keySendB,
                        autovalidate: _validateSend,
                        child: ListView(
                          children: <Widget>[
                            TextFormField(
                              validator: valText,
                              onSaved: (String val) {
                                txt = val;
                              },
                              maxLines: 3,
                              decoration: InputDecoration(
                                  labelText: "Text",
                                  border: OutlineInputBorder()),
                            ),
                            SizedBox(
                              height: 5.0,
                            ),
                            TextFormField(
                              validator: valTo,
                              onSaved: (String val) {
                                to = val;
                              },
                              decoration: InputDecoration(
                                  labelText: "To",
                                  border: OutlineInputBorder()),
                            ),
                            SizedBox(
                              height: 5.0,
                            ),
                            TextFormField(
                              validator: valKey,
                              onSaved: (String val) {
                                key = val;
                              },
                              decoration: InputDecoration(
                                  labelText: "Key",
                                  border: OutlineInputBorder()),
                            ),
                            SizedBox(
                              height: 5.0,
                            ),
                            TextFormField(
                              validator: valMessage,
                              onSaved: (String val) {
                                message = val;
                              },
                              maxLines: 5,
                              decoration: InputDecoration(
                                  labelText: "Message",
                                  border: OutlineInputBorder()),
                            ),
                            SizedBox(
                              height: 8.0,
                            ),
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
                                    onTap: sendText,
                                    child: Center(
                                      child: Text(
                                        "Send",
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
                    )
                  ],
                ),
              )
            ],
          ),
        ),
        InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            child: Center(
              child: Text("X"),
            ),
            width: 30.0,
            height: 30.0,
            decoration: new BoxDecoration(
                border: Border.all(width: 1),
                borderRadius: BorderRadius.circular(500.0),
                shape: BoxShape.rectangle,
                color: Colors.white),
          ),
        )
      ],
    );
  }

  @override
  dispose() {
    _animationController.dispose();
    super.dispose();
  }

  animate() {
    if (!isOpened) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    isOpened = !isOpened;
  }

  Widget gambar() {
    return Container(
      child: FloatingActionButton(
        heroTag: "btnGambar",
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0)),
                  elevation: 0.0,
                  backgroundColor: Colors.transparent,
                  child: dialogContent(context),
                );
              });
        },
        tooltip: 'Gambar',
        child: Icon(Icons.image),
      ),
    );
  }

  Widget teks() {
    return Container(
      child: FloatingActionButton(
        heroTag: "btnTeks",
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0)),
                  elevation: 0.0,
                  backgroundColor: Colors.transparent,
                  child: dialogContentB(context),
                );
              });
        },
        tooltip: 'Teks',
        child: Icon(Icons.text_fields),
      ),
    );
  }

  Widget toggle() {
    return Container(
      child: FloatingActionButton(
        backgroundColor: _buttonColor.value,
        onPressed: animate,
        tooltip: 'Toggle',
        child: AnimatedIcon(
          icon: AnimatedIcons.menu_close,
          progress: _animateIcon,
        ),
      ),
    );
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Transform(
            transform: Matrix4.translationValues(
              0.0,
              _translateButton.value * 2.0,
              0.0,
            ),
            child: gambar(),
          ),
          Transform(
            transform: Matrix4.translationValues(
              0.0,
              _translateButton.value,
              0.0,
            ),
            child: teks(),
          ),
          toggle(),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _getDataKirim,
        key: _refresh,
        child: SafeArea(
          child: Container(
            child: loading
                ? Center(child: CircularProgressIndicator())
                : notfound
                    ? Center(child: Text("No Data Found"))
                    : ListView.separated(
                        separatorBuilder: (context, ind) => Divider(
                          color: Colors.black26,
                        ),
                        itemCount: listkirim == null ? 0 : listkirim.length,
                        itemBuilder: (context, i) {
                          final res = listkirim[i];
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
                                final gen = await http.post(Baseurl.gen, body: {
                                  'id': res.id,
                                  'nama': user,
                                  'tipe': res.tipe,
                                  'str': res.str,
                                  'key': pws
                                });
                                var enc = jsonDecode(gen.body);
                                String end = enc['result'];
                                Navigator.pop(context);
                                if (res.tipe == 'img') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => new Photos(end),
                                    ),
                                  );
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
                                                Text(res.penerima),
                                                Text('Key :'),
                                                Text(res.kunci),
                                                Text('Message :'),
                                                Text(res.pesan),
                                                Text('Text :'),
                                                Text(end),
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
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 2.0),
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
                                                            "assets/padlock.png"))),
                                              ),
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(
                                                    res.penerima,
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
                                            // InkWell(
                                            //     onTap: () {
                                            //       print('download');
                                            //     },
                                            //     child: Padding(
                                            //       padding:
                                            //           const EdgeInsets.all(8.0),
                                            //       child:
                                            //           Icon(Icons.file_download),
                                            //     )),
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
                                                                          .deleteSend,
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
                            ),
                          );
                        },
                      ),
          ),
        ),
      ),
    );
  }
}
