import 'package:flutter/material.dart';
import 'package:flutter_summernote/flutter_summernote.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Demo Flutter Summernote'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GlobalKey<FlutterSummernoteState> _keyEditor = GlobalKey();
  final _scaffoldState = GlobalKey<ScaffoldState>();
  String result = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        title: Text(widget.title),
        elevation: 0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () async {
              final value = await _keyEditor.currentState.getText();
              _scaffoldState.currentState.showSnackBar(SnackBar(
                duration: Duration(seconds: 5),
                content: Text(value),
              ));
            },
          )
        ],
      ),
      backgroundColor: Colors.white,
      body: FlutterSummernote(
        hint: "Your text here...",
        key: _keyEditor,
        hasAttachment: false,
        customToolbar: """
          [
            ['style', ['bold', 'italic', 'underline', 'clear']],
            ['font', ['strikethrough', 'superscript', 'subscript']],
            ['insert', ['link', 'table', 'hr']]
          ]
        """,
      ),
    );
  }
}