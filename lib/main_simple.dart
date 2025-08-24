import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const SimpleTestApp());
}

class SimpleTestApp extends StatelessWidget {
  const SimpleTestApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      title: 'AssetWorks Test',
      home: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('AssetWorks Test'),
        ),
        child: Center(
          child: Text(
            'App is running!',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}