import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bugly/flutter_bugly.dart';

import 'update_dialog.dart';

void main() => FlutterBugly.postCatchedException(() => runApp(MyApp()));

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

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
      androidAppId: "0358f4a973",
      iOSAppId: "0358f4a973",
    ).then((_result) {
      setState(() {
        _platformVersion = _result.message;
        print(_result.appId);
      });
    });
    // autoCheckUpgrade 为 true 时，可以不用调用
    // if (mounted) _checkUpgrade();
  }

  @override
  void dispose() {
    FlutterBugly.dispose();
    super.dispose();
  }

  Widget getItemView(String title, VoidCallback onPressed,
      {bool visibility = true}) {
    return Visibility(
      visible: visibility,
      child: RaisedButton(
        child: new Text(title),
        color: Color(0x66E6C8A0),
        textColor: Colors.white,
        onPressed: onPressed,
        shape: RoundedRectangleBorder(
            side: new BorderSide(color: Color(0xffE6C8A0), width: 1.0),
            borderRadius: BorderRadius.circular(20.0)), //圆角大小
      ),
    );
  }

  Future<void> _log() async {
    print("---- 打印日志 ----");
    debugPrint("调试日志。。。。");
    FlutterBugly.log("lock", "调试打印日志");

    // var tt = int.parse("100fdaf");
  }

  Future<void> _upload() async {
    print("---- 上报日志 ----");
    FlutterBugly.uploadException(
        message: "这个是一个日志。用来测试的 打印---${Random().nextInt(1000)}  日志",
        detail: "我是用来测试ice ${Random().nextInt(1000)} ---- 2 我是detail");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bugly SDK')),
      body: Center(
        child: Column(
          children: [
            getItemView("日志", _log, visibility: true),
            getItemView("上报", _upload, visibility: true),
          ],
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
          // 提示不要重复下载
        },
        onClickWhenNotDownload: () {
          //下载 apk，完成后打开 apk 文件，建议使用 dio + open_file 插件
        },
      ),
    );
  }

  /// Dio 可以监听下载进度，调用此方法
  void _updateProgress(_progress) {
    setState(() {
      _dialogKey.currentState.progress = _progress;
    });
  }
}
