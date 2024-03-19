import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Page')),
      body: Center(
        child: Scrollbar(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Home Page，route：/'),
                const SizedBox(height: 50),
                FilledButton(
                  onPressed: () => context.go('/normal_page'),
                  child: const Text('go route：/normal_page 一般页面'),
                ),
                FilledButton(
                  onPressed: () => context.goNamed('normal_page_route'),
                  child: const Text('goNamed route name：normal_page_route 一般页面'),
                ),
                FilledButton(
                  onPressed: () => context.push('/normal_page'),
                  child: const Text('push route：/normal_page 一般页面'),
                ),
                FilledButton(
                  onPressed: () => context.pushNamed('normal_page_route'),
                  child: const Text('pushNamed route name：normal_page_route 一般页面'),
                ),
                FilledButton(
                  onPressed: () => context.go('/home_sub_route_page'),
                  child: const Text('go route：/home_sub_route_page  Home的子路由页面'),
                ),
                FilledButton(
                  onPressed: () => context.push('/home_sub_route_page'),
                  child: const Text('push route：/home_sub_route_page  Home的子路由页面'),
                ),
                FilledButton(
                  onPressed: () => context.go('/modal_page'),
                  child: const Text('go route：/modal_page  Home的子路由页面'),
                ),
                FilledButton(
                  onPressed: () => context.push('/params_page/hello'),
                  child: const Text('push route：/params_page/:id 接收参数的页面'),
                ),
                FilledButton(
                  onPressed: () => context.push('/params_page', extra: 'extra string'),
                  child: const Text('push route：/params_page 接收extra的页面'),
                ),
                FilledButton(
                  // onPressed: () => context.push('/params_page?search=world'),
                  onPressed: () => context.push(
                    Uri(
                      path: '/params_page',
                      queryParameters: {'search': 'world'},
                    ).toString(),
                  ),
                  child: const Text('push route：/params_page?search=world 接收参数的页面'),
                ),
                FilledButton(
                  onPressed: () => context.go('/top_route_page/sub_route_page'),
                  child: const Text('go route：/top_route_page/sub_route_page 其他子路由页面'),
                ),
                FilledButton(
                  onPressed: () => context.push('/top_route_page/sub_route_page'),
                  child: const Text('push route：/top_route_page/sub_route_page 其他子路由页面'),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Text('404'),
        onPressed: () => context.go('/404'),
      ),
    );
  }
}
