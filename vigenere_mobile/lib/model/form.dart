// import 'package:flutter/material.dart';

String valUser(String value) {
  if (value.length == 0) {
    return "Username is Required";
  } else {
    return null;
  }
}

String valPass(String value) {
  if (value.length == 0) {
    return "Password is Required";
  } else if (value.length < 6) {
    return "Password is at least 6 characters";
  }
  return null;
}

// Widget username(String _username) {
//   return TextFormField(
//       validator: valUser,
//       onSaved: (String val) {
//         return _username = val;
//       },
//       decoration: InputDecoration(labelText: "Username"));
// }

// Widget password(String _password, _secureText, showHide) {
//   return TextFormField(
//       validator: valPass,
//       onSaved: (String val) {
//         return _password = val;
//       },
//       obscureText: _secureText,
//       decoration: InputDecoration(
//           suffixIcon: IconButton(
//             onPressed: showHide,
//             icon: Icon(_secureText ? Icons.visibility_off : Icons.visibility),
//           ),
//           labelText: "Password"));
// }
