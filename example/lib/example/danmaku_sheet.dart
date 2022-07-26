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
    final double height = 52.rpx;
    final double bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
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
          ],
        ),
      ),
    );
  }
}
