import 'package:flutter/material.dart';
import 'package:vigenere_mobile/model/sidebar.dart';
import './home.dart' as home;
import './send.dart' as send;
import './inbox.dart' as inbox;
// import 'package:vigenere_mobile/model/util.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with SingleTickerProviderStateMixin {
  TabController controller;

  @override
  void initState() {
    controller = new TabController(vsync: this, length: 3);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Sidebar(),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text("Dashboard"),
        bottom: TabBar(
          controller: controller,
          tabs: <Widget>[
            new Tab(
              icon: new Icon(Icons.home),
              text: "Home",
            ),
            new Tab(
              icon: new Icon(Icons.send),
              text: "Send",
            ),
            new Tab(
              icon: new Icon(Icons.inbox),
              text: "Inbox",
            )
          ],
        ),
      ),
      body: new TabBarView(
        controller: controller,
        children: <Widget>[new home.Home(), new send.Send(), new inbox.Inbox()],
      ),
    );
  }
}
