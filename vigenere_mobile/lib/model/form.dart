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
