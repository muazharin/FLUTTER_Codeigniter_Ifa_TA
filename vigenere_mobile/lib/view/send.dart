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
// import 'package:vigenere_mobile/model/util.dart';

class Send extends StatefulWidget {
  @override
  _SendState createState() => _SendState();
}

class _SendState extends State<Send> {
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
        final ok = new Listkirim(api['penerima'], api['kunci'], api['foto'],
            api['pesan'], api['ket']);
        listkirim.add(ok);
      });
      setState(() {
        loading = false;
        notfound = false;
      });
    }
  }

  final _keySend = new GlobalKey<FormState>();
  bool _validateSend = false;
  String to = '', key = '', message = '';

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
        print(response.toString());
        if (response.statusCode > 2) {
          print("Upload image successfully");
        } else {
          print("Upload image failed");
        }
        setState(() {
          _image = null;
          Navigator.pop(context);
        });
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
                              height: 20.0,
                            ),
                            InkWell(
                              child: Container(
                                width: double.infinity,
                                height: 30.0,
                                decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(15.0)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
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
        tooltip: "Image",
        child: Icon(Icons.add),
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
                          return Container(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 2.0),
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
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Container(
                                                width: 50.0,
                                                height: 50.0,
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.rectangle,
                                                    image: new DecorationImage(
                                                        fit: BoxFit.cover,
                                                        image: new NetworkImage(
                                                            Baseurl.ip +
                                                                '/ifa_ta/assets/file_kirim/' +
                                                                res.foto))),
                                              ),
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(res.penerima),
                                                  Text(res.ket)
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
