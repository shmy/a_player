import 'package:flutter/material.dart';
import 'package:rpx/rpx.dart';

class DanmakuSheet extends StatefulWidget {
  final TextEditingController danmakuEditingController;
  final VoidCallback onSend;

  const DanmakuSheet(
      {Key? key, required this.danmakuEditingController, required this.onSend})
      : super(key: key);

  @override
  State<DanmakuSheet> createState() => _DanmakuSheetState();
}

class _DanmakuSheetState extends State<DanmakuSheet> {
  String text = '';
  @override
  void initState() {
    widget.danmakuEditingController.addListener(onEditingChange);
    onEditingChange();
    super.initState();
  }
  @override
  void dispose() {
    widget.danmakuEditingController.removeListener(onEditingChange);
    super.dispose();
  }
  void onEditingChange() {
    setState(() {
      text = widget.danmakuEditingController.text;
    });
  }
  @override
  Widget build(BuildContext context) {
    final double height = 130.rpx;
    final double bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey.withOpacity(0.5),
            width: 1.rpx,
          ),
        ),
      ),
      padding: EdgeInsets.only(
        left: 10.rpx,
        right: 10.rpx,
      ),
      height: bottom + height,
      child: SizedBox(
        height: height,
        child: Column(
          children: [
            SizedBox(
              height: 10.rpx,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(20.rpx),
                    ),
                    height: 32.rpx,
                    padding: EdgeInsets.symmetric(horizontal: 15.rpx),
                    child: Center(
                      child: TextField(
                        controller: widget.danmakuEditingController,
                        onSubmitted: (_) => widget.onSend(),
                        autofocus: true,
                        decoration: InputDecoration(
                          isCollapsed: true,
                          hintText: '发个友善的弹幕见证下',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          fillColor: Colors.grey[300],
                          filled: true,
                        ),
                        style: TextStyle(fontSize: 14.rpx),
                      ),
                    ),
                  ),
                ),
                if (text.isNotEmpty)
                SizedBox(
                  width: 20.rpx,
                ),
                if (text.isNotEmpty)
                GestureDetector(onTap: widget.onSend, child: const Icon(Icons.send)),
              ],
            ),
            SizedBox(
              height: 10.rpx,
            ),
            SizedBox(
              height: 28.rpx,
              child: Row(
                children: [
                  const Text('颜色'),
                  SizedBox(width: 10.rpx,),
                  Expanded(
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        Container(color: Colors.red, height: 28.rpx, width: 28.rpx, margin: EdgeInsets.only(right: 10.rpx),),
                        Container(color: Colors.red, height: 28.rpx, width: 28.rpx, margin: EdgeInsets.only(right: 10.rpx),),
                        Container(color: Colors.red, height: 28.rpx, width: 28.rpx, margin: EdgeInsets.only(right: 10.rpx),),
                        Container(color: Colors.red, height: 28.rpx, width: 28.rpx, margin: EdgeInsets.only(right: 10.rpx),),
                        Container(color: Colors.red, height: 28.rpx, width: 28.rpx, margin: EdgeInsets.only(right: 10.rpx),),
                        Container(color: Colors.red, height: 28.rpx, width: 28.rpx, margin: EdgeInsets.only(right: 10.rpx),),
                        Container(color: Colors.red, height: 28.rpx, width: 28.rpx, margin: EdgeInsets.only(right: 10.rpx),),
                        Container(color: Colors.red, height: 28.rpx, width: 28.rpx, margin: EdgeInsets.only(right: 10.rpx),),
                        Container(color: Colors.red, height: 28.rpx, width: 28.rpx, margin: EdgeInsets.only(right: 10.rpx),),
                        Container(color: Colors.red, height: 28.rpx, width: 28.rpx, margin: EdgeInsets.only(right: 10.rpx),),
                        Container(color: Colors.red, height: 28.rpx, width: 28.rpx, margin: EdgeInsets.only(right: 10.rpx),),

                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.rpx,),
            SizedBox(
              height: 28.rpx,
              child: Row(
                children: [
                  const Text('位置'),
                  SizedBox(width: 10.rpx,),
                  Expanded(
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        Container(color: Colors.red, height: 28.rpx, width: 28.rpx, margin: EdgeInsets.only(right: 10.rpx),),
                        Container(color: Colors.red, height: 28.rpx, width: 28.rpx, margin: EdgeInsets.only(right: 10.rpx),),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
