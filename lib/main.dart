import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_work/contact_work.dart';
import 'package:flutter_work/download_work.dart';
import 'package:flutter_work/login_work.dart';
import 'package:flutter_work/topic_work.dart';
import 'package:flutter_work/upload_work.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  final TextEditingController _numberController = new TextEditingController();
  final TextEditingController _codeController = new TextEditingController();

  final work = LoginWork();

  void _incrementCounter() {
    final counter = ++_counter;

    work.start([_numberController.text, _codeController.text]);

    if (_counter > 5) {
      print("all work cancel");
      work.cancel();
    }
  }

  _download() async {
    Directory tempDir = await getTemporaryDirectory();

    DownloadWork().start(["${tempDir.path}/temp.png"], 0, (c, t) {
      print("download $c/$t ${c * 100 ~/ t}%");
    });
  }

  _upload() async {

    final file=  await ImagePicker.pickImage(source: ImageSource.gallery);

    await UploadWork().start([file.path]);

    print("upload end");
  }

  _contact() async {
    ContactWork().start();
  }

  _topic() async {
    TopicWork().start();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return new Scaffold(
      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: new Text(widget.title),
      ),
      body: new Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: new Column(
          // Column is also layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug paint" (press "p" in the console where you ran
          // "flutter run", or select "Toggle Debug Paint" from the Flutter tool
          // window in IntelliJ) to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              keyboardType: TextInputType.number,
              controller: _numberController,
              decoration: InputDecoration(
                hintText: '手机号',
              ),
            ),
            TextField(
              keyboardType: TextInputType.number,
              controller: _codeController,
              decoration: InputDecoration(
                hintText: '验证码',
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _upload,
        tooltip: 'Increment',
        child: new Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
