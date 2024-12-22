import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class AutoSizeTextApp extends StatelessWidget {
  const AutoSizeTextApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Custom AutoSizeTextDemo',
      home: AutoSizeTextDemo(),
    );
  }
}

class AutoSizeTextDemo extends StatelessWidget {
  AutoSizeTextDemo({super.key});

  final AutoSizeGroup textGroup = AutoSizeGroup();

  @override
  Widget build(BuildContext context) {
    const String longText =
        ''' This is a long text that will not fit the screen This is a long text that will not fit the screen This is a long text that will not fit the screen This is a long text that will not fit the screen This is a long text that will not fit the screen This is a long text that will not fit the screen ''';
    return Scaffold(
      appBar: AppBar(
        title: const Text("AutoSizeText Example"),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text("AutoSizeText with stepGranularity 1"),
            const SizedBox(height: 20),
            const AutoSizeText(
              longText,
              style: TextStyle(fontSize: 20),
              maxLines: 2,
              minFontSize: 10,
              maxFontSize: 20,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),
            const Text("AutoSizeText with stepGranularity 5"),
            const SizedBox(height: 20),
            const AutoSizeText(
              longText,
              style: TextStyle(fontSize: 20),
              maxLines: 2,
              minFontSize: 10,
              maxFontSize: 20,
              stepGranularity: 5,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),
            const Text("AutoSizeText with presetFontSizes"),
            const SizedBox(height: 20),
            const AutoSizeText(
              longText,
              style: TextStyle(fontSize: 20),
              maxLines: 2,
              minFontSize: 10,
              maxFontSize: 20,
              presetFontSizes: [20, 18, 16, 14, 12, 10],
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),

            /// region 使用 group 同步字体大小
            const Text(
              '使用 group 同步字体大小:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Container(
              color: Colors.grey[200],
              width: double.infinity,
              height: 50,
              child: AutoSizeText(
                '文本 1：字体大小与其他文本同步。',
                style: const TextStyle(fontSize: 30),
                maxLines: 1,
                group: textGroup,
              ),
            ),
            const SizedBox(height: 20),
            AutoSizeText(
              longText,
              style: const TextStyle(fontSize: 20),
              maxLines: 2,
              minFontSize: 5,
              maxFontSize: 10,
              overflow: TextOverflow.ellipsis,
              group: textGroup,
            ),
            const SizedBox(height: 20),
            Container(
              color: Colors.grey[200],
              width: double.infinity,
              height: 50,
              child: AutoSizeText.rich(
                const TextSpan(
                  style: TextStyle(fontSize: 30),
                  children: [
                    TextSpan(
                      text: '这是一个富文本。',
                      style: TextStyle(fontSize: 10),
                    ),
                    TextSpan(
                      text: '这是一个富文本。',
                      style: TextStyle(fontSize: 20),
                    ),
                    TextSpan(
                      text: '文本 2：字体大小与其他文本同步。',
                      style: TextStyle(fontSize: 30),
                    ),
                  ],
                ),
                style: const TextStyle(fontSize: 30),
                maxLines: 1,
                group: textGroup,
              ),
            ),
            const SizedBox(height: 20),
            AutoSizeText(
              longText,
              style: const TextStyle(fontSize: 20),
              maxLines: 2,
              minFontSize: 10,
              maxFontSize: 20,
              overflowReplacement: const Text('文本太长, 已被替换'),
              group: textGroup,
            ),
            /// endregion
          ],
        ),
      ),
    );
  }
}
