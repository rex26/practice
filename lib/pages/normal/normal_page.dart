import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:practice/global/global_value.dart';

import '../../widgets/custom_app_bar.dart';

int commonPageCounter = 0;

class NormalPage extends StatelessWidget {
  const NormalPage({this.number, Key? key}) : super(key: key);
  final String? number;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Normal Page - \$${number ?? 0}'),
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
                  context.pop(number);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('There is nothing to pop')),
                  );
                }
              },
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
