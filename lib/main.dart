import 'package:flutter/material.dart';
import 'userpage.dart';
import 'homepage.dart';

void main() => runApp(new MyApp());

var gToken = "";

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "MyApp",
      home: new HomePage(),
      routes: <String, WidgetBuilder> {
        '/entitypage': (BuildContext context) => new EntityPage(),
        '/relationpage': (BuildContext context) => new RelationPage()
      },
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  var userPage = new UserPage();
  var mainPage = new MainPage();

  _onTapHandler (int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final _children = new IndexedStack(
      children: <Widget>[
        mainPage,
        userPage
      ],
      index: _currentIndex,
    );
    return new Scaffold(
      body: _children,
      bottomNavigationBar: new BottomNavigationBar(
        onTap: _onTapHandler,
        currentIndex: _currentIndex,
        items: [
          new BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text("Home"),
          ),
          new BottomNavigationBarItem(
            icon: Icon(Icons.person),
            title: Text("Profile"),
          )
        ],
      ),
    );
  }
}


