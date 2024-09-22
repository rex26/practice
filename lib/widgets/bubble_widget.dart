import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final Color borderColor;
  final bool isLeft;

  const ChatBubble({
    super.key,
    required this.text,
    required this.borderColor,
    this.isLeft = true,
  });

  @override
  Widget build(BuildContext context) {
    double arrowWidth = 20;
    return CustomPaint(
      painter: BubblePainter(
        borderColor: borderColor,
        isLeft: isLeft,
        arrowWidth: arrowWidth,
      ),
      child: Container(
        padding: EdgeInsets.only(left: arrowWidth + 10.0, right: 10.0, top: 10.0, bottom: 10.0),
        margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
        child: Text(text),
      ),
    );
  }
}

class BubblePainter extends CustomPainter {
  final Color borderColor;
  final bool isLeft;
  final double arrowWidth;

  BubblePainter({
    required this.borderColor,
    required this.isLeft,
    this.arrowWidth = 10.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.transparent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = borderColor;

    final path = Path();
    const radius = 10.0;
    if (isLeft) {
      path.moveTo(radius + arrowWidth, 0);
      path.lineTo(size.width - radius, 0);
      path.arcToPoint(
        Offset(size.width, radius),
        radius: const Radius.circular(radius),
      );
      path.lineTo(size.width, size.height - radius);
      path.arcToPoint(
        Offset(size.width - radius, size.height),
        radius: const Radius.circular(radius),
      );
      path.lineTo(radius + arrowWidth, size.height);
      path.arcToPoint(
        Offset(arrowWidth, size.height - radius),
        radius: const Radius.circular(radius),
      );
      path.lineTo(arrowWidth, 30); // 竖线高度到 y=30
      path.lineTo(0, 20); // 第一根斜线的高度=30 - 20
      path.lineTo(arrowWidth, 10); // 第二根斜线高度=20 - 10
      path.lineTo(arrowWidth, radius);
      path.arcToPoint(
        Offset(radius + arrowWidth, 0),
        radius: const Radius.circular(radius),
      );
    } else {
      path.moveTo(radius, 0);
      path.lineTo(size.width - radius - 10, 0);
      path.arcToPoint(
        Offset(size.width - 10, radius),
        radius: const Radius.circular(radius),
      );
      path.lineTo(size.width - 10, 10);
      path.lineTo(size.width, 20);
      path.lineTo(size.width - 10, 30);
      path.lineTo(size.width - 10, size.height - radius);
      path.arcToPoint(
        Offset(size.width - radius - 10, size.height),
        radius: const Radius.circular(radius),
      );
      path.lineTo(radius, size.height);
      path.arcToPoint(
        Offset(0, size.height - radius),
        radius: const Radius.circular(radius),
      );
      path.lineTo(0, radius);
      path.arcToPoint(
        const Offset(radius, 0),
        radius: const Radius.circular(radius),
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
