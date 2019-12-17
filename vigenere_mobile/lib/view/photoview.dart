import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:vigenere_mobile/model/baseurl.dart';

class Photos extends StatelessWidget {
  final String end;
  Photos(this.end);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: PhotoView(
        imageProvider:
            NetworkImage(Baseurl.ip + '/ifa_ta/assets/file_dec/' + end),
      ),
    );
  }
}
