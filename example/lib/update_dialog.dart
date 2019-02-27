import 'package:flutter/material.dart';

class UpdateDialog extends StatefulWidget {
  final key;
  final version;
  final Function onClickWhenDownload;
  final Function onClickWhenNotDownload;

  UpdateDialog({
    this.key,
    this.version,
    this.onClickWhenDownload,
    this.onClickWhenNotDownload,
  });

  @override
  State<StatefulWidget> createState() => new UpdateDialogState();
}

class UpdateDialogState extends State<UpdateDialog> {
  var _downloadProgress = 0.0;

  @override
  Widget build(BuildContext context) {
    var _textStyle =
        new TextStyle(color: Theme.of(context).textTheme.body1.color);

    return new AlertDialog(
      title: new Text(
        "有新的更新",
        style: _textStyle,
      ),
      content: _downloadProgress == 0.0
          ? new Text(
              "版本${widget.version}",
              style: _textStyle,
            )
          : new LinearProgressIndicator(
              value: _downloadProgress,
            ),
      actions: <Widget>[
        new FlatButton(
          child: new Text(
            '更新',
            style: _textStyle,
          ),
          onPressed: () {
            if (_downloadProgress != 0.0) {
              widget.onClickWhenDownload("正在更新中");
              return;
            }
            widget.onClickWhenNotDownload();
//            Navigator.of(context).pop();
          },
        ),
        new FlatButton(
          child: new Text('取消'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  set progress(_progress) {
    setState(() {
      _downloadProgress = _progress;
      if (_downloadProgress == 1) {
        Navigator.of(context).pop();
        _downloadProgress = 0.0;
      }
    });
  }
}
