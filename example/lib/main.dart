import 'package:flutter/material.dart';
import 'package:flutter_bugly/flutter_bugly.dart';

void main() => FlutterBugly.postCatchedException(
      () => runApp(MyApp()),
      debugUpload: true,
    );

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    FlutterBugly.init(
      androidAppId: "5346b6e5bb",
      iOSAppId: "your app id",
      // 调用Android原生升级方式
      // autoCheckUpgrade: true,
      // checkUpgradeCount: 0,
      // upgradeCheckPeriod: 60,
    ).then((_result) {
      setState(() {
        _platformVersion = _result.message;
        print(_result.appId);
      });
    });
    FlutterBugly.setUserId("user id");
    FlutterBugly.putUserData(key: "key", value: "value");
    int tag = 9527;
    FlutterBugly.setUserTag(tag);
    //autoCheckUpgrade为true时，可以不用调用
    // if (mounted) _checkUpgrade();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: GestureDetector(
        onTap: () {
          throw 'test';
        },
        child: Center(
          child: Text('init result: $_platformVersion\n'),
        ),
      ),
    );
  }
}
