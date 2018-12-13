import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

import 'main.dart';


class UserPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _UserPageState();
  }
}

class _UserPageState extends State<UserPage> {
  @override
  Widget build(BuildContext context) {
    return new LoginPage();
  }
}

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> with AutomaticKeepAliveClientMixin {
  @protected
  bool get wantKeepAlive => true;

  var isLoggedIn = false;
  var token = '';
  var msg = '';
  _loginPost (data) async {
    var host = '10.15.82.223:9090';
    var path = '/app_get_data/app_signincheck';

    var result = "";
    try {
      var httpClient = HttpClient();
      var uri = new Uri.http(host, path, data);
      var request = await httpClient.postUrl(uri);
      var response = await request.close();
      if (response.statusCode == HttpStatus.ok) {
        var jsondata = await response.transform(utf8.decoder).join();
        var data = json.decode(jsondata);
        if (data['msg'] == "登录成功") {
          setState(() {
            isLoggedIn = true;
            token = data['token'];
            gToken = token;
          });
        } else {
          result = "登录失败";
        }
      } else {
        result = 'Http error: ${response.statusCode}';
      }
    } catch(exception) {
      result = 'Failed to post: ${exception.toString()}';
    }
    setState(() {
      msg = result;
    });
  }

  _logoutPost(token) async {
    var result;
    var host = '10.15.82.223:9090';
    var path = '/app_get_data/app_logout';
    try {
      var httpClient = HttpClient();
      var uri = new Uri.http(host, path, {"token": token});
      var request = await httpClient.postUrl(uri);
      var response = await request.close();
      if (response.statusCode == HttpStatus.ok) {
        var jsondata = await response.transform(utf8.decoder).join();
        var data = json.decode(jsondata);
        setState(() {
          isLoggedIn = false;
        });
        result = data['msg'];
      }
    } catch(exception) {
      result = 'Failed to post ${exception.toString()}';
    }
    msg = result;
    gToken = "";
  }
  final usernameCtrl = new TextEditingController();
  final passwordCtrl = new TextEditingController();
  

  @override
  Widget build(BuildContext context) {
    var page;
    if (isLoggedIn == false) {
      page = new Scaffold(
        appBar: new AppBar(
          title: Text("Login"),
        ),
        body: Center(
          child: SizedBox(
            width: 320.0,
            child: Column(
              children: <Widget>[
                new SizedBox(
                  height: 180.0,
                ),
                new TextFormField(
                  controller: usernameCtrl,
                  decoration: InputDecoration(
                      icon: Icon(Icons.person),
                      hintText: "Username"
                  ),
                  textInputAction: TextInputAction.next,
                ),
                new SizedBox(
                  height: 80.0,
                ),
                new TextFormField(
                  obscureText: true,
                  controller: passwordCtrl,
                  decoration: InputDecoration(
                      icon: Icon(Icons.lock),
                      hintText: "Password"
                  ),
                  textInputAction: TextInputAction.done,
                ),
                new SizedBox(
                  height: 80,
                ),
                new SizedBox(
                  child: new RaisedButton(
                    child: Text("Login"),
                    onPressed: () { _loginPost({'username': usernameCtrl.text, 'password': passwordCtrl.text});},
                    color: Colors.blue,
                  ),
                  height: 60,
                  width: 180,
                ),
                new SizedBox(
                  height: 40,
                  child: Text(msg),
                ),
                new SizedBox(
                  child: new RaisedButton(
                      child: Text("Sign up"),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => RegisterPage())
                        );
                      }
                  ),
                  height: 60,
                  width: 180,
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      page = new Scaffold(
        appBar: new AppBar(
          title: Text(usernameCtrl.text),
        ),
        body: Center(
          child: SizedBox(
            width: 320.0,
            child: new Column(
              children: <Widget>[
                new SizedBox(
                  height: 120,
                ),
                new SizedBox(
                  child: Icon(Icons.person, size: 180.0, color: Colors.lightBlue,),
                  height: 180,
                  width: 180,
                ),
                new SizedBox(
                  height: 40,
                ),
                new Center(
                  child: Text(usernameCtrl.text, style: new TextStyle(fontSize: 40),),
                ),
                new SizedBox(
                  height: 40,
                ),
                new SizedBox(
                  width: 180,
                  height: 60,
                  child: new RaisedButton(
                    child: Text("Log out"),
                    onPressed: () {_logoutPost(token);},
                  ),
                ),
              ],
            )
          ),
        ),
      );
    }
    return page;
  }
}

class RegisterPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _RegisterPageState();
  }
}

class _RegisterPageState extends State<RegisterPage> {
  var msg = '';
  _afterRegister(result) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(result),
          actions: <Widget>[
            new RaisedButton(
              child: new Text("Back"),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            )
          ],
        );
      }
    );
  }
  _registerPost (data) async {
    var host = '10.15.82.223:9090';
    var path = '/app_get_data/app_register';

    var result;
    try {
      var httpClient = HttpClient();
      var uri = new Uri.http(host, path, data);
      var request = await httpClient.postUrl(uri);
      var response = await request.close();
      if (response.statusCode == HttpStatus.ok) {
        var jsondata = await response.transform(utf8.decoder).join();
        var data = json.decode(jsondata);
        result = data['msg'];
        setState(() {
          usernameCtrl.text = "";
          passwordCtrl.text = "";
        });
      } else {
        result = 'Http error: ${response.statusCode}';
      }
    } catch(exception) {
      result = 'Failed to post';
    }
    setState(() {
      if (result != "注册成功") {
        msg = result;
      }
    });
    if (result == "注册成功") {
      _afterRegister(result);
    }
  }
  final usernameCtrl = new TextEditingController();
  final passwordCtrl = new TextEditingController();
  final emailCtrl = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    var page = new Scaffold(
      appBar: new AppBar(
        title: Text("Register"),
      ),
      body: new Center(
        child: new SizedBox(
          width: 320.0,
          child: Column(
            children: <Widget>[
              new SizedBox(
                height: 180,
              ),
              TextFormField(
                controller: usernameCtrl,
                decoration: InputDecoration(
                  icon: Icon(Icons.person),
                  hintText: "Username"
                ),
              ),
              new SizedBox(
                height: 40,
              ),
              TextFormField(
                obscureText: true,
                controller: passwordCtrl,
                decoration: InputDecoration(
                  icon: Icon(Icons.lock),
                  hintText: "Password"
                ),
              ),
              new SizedBox(
                height: 40,
              ),
              TextFormField(
                controller: emailCtrl,
                decoration: InputDecoration(
                  icon: Icon(Icons.email),
                  hintText: "Email"
                ),
              ),
              new SizedBox(
                height: 80,
              ),
              new SizedBox(
                child: new RaisedButton(
                  child: Text("Register"),
                  onPressed: () {
                    _registerPost({
                      'username': usernameCtrl.text,
                      'password': passwordCtrl.text,
                      'email': emailCtrl.text,
                    });
                  },
                  color: Colors.blueAccent,
                ),
                height: 60,
                width: 180,
              ),
              Text(msg),
            ],
          ),
        ),
      ),
    );
    return page;
  }
}