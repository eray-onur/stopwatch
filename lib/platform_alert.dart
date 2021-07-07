import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PlatformAlert {
  final String title;
  final String message;

  const PlatformAlert({@required this.title, @required this.message})
  : assert(title != null), assert(message != null);

  void show(BuildContext context) {
    final platform = Theme.of(context).platform;
    if(platform == TargetPlatform.iOS) {
      _buildCupertinoAlert(context);
    } else {
      _buildMaterialAlert(context);
    }
  }

  Widget _buildCupertinoAlert(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              CupertinoButton(
                  child: Text('Close'),
                  onPressed: () => Navigator.of(context).pop()
              )
            ],
          );
        }
    );
  }

  Widget _buildMaterialAlert(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                  child: Text('Close'),
                  onPressed: () => Navigator.of(context).pop()
              )
            ],
          );
        }
    );
  }

}