import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bugly/flutter_bugly.dart';

import 'update_dialog.dart';

void main() => FlutterBugly.postCatchedException(() {
      runApp(MyApp());
    });

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
              FlutterBugly.getUpgradeInfo().then((UpgradeInfo info) {
                if (info != null && info.id != null) {
                  showUpdateDialog(info.newFeature, info.apkUrl);
                }
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

  void showUpdateDialog(String version, String url) async {
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => _buildDialog(version, url),
    );
  }

  Widget _buildDialog(String version, String url) {
    return new UpdateDialog(
      key: _dialogKey,
      version: version,
      onClickWhenDownload: (_msg) {
        //提示不要重复下载
      },
      onClickWhenNotDownload: () {
        //下载apk，完成后打开apk文件，建议使用dio+open_file插件
      },
    );
  }
  //dio可以监听下载进度，调用此方法
  void _updateProgress(_progress) {
    setState(() {
      _dialogKey.currentState.progress = _progress;
    });
  }
}
