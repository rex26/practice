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
    final String extraString = GoRouterState.of(context).extra! as String;

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
          ],
        ),
      ),
    );
  }
}
