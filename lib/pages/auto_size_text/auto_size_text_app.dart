import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class AutoSizeTextApp extends StatelessWidget {
  const AutoSizeTextApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Custom AutoSizeTextDemo',
      home: AutoSizeTextDemo(),
    );
  }
}

class AutoSizeTextDemo extends StatelessWidget {
  const AutoSizeTextDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AutoSizeText Example"),
      ),
      body: const Center(
        child: Column(
          children: [
            SizedBox(height: 20),
            Text("AutoSizeText"),
            SizedBox(height: 20),
            AutoSizeText(
              'This is a long text that will not fit the screen',
              style: TextStyle(fontSize: 20),
              maxLines: 2,
              minFontSize: 10,
              maxFontSize: 20,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 20),
            Text("AutoSizeText with stepGranularity"),
            SizedBox(height: 20),
            AutoSizeText(
              'This is a long text that will not fit the screen',
              style: TextStyle(fontSize: 20),
              maxLines: 2,
              minFontSize: 10,
              maxFontSize: 20,
              stepGranularity: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 20),
            Text("AutoSizeText with presetFontSizes"),
            SizedBox(height: 20),
            AutoSizeText(
              'This is a long text that will not fit the screen',
              style: TextStyle(fontSize: 20),
              maxLines: 2,
              minFontSize: 10,
              maxFontSize: 20,
              presetFontSizes: [20, 18, 16, 14, 12, 10],
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
