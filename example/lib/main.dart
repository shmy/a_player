import 'package:a_player_example/network_player_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rpx/rpx.dart';

void main() async {

  await Rpx.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const GetMaterialApp(
      home: MainPage(),
    );
  }
}
class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: ListView(
        children: [
          MaterialButton(onPressed: () {
            Get.to(() => const NetworkPlayerPage());
          }, child: const Text('Network Test'),),
        ],
      ),
    );
  }
}
