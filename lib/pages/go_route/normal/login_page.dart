import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:practice/global/global_value.dart';

import 'package:practice/widgets/custom_app_bar.dart';


class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Login Page'),
            FilledButton(
              onPressed: () {
                GlobalValue.isLogin = true;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('已登录')),
                );
                context.go('/');
              },
              child: const Text('登录并回到首页'),
            ),
            FilledButton(
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
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
}
