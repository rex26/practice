import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:practice/global/constant_data.dart';
import 'package:practice/global/global_value.dart';
import 'package:practice/widgets/bubble_widget.dart';

import 'package:practice/widgets/custom_app_bar.dart';


int commonPageCounter = 0;

class NormalPage extends StatefulWidget {
  const NormalPage({this.number, Key? key}) : super(key: key);
  final String? number;

  @override
  State<NormalPage> createState() => _NormalPageState();
}

class _NormalPageState extends State<NormalPage> with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, lowerBound: 0.3, upperBound: 1.0, duration: const Duration(milliseconds: 500))..forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Normal Page - \$${widget.number ?? 0}'),
            const ChatBubble(
              text: "This is a left bubble\n hello world",
              borderColor: Colors.blue,
              isLeft: true,
            ),
            buildPushButton(context),
            FilledButton(
              onPressed: () => context.push(
                Uri(
                  path: '/params_page',
                  queryParameters: {'search': '调用 replace'},
                ).toString(),
              ),
              child: const Text('push route：/params_page 到 params page'),
            ),
            FilledButton(
              onPressed: () {
                GlobalValue.isLogin = false;
                context.push('/normal_page');
              },
              child: const Text('退出登录，并尝试push: /normal_page'),
            ),
            FilledButton(
              onPressed: () {
                if (context.canPop()) {
                  context.pop(widget.number);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('There is nothing to pop')),
                  );
                }
              },
              child: const Text('返回上一个页面'),
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    controller.forward(from: 0);
                  },
                  child: AnimatedBuilder(
                    animation: controller,
                    builder: (ctx, child) {
                      return Transform.scale(
                        scale: controller.value,
                        child: Opacity(opacity: controller.value, child: child),
                      );
                    },
                    child: Container(
                      height: 100,
                      width: 100,
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                    ),
                  ),
                ),
                Container(height: 100, width: 100, color: Colors.purple),
                const Text(ConstantData.longText),
              ],
            ),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Colors.red,
                    height: 100,
                    width: 200,
                    alignment: Alignment.center,
                    child: const Text('red Container', style: TextStyle(color: Colors.white)),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    color: Colors.blue,
                    height: 100,
                    width: 200,
                    alignment: Alignment.center,
                    child: const Text('blue Container', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.all(20),
              child: const RepaintBoundary(child: CircularProgressIndicator()),
            ),
            Container(
              height: 400,
              margin: const EdgeInsets.symmetric(vertical: 20),
              child: ListView.separated(
                itemCount: 50,
                itemBuilder: (context, index) => ListTile(
                  leading: ClipRect(
                    child: Image.asset(
                      'assets/images/red.png',
                      width: 200,
                      height: 200,
                    ),
                  ),
                  title: Text('${index + 1}'),
                ),
                separatorBuilder: (BuildContext context, int index) {
                  return const Divider();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPushButton(BuildContext context) {
    if (widget.number == '3') {
      return FilledButton(
        onPressed: () => context.go('/top_route_page'),
        child: const Text('go route: /top_route_page'),
      );
    }
    return FilledButton(
      onPressed: () async {
        String? result = await context.push('/normal_page?number=${++commonPageCounter}');
        if (result != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('返回的参数是：$result')),
          );
        }
      },
      child: const Text('push 新的 CommonPage 到堆栈'),
    );
  }
}
