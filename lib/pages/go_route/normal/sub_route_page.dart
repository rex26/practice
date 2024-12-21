import 'package:flutter/material.dart';

import 'package:practice/widgets/custom_app_bar.dart';


class SubRoutePage extends StatelessWidget {
  const SubRoutePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Sub Route Page'),
          ],
        ),
      ),
    );
  }
}
