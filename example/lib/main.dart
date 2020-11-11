import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bugly/flutter_bugly.dart';

import 'update_dialog.dart';

void main() => FlutterBugly.postCatchedException(
      () => runApp(MyApp()),
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
  GlobalKey<UpdateDialogState> _dialogKey = new GlobalKey();

  @override
  void initState() {
    super.initState();
    FlutterBugly.init(
      androidAppId: "your app id",
      iOSAppId: "your app id",
    ).then((_result) {
      setState(() {
        _platformVersion = _result.message;
        print(_result.appId);
      });
    });
    FlutterBugly.onCheckUpgrade.listen((_upgradeInfo) {
        _showUpdateDialog(_upgradeInfo.newFeature, _upgradeInfo.apkUrl,
            _upgradeInfo.upgradeType == 2);
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
    FlutterBugly.dispose();
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
          if (Platform.isAndroid) {
            _checkUpgrade();
          }
        },
        child: Center(
          child: Text('init result: $_platformVersion\n'),
        ),
      ),
    );
  }

  void _showUpdateDialog(String version, String url, bool isForceUpgrade) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => _buildDialog(version, url, isForceUpgrade),
    );
  }

  void _checkUpgrade() {
    print("获取更新中。。。");
    FlutterBugly.checkUpgrade();
  }

  Widget _buildDialog(String version, String url, bool isForceUpgrade) {
    return WillPopScope(
        onWillPop: () async => isForceUpgrade,
        child: UpdateDialog(
          key: _dialogKey,
          version: version,
          onClickWhenDownload: (_msg) {
            //提示不要重复下载
          },
          onClickWhenNotDownload: () {
            //下载apk，完成后打开apk文件，建议使用dio+open_file插件
          },
        ));
  }

  //dio可以监听下载进度，调用此方法
  void _updateProgress(_progress) {
    setState(() {
      _dialogKey.currentState.progress = _progress;
    });
  }
}
