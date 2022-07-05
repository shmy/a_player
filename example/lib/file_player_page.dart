import 'package:flutter/material.dart';

class FilePlayerPage extends StatefulWidget {
  const FilePlayerPage({Key? key}) : super(key: key);

  @override
  State<FilePlayerPage> createState() => _FilePlayerPageState();
}

class _FilePlayerPageState extends State<FilePlayerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('File')),
    );
  }
}
