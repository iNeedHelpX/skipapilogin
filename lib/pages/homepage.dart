import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Color.fromARGB(255, 169, 148, 199),
      child: Scaffold(
        body: Text("this data"),
      ),
    );
  }
}
