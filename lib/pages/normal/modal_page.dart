import 'package:flutter/material.dart';

class ModalPage extends StatefulWidget {
  const ModalPage({Key? key}) : super(key: key);

  @override
  State<ModalPage> createState() => _ModalPageState();
}

class _ModalPageState extends State<ModalPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Center(child: Text('Modal Page')),
    );
  }
}
