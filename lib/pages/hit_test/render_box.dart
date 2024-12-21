import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class HitTestBlocker extends SingleChildRenderObjectWidget {
  const HitTestBlocker({
    Key? key,
    this.up = true,
    this.down = false,
    this.self = false,
    this.hit = true,
    this.name = '',
    Widget? child,
  }) : super(key: key, child: child);

  /// up 为 true 时 , `hitTest()` 将会一直返回 false.
  final bool up;

  /// down 为 true 时, 将不会调用 `hitTestChildren()`.
  final bool down;

  /// `hitTestSelf` 的返回值
  final bool self;
  final bool hit;
  final String name;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderHitTestBlocker(
      up: up,
      down: down,
      self: self,
      name: name,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderHitTestBlocker renderObject) {
    print('updateRenderObject $name');
    renderObject
      ..up = up
      ..down = down
      ..self = self;
  }
}

class RenderHitTestBlocker extends RenderProxyBox {
  RenderHitTestBlocker({
    this.up = true,
    this.down = true,
    this.self = true,
    this.name = '',
  });

  bool up;
  bool down;
  bool self;
  String name;

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    print('hitTest $name 开始');
    bool hitTestChildren2 = hitTestChildren(result, position: position);
    print('hitTest hitTestChildren2-$hitTestChildren2 结束');
    result.add(BoxHitTestEntry(this, position));
    return true;
    bool hitTestDownResult = false;

    if (!down) {
      hitTestDownResult = hitTestChildren(result, position: position);
    }

    bool pass = hitTestSelf(position) || (hitTestDownResult && size.contains(position));

    if (pass) {
      result.add(BoxHitTestEntry(this, position));
    }

    // return !up && pass && hit;
    return pass;
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    // TODO: implement hitTestChildren
    return super.hitTestChildren(result, position: position);
  }
  @override
  bool hitTestSelf(Offset position) {
    print('hitTestSelf $name');
    return true;
  }
}

// 自定义 RenderProxyBox，控制事件传递
class CustomHitTestBlocker extends SingleChildRenderObjectWidget {
  final bool blockHitTest;
  final String name;

  const CustomHitTestBlocker({
    Key? key,
    required this.blockHitTest,
    required this.name,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  RenderCustomHitTestBlocker createRenderObject(BuildContext context) {
    return RenderCustomHitTestBlocker(blockHitTest, name);
  }

  @override
  void updateRenderObject(BuildContext context, RenderCustomHitTestBlocker renderObject) {
    renderObject.blockHitTest = blockHitTest;
    renderObject.name = name;
  }
}

class RenderCustomHitTestBlocker extends RenderProxyBox {
  bool blockHitTest;
  String name;
  RenderCustomHitTestBlocker(this.blockHitTest, this.name);

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    print('CustomHitTestBlocker $name');
    /*if (blockHitTest) {
      // 如果 blockHitTest 为 true，则阻止事件传递，直接消费事件
      return false;
    }*/
    return true;
    return super.hitTest(result, position: position); // 允许事件传递
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return false;
    // TODO: implement hitTestChildren
    return super.hitTestChildren(result, position: position);
  }
  @override
  bool hitTestSelf(Offset position) {
    return false;
    // TODO: implement hitTestSelf
    return super.hitTestSelf(position);
  }
}
