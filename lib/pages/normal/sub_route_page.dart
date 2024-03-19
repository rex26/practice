import 'package:flutter/material.dart';

class SubRoutePage extends StatelessWidget {
  const SubRoutePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
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
