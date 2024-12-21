import 'package:flutter/material.dart';

import 'package:practice/widgets/custom_app_bar.dart';


class TopRoutePage extends StatelessWidget {
  const TopRoutePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppbar(),
      body: Center(child: Text('Top Route Page')),
    );
  }
}
