import 'package:flutter/material.dart';

import '../../widgets/custom_app_bar.dart';

class HomeSubRoutePage extends StatelessWidget {
  const HomeSubRoutePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppbar(),
      body: Center(
        child: Text('Home Page\'s Sub Route Page'),
      ),
    );
  }
}
