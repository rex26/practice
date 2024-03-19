import 'package:flutter/material.dart';

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
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Params Page'),
            Text('id: $id'),
            Text('search: $search'),
          ],
        ),
      ),
    );
  }
}
