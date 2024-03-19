import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

int commonPageCounter = 0;

class NormalPage extends StatelessWidget {
  const NormalPage({this.number, Key? key}) : super(key: key);
  final String? number;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Common Page - \$${number ?? 0}'),
            buildPushButton(context),
            FilledButton(
              onPressed: () => context.pop(number),
              child: const Text('返回上一个页面'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPushButton(BuildContext context) {
    if (number == '3') {
      return FilledButton(
        onPressed: () => context.go('/top_route_page'),
        child: const Text('go route: /top_route_page'),
      );
    }
    return FilledButton(
      onPressed: () async {
        String? result = await context.push('/common_page?number=${++commonPageCounter}');
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
