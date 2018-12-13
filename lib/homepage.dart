import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'main.dart';

class MainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _MainPageState();
  }
}

int pos1, pos2;

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Main"),
      ),
      body: new Center(
        child: new Container(
          alignment: Alignment.bottomCenter,
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              new SizedBox(
                height: 120,
                width: 120,
                child: new FloatingActionButton(
                  heroTag: "entity",
                  child: Text(
                    "Entity",
                    style: TextStyle(
                      fontSize: 20
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/entitypage');
                  },
                ),
              ),
              new SizedBox(
                width: 120,
                height: 120,
                child: new FloatingActionButton(
                  heroTag: "relation",
                  child: Text(
                    "Relation",
                    style: TextStyle(
                      fontSize: 20
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/relationpage');
                  },
                ),
              )
            ],
          ),
        )
      ),
    );
  }
}


class EntityPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _EntityPageState();
  }
}

class _EntityPageState extends State<EntityPage> {
  var errorFlag = true;
  var msg = "";
  var data = {};
  var artTitle = "", content = "", sentId = 0, docId = "";
  var labelvalue;
  _getEntity (token) async {
    var host = "10.15.82.223:9090";
    var path = "/app_get_data/app_get_entity";

    try {

      var httpClient = HttpClient();
      var url = Uri.http(host, path, {"token": token});
      var request = await httpClient.postUrl(url);
      var response = await request.close();
      if (response.statusCode == HttpStatus.ok) {
        var jsondata = await response.transform(utf8.decoder).join();
        data = json.decode(jsondata);
        if (data['msg'] == "尚未登录") {
          setState(() {
            msg = data['msg'];
            errorFlag = true;
          });
        } else {
          setState(() {
            errorFlag = false;
            artTitle = data['title'];
            content = data['content'];
            sentId = data['sent_id'];
            docId = data['doc_id'];
          });
        }
      }
    } catch (e) {
      setState(() {
        msg = e.toString();
        errorFlag = true;
      });
    }
  }
  onChanged(e) {
    setState(() {
      labelvalue = e;
    });
  }
  _EntityPageState() {
    _getEntity(gToken);
  }
  _uploadEntity () async {

    var host = 'http://10.15.82.223:9090';
    var path = '/app_get_data/app_upload_triple';

    Map<String, dynamic> uploadData = {
      'token': gToken,
      'doc_id': data['doc_id'],
      'sent_id': data['sent_id'],
      'entities': [{
        'EntityName': content.substring(pos1, pos2),
        'Start': pos1,
        'End': pos2,
        'NerTag': labelvalue
      }]
    };
    var result = "";
    try {
      Dio dio = new Dio();
      dio.options.contentType = ContentType.json;
      FormData data = new FormData.from(uploadData);
      var response = await dio.post(host+path, data: data);
      result = response.data['msg'];

//      var uri = Uri(
//          scheme: "http",
//          host: "10.15.82.223",
//          port: 9090,
//          path: "/app_get_data/app_upload_entity",
//          queryParameters: uploadData
//      );
//      var httpClient = HttpClient();
//      var request = await httpClient.postUrl(uri);
//      request.headers.contentType = ContentType.json;
//      var response = await request.close();
//      if (response.statusCode == HttpStatus.ok) {
//        var jsondata = await response.transform(utf8.decoder).join();
//        var data = json.decode(jsondata);
//        if (data['msg'] == "上传成功") {
//          result = data['msg'];
//        } else {
//          result = data['msg'];
//        }
//      } else {
//        result = 'Http error: ${response.statusCode}';
//      }

    } catch(exception) {
      result = 'Failed to post: ${exception.toString()}';
    }
    setState(() {
      msg = result;
    });
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(msg),
            actions: <Widget>[
              RaisedButton(
                child: Icon(Icons.backspace),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    var errorPage = new Scaffold(
      appBar: AppBar(
        title: Text("Error"),
      ),
      body: new Container(
        alignment: Alignment.center,
        child: Text(
          msg,
          style: TextStyle(
            fontSize: 24
          ),
        ),
      ),
    );
    var labelPage = Scaffold(
      appBar: new AppBar(
        title: Text("Label Entity"),
      ),
      body: new Container(
        child: new Center(
          child: new SizedBox(
            width: 360,
            child: new Column(
              children: <Widget>[
                new SizedBox(
                  height: 20,
                ),
                new SizedBox(
                  child: Text(
                    artTitle,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                new SizedBox(
                  height: 40,
                ),
                new SizedBox(
                  height: 480,
                  child: new Content(
                    content: content,
                  ),
                ),
                new SizedBox(
                  height: 60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Radio(
                        value: "PERSON",
                        groupValue: labelvalue,
                        onChanged: (e) => onChanged(e),
                      ),
                      Text("人名", style: TextStyle(fontSize: 18),),
                      Radio(
                        value: "TITLE",
                        groupValue: labelvalue,
                        onChanged: (e) => onChanged(e),
                      ),
                      Text("官职", style: TextStyle(fontSize: 18),)
                    ],
                  ),
                ),
                new Container(
                  height: 80,
                  alignment: Alignment.center,
                  child: new SizedBox(
                    height: 60,
                    width: 180,
                    child: RaisedButton(
                      child: Icon(Icons.cloud_upload),
                      onPressed: _uploadEntity,
                    ),
                  ),
                )
              ],
            ),
          )
        )
      ),
    );
    if (errorFlag) {
      return errorPage;
    } else {
      return labelPage;
    }
  }
}

class TextButton extends StatelessWidget {
  TextButton({this.onPressed, this.index, this.char, this.color});

  final VoidCallback onPressed;
  final String char;
  final int index;
  final Color color;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return RaisedButton(
      shape: CircleBorder(),
      child: Text(this.char),
      onPressed: onPressed,
      color: this.color,
    );
  }
}

class Content extends StatefulWidget {
  Content({this.content});
  final String content;
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _ContentState(this.content);
  }
}
class _ContentState extends State<Content> {
  bool initFlag = false;
  int x1 = -1, x2 = -1;
  _ContentState(data){
    this.data = data;
    _generateList();
  }

  String data;
  List<TextButton> text;
  List<int> index;
  _onPressed(i) {
    if (x1 == -1) {
      x1 = i;
    } else if (x2 == -1) {
      x2 = i;
    } else {
      x1 = -1;
      x2 = -1;
    }
    if (x1 > x2 && x2 != -1) {
      var tmp = x1;
      x1 = x2;
      x2 = tmp;
    }
    var tmp = text;
    if (x1 != -1 && x2 != -1) {
      for (var i = x1; i <= x2; i ++) {
        tmp[i] =
            TextButton(
              onPressed: () {
                _onPressed(index[i]);
              },
              index: i,
              char: data.substring(i, i + 1),
              color: Colors.blue,
            );
      }
    }
    if (x1 == -1 && x2 == -1) {
      for (var i = 0; i < text.length; i ++) {
        tmp[i] =
            TextButton(
              onPressed: () {
                _onPressed(index[i]);
              },
              index: i,
              char: data.substring(i, i + 1),
              color: Colors.white,
            );
      }
    }
    setState(() {
      text = List<TextButton>(data.length);
      for (var i = 0; i < data.length; i ++) {
        index[i] = i;
        if (i >= x1 && i <= x2){
          text[i] =
              TextButton(
                onPressed: () {
                  _onPressed(index[i]);
                },
                index: i,
                char: data.substring(i, i + 1),
                color: Colors.blue,
              );
        } else {
          text[i] =
              TextButton(
                onPressed: () {
                  _onPressed(index[i]);
                },
                index: i,
                char: data.substring(i, i + 1),
                color: Colors.white,
              );
        }
      }
    });
  }


  _generateList() {
    if (initFlag == false) {
      text = List<TextButton>(data.length);
      index = List<int>(data.length);
      for (var i = 0; i < data.length; i ++) {
        index[i] = i;
        text[i] =
            TextButton(
              onPressed: () {
                _onPressed(index[i]);
              },
              index: i,
              char: data.substring(i, i + 1),
              color: Colors.white,
            );
      }
      initFlag = true;
    }
  }
  @override
  Widget build(BuildContext context) {
    if(x1 != -1 && x2 != -1) {
      pos1 = x1;
      pos2 = x2;
    }
    var page = new GridView(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 44),
      semanticChildCount: 10,
      children: text,
    );
    return page;
  }
}


class RelationPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _RelationPageState();
  }
}

class _RelationPageState extends State<RelationPage> {
  var errorFlag = true;
  var msg = "";
  var data = {};
  var artTitle = "", content, sentId = 0, docId = "", triples = [];
  var indexList;
  var currentRelation;
  List<RaisedButton> relations;
  List<int> modified = new List<int>(0);

  _getTriple(token) async {
    var host = "10.15.82.223:9090";
    var path = "/app_get_data/app_get_triple";
    try {
      var httpClient = HttpClient();
      var url = Uri.http(host, path, {"token": token});
      var request = await httpClient.postUrl(url);
      var response = await request.close();
      if (response.statusCode == HttpStatus.ok) {
        var jsondata = await response.transform(utf8.decoder).join();
        data = json.decode(jsondata);
        if (data['msg'] == "尚未登录") {
          setState(() {
            msg = data['msg'];
            errorFlag = true;
          });
        } else {
          setState(() {
            errorFlag = false;
            artTitle = data['title'];
            content = new RichText(text: TextSpan(text: data['sent_ctx'], style: TextStyle(color: Colors.black87, fontSize: 18)));
            sentId = data['sent_id'];
            docId = data['doc_id'];
            triples = data['triples'];
          });
        }
      }
    } catch (e) {
      setState(() {
        msg = e.toString();
        errorFlag = true;
      });
    }
  }
  String gTest;
  _uploadTriple () async {
    for (var i = 0; i < triples.length; i ++) {
      if (modified[i] != 1) {
        triples[i]['status'] = -1;
      } else {
        triples[i]['status'] = 1;
        var newId = List(triples[i]['id']);
        newId.shuffle();
        triples[i]['id'] = newId.toString();
      }
    }
    var host = 'http://10.15.82.223:9090';
    var path = '/app_get_data/app_upload_triple';

    Map<String, dynamic> uploadData = {
      'doc_id': data['doc_id'],
      'sent_id' : data['sent_id'],
      'title': data['title'],
      'sent_ctx': data['sent_ctx'],
      'token': gToken,
      'triples': triples,
    };
    var result = "";
    try {
//      Map headers = {
//        'Content-type' : 'application/json',
//        'Accept': 'application/json',
//      };
//      var url = "http://10.15.82.223:9090/app_get_data/app_upload_triple";
//      var response = http.post(
//          url,
//          body: json.encode(data),
//          headers: {'content-type': 'application/json'});
//      response.then((response) {
//        print(response.body);
//      });

//      var uri = Uri(
//        scheme: "http",
//        host: "10.15.82.223",
//        port: 9090,
//        path: "/app_get_data/app_upload_triple",
//        queryParameters: uploadData
//      );
//      var httpClient = HttpClient();
//      var request = await httpClient.postUrl(uri);
//      request.headers.contentType = ContentType.json;
//      var response = await request.close();
//      if (response.statusCode == HttpStatus.ok) {
//        var jsondata = await response.transform(utf8.decoder).join();
//        var data = json.decode(jsondata);
//        if (data['msg'] == "上传成功") {
//          result = data['msg'];
//        } else {
//          result = data['msg'];
//        }
//      } else {
//        result = 'Http error: ${response.statusCode}';
//      }

      Dio dio = new Dio();
      dio.options.contentType = ContentType.json;
      FormData data = new FormData.from(uploadData);
      var response = await dio.post("http://10.15.82.223:9090/app_get_data/app_upload_triple", data: data);
      result = response.data['msg'];

    } catch(exception) {
      result = 'Failed to post: ${exception.toString()}';
    }
    setState(() {
      msg = result;
    });
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(msg),
          actions: <Widget>[
            RaisedButton(
              child: Icon(Icons.backspace),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      }
    );
  }

  _onRelationPressed(index) {
    var head, left, mid, right, tail;
    var text = data['sent_ctx'];
    if(triples[index]['left_e_start'] >= triples[index]['right_e_end']) {
      head = text.substring(0, triples[index]['right_e_start']);
      right = text.substring(triples[index]['left_e_start'], triples[index]['left_e_end']);
      mid = text.substring(triples[index]['right_e_end'], triples[index]['left_e_start']);
      left = text.substring(triples[index]['right_e_start'], triples[index]['right_e_end']);
      tail = text.substring(triples[index]['left_e_end']);
    } else {
      head = text.substring(0, triples[index]['left_e_start']);
      left = text.substring(triples[index]['left_e_start'], triples[index]['left_e_end']);
      mid = text.substring(triples[index]['left_e_end'], triples[index]['right_e_start']);
      right = text.substring(triples[index]['right_e_start'], triples[index]['right_e_end']);
      tail = text.substring(triples[index]['right_e_end']);
    }

    currentRelation = index;
    var rich = new RichText(
      text: TextSpan(
        text: '',
        style: TextStyle(
          fontSize: 18
        ),
        children: <TextSpan> [
          TextSpan(
            text: head,
            style: TextStyle(
              color: Colors.black87
            )
          ),
          TextSpan(
            text: left,
            style: TextStyle(
              color: Colors.red,
              fontStyle: FontStyle.italic
            )
          ),
          TextSpan(
            text: mid,
            style: TextStyle(
              color: Colors.black87
            )
          ),
          TextSpan(
            text: right,
            style: TextStyle(
              color: Colors.red,
              fontStyle: FontStyle.italic
            )
          ),
          TextSpan(
            text: tail,
            style: TextStyle(
              color: Colors.black87
            )
          )
        ],
      ),
    );
    setState(() {
      content = rich;
      if (modified[currentRelation] == 0) {
        wrongColor = Colors.red;
        rightColor = Colors.green;
      } else if (modified[currentRelation] == 1) {
        wrongColor = Colors.grey;
        rightColor = Colors.green;
      } else if (modified[currentRelation] == 2) {
        wrongColor = Colors.red;
        rightColor = Colors.grey;
      }
    });
  }

  _generateButton() {
    relations = new List<RaisedButton>.filled(
      triples.length,
      null,
    );
    if (triples.length != modified.length) {
      modified = new List<int>.filled(triples.length, 0);
    }
    indexList = new List<int>.generate(triples.length, (index)=>index);
    for (var i = 0; i < triples.length; i ++) {
      var rel = "";
      if (triples[i]['relation_id'] == 0) {
        rel = "职务";
      } else if (triples[i]['relation_id'] == 1) {
        rel = "亲属";
      }
      relations[i] = new RaisedButton(
        onPressed: () {_onRelationPressed(indexList[i]);},
        child: Text(rel),
        shape: StadiumBorder(),
      );
    }
  }
  var wrongColor = Colors.red, rightColor = Colors.green;

  _wrongPressed() {
    if (triples.length == 0)
      return;
    else {
      setState(() {
        modified[currentRelation] = 1;
        wrongColor = Colors.grey;
        rightColor = Colors.green;
      });
      if (triples[currentRelation]['relation_id'] == 0) {
        triples[currentRelation]['relation_id'] = 1;
      } else {
        triples[currentRelation]['relation_id'] = 0;
      }
    }
  }
  _rightPressed() {
    if (triples.length == 0)
      return;
    else {
      setState(() {
        modified[currentRelation] = 2;
        wrongColor = Colors.red;
        rightColor = Colors.grey;
      });
    }
  }

  _RelationPageState() {
    _getTriple(gToken);
  }
  @override
  Widget build(BuildContext context) {
    _generateButton();
    var errorPage = new Scaffold(
      appBar: AppBar(
        title: Text("Error"),
      ),
      body: new Container(
        alignment: Alignment.center,
        child: Text(
          msg,
          style: TextStyle(
              fontSize: 24
          ),
        ),
      ),
    );
    var labelPage = Scaffold(
      appBar: new AppBar(
        title: Text("Label Relation"),
      ),
      body: new Column(
        children: <Widget>[
          new Container(
            alignment: FractionalOffset.topCenter,
            child: new Container(
              width: 360,
              height: 540,
              child: new ListView(
                children: <Widget>[
                  new SizedBox(
                    height: 20,
                  ),
                  new SizedBox(
                    child: Text(
                      artTitle,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  new SizedBox(
                    height: 40,
                  ),
                  new SizedBox(
                    child: content
                  ),
                  new Text(gTest.toString())
                ],
              ),
            ),
          ),
          new Container(
            alignment: FractionalOffset.bottomCenter,
            child: new Column(
              children: <Widget>[
                new Container(
                  height: 60,
                  padding: EdgeInsets.all(4.0),
                  child: new ListView(
                    scrollDirection: Axis.horizontal,
                    children: relations,
                  ),
                ),
                new Container(
                  height: 80,
                  alignment: Alignment.bottomCenter,
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      new SizedBox(
                        width:150,
                        height: 60,
                        child: RaisedButton(
                          onPressed: _wrongPressed,
                          color: wrongColor,
                          child: new SizedBox(
                            width:150,
                            height: 60,
                            child: Icon(Icons.close),
                          )
                        ),
                      ),
                      new SizedBox(
                        width:150,
                        height: 60,
                        child: RaisedButton(
                          onPressed: _rightPressed,
                          color: rightColor,
                          child: Icon(Icons.done),
                        ),
                      ),
                    ],
                  )
                ),
                new SizedBox(
                  height: 20,
                ),
                new SizedBox(
                  height: 60,
                  width: 320,
                  child: new RaisedButton(
                    child: new Icon(Icons.cloud_upload),
                    onPressed: () {
                      _uploadTriple();
                    }
                  ),
                )
              ],
            )
          )
        ],
      )
    );
    if (errorFlag) {
      return errorPage;
    } else {
      if (triples.length > 0)
        _onRelationPressed(0);
      return labelPage;
    }
  }
}