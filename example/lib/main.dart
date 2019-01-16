import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bugly/flutter_bugly.dart';

void main()=>FlutterBugly.postCatchedException((){
  runApp(MyApp());
});

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    FlutterBugly.init(
      androidAppId: "your app id",
      iOSAppId: "your app id",
    ).then((_result) {
      setState(() {
        _platformVersion = _result;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: GestureDetector(
          onTap: () {
            if (Platform.isAndroid) {
              FlutterBugly.checkUpgrade();
              FlutterBugly.getUpgradeInfo().then((_info) {
                print("------------------${_info?.title}");
              });
            }
          },
          child: Center(
            child: Text('init result: $_platformVersion\n'),
          ),
        ),
      ),
    );
  }
}
