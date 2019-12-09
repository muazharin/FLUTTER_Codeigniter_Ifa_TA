class Util {
  String username;

  Util(this.username);
  Util.initialized() {
    this.username = '';
  }

  String getUsername() => this.username;
  void setUsername(String value) => username = value;
}
