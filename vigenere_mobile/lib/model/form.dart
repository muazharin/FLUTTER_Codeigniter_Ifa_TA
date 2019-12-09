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

String valTo(String value) {
  if (value.length == 0) {
    return "To is Required";
  } else {
    return null;
  }
}

String valKey(String value) {
  if (value.length == 0) {
    return "Key is Required";
  } else {
    return null;
  }
}

String valMessage(String value) {
  if (value.length == 0) {
    return "Message is Required";
  } else {
    return null;
  }
}

String valEmail(String value) {
  String pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regExp = new RegExp(pattern);
  if (value.length == 0) {
    return "Email is Required";
  } else if (!regExp.hasMatch(value)) {
    return "Invalid Email";
  } else {
    return null;
  }
}

String valPhone(String value) {
  String patttern = r'(^[0-9]*$)';
  RegExp regExp = new RegExp(patttern);
  if (value.length == 0) {
    return "Mobile is Required";
  } else if (value.length != 12) {
    return "Mobile number must 12 digits";
  } else if (!regExp.hasMatch(value)) {
    return "Mobile Number must be digits";
  }
  return null;
}
