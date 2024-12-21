import 'package:flutter/material.dart';
import 'package:practice/pages/hit_test/render_box.dart';

class HitTestApp extends StatelessWidget {
  const HitTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Custom HitTest Example',
      home: StackItemDemo(),
    );
  }
}

class StackItemDemo extends StatefulWidget {
  const StackItemDemo({super.key});

  @override
  _StackItemDemoState createState() => _StackItemDemoState();
}

class _StackItemDemoState extends State<StackItemDemo> {
  @override
  Widget build(BuildContext context) {
    double top = 400;
    double width = 300;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Event Handling Example"),
      ),
      body: Center(
        child: Stack(
          children: [
            // Row containing b1 and b2
            Positioned(
              top: top,
              left: width,
              child: Row(
                children: [
                  // b1 事件区域，事件不传递
                  CustomHitTestBlocker(
                    name: 'b1',
                    blockHitTest: true,
                    child: Container(
                      width: width,
                      height: width,
                      color: Colors.blue,
                      child: const Center(child: Text("b1")),
                    ),
                  ),
                  const SizedBox(width: 10), // 间距
                  Container(
                    width: width,
                    height: width,
                    color: Colors.red,
                    child: const Center(child: Text("b2")),
                  ),
                ],
              ),
            ),
            // Item A 覆盖在上面
            Positioned(
              top: top,
              left: width,
              child: HitTestBlocker(
                up: true,
                down: true,
                self: false,
                name: 'Item A',
                child: Listener(
                  behavior: HitTestBehavior.opaque,
                  onPointerDown: (PointerDownEvent e) {
                    print(" A  A  A  A Item A tapped");
                  },
                  child: Container(
                    width: width * 2 + 10, // 覆盖整个 b1 和 b2 的区域
                    height: width,
                    color: Colors.black87, // 半透明效果
                    child: const Center(child: Text("Item A (Tap to test)")),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

