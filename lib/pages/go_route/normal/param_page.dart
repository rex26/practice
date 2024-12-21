import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:practice/widgets/custom_app_bar.dart';

class ParamsPage extends StatelessWidget {
  const ParamsPage({
    this.id,
    this.search,
    Key? key,
  }) : super(key: key);
  final String? id;
  final String? search;

  @override
  Widget build(BuildContext context) {
    final String? extraString = GoRouterState.of(context).extra?.toString();

    return Scaffold(
      appBar: const CustomAppbar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Params Page'),
            Text('id: $id'),
            Text('search: $search'),
            Text('extraString: $extraString'),
            FilledButton(
              onPressed: () => context.replace('/top_route_page'),
              child: const Text('replace route：/top_route_page'),
            ),
            FilledButton(
              onPressed: () => context.replace('/normal_page'),
              child: const Text('replace route：/normal_page'),
            ),
            FilledButton(
              onPressed: () => context.replaceNamed('normal_page_route'),
              child: const Text('replaceNamed: normal_page_route'),
            ),
          ],
        ),
      ),
    );
  }
}
