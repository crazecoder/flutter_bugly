import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bugly/flutter_bugly.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    FlutterBugly.init(androidAppId:"your android app id",iOSAppId: "your iOS app id", autoDownloadOnWifi: true,upgradeCheckPeriod: 5,enableNotification: true).then((_result){
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
            if (Platform.isAndroid){
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
