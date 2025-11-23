import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';

void main() {
  runApp(const FlutterWidgetsDemoApp());
}

class FlutterWidgetsDemoApp extends StatelessWidget {
  const FlutterWidgetsDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '8 个你可能没用过的 Flutter Widget',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const WidgetsDemoHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WidgetsDemoHomePage extends StatefulWidget {
  const WidgetsDemoHomePage({super.key});

  @override
  State<WidgetsDemoHomePage> createState() => _WidgetsDemoHomePageState();
}

class _WidgetsDemoHomePageState extends State<WidgetsDemoHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const SnapshotWidgetDemo(),
    const RepaintBoundaryDemo(),
    const GridPaperDemo(),
    const LayerLinkDemo(),
    const TickerModeDemo(),
    const SensitiveContentDemo(),
    const BlockSemanticsDemo(),
    const BeveledRectangleBorderDemo(),
  ];

  final List<String> _titles = [
    'SnapshotWidget',
    'RepaintBoundary.toImage',
    'GridPaper',
    'LayerLink',
    'TickerMode',
    'SensitiveContent',
    'BlockSemantics',
    'BeveledRectangleBorder',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: _titles
            .asMap()
            .entries
            .map((entry) => BottomNavigationBarItem(
                  icon: Icon(Icons.widgets),
                  label: entry.value,
                ))
            .toList(),
      ),
    );
  }
}

// 1. SnapshotWidget Demo
class SnapshotWidgetDemo extends StatefulWidget {
  const SnapshotWidgetDemo({super.key});

  @override
  State<SnapshotWidgetDemo> createState() => _SnapshotWidgetDemoState();
}

class _SnapshotWidgetDemoState extends State<SnapshotWidgetDemo> {
  final SnapshotController _controller = SnapshotController();
  bool _isSnapshotEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            'SnapshotWidget 可以将复杂的 Widget 转换为静态图像以提升性能',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          SnapshotWidget(
            controller: _controller,
            child: const ExpensiveCircleGrid(),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isSnapshotEnabled = !_isSnapshotEnabled;
                _controller.allowSnapshotting = _isSnapshotEnabled;
              });
            },
            child: Text(_isSnapshotEnabled ? '禁用快照' : '启用快照'),
          ),
          const SizedBox(height: 10),
          Text(
            _isSnapshotEnabled ? '当前显示：静态快照' : '当前显示：实时渲染',
            style: TextStyle(
              color: _isSnapshotEnabled ? Colors.green : Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class ExpensiveCircleGrid extends StatelessWidget {
  const ExpensiveCircleGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: 300,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: CustomPaint(
        painter: CircleGridPainter(),
      ),
    );
  }
}

class CircleGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    const int rows = 10;
    const int cols = 15;
    final double cellWidth = size.width / cols;
    final double cellHeight = size.height / rows;

    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        final center = Offset(
          j * cellWidth + cellWidth / 2,
          i * cellHeight + cellHeight / 2,
        );
        canvas.drawCircle(center, cellWidth / 4, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 2. RepaintBoundary.toImage Demo
class RepaintBoundaryDemo extends StatefulWidget {
  const RepaintBoundaryDemo({super.key});

  @override
  State<RepaintBoundaryDemo> createState() => _RepaintBoundaryDemoState();
}

class _RepaintBoundaryDemoState extends State<RepaintBoundaryDemo> {
  final GlobalKey _boundaryKey = GlobalKey();
  Uint8List? _imageBytes;

  Future<void> _captureImage() async {
    try {
      RenderRepaintBoundary boundary = _boundaryKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      setState(() {
        _imageBytes = byteData!.buffer.asUint8List();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('截图失败: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            'RepaintBoundary.toImage 可以将 Widget 转换为图像',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          RepaintBoundary(
            key: _boundaryKey,
            child: Container(
              color: Colors.blueAccent,
              width: 200,
              height: 200,
              child: const Center(
                child: Text(
                  '截图我！',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _captureImage,
            child: const Text('截图'),
          ),
          const SizedBox(height: 20),
          if (_imageBytes != null) ...[
            const Text('截图结果：'),
            const SizedBox(height: 10),
            Image.memory(
              _imageBytes!,
              width: 150,
              height: 150,
            ),
          ],
        ],
      ),
    );
  }
}

// 3. GridPaper Demo
class GridPaperDemo extends StatefulWidget {
  const GridPaperDemo({super.key});

  @override
  State<GridPaperDemo> createState() => _GridPaperDemoState();
}

class _GridPaperDemoState extends State<GridPaperDemo> {
  bool _showGrid = true;
  double _interval = 50.0;
  int _divisions = 2;
  int _subdivisions = 4;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            'GridPaper 是一个调试工具，可以在 UI 上显示网格',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _showGrid
                ? GridPaper(
                    color: Colors.red,
                    interval: _interval,
                    divisions: _divisions,
                    subdivisions: _subdivisions,
                    child: _buildContent(),
                  )
                : _buildContent(),
          ),
          const SizedBox(height: 20),
          SwitchListTile(
            title: const Text('显示网格'),
            value: _showGrid,
            onChanged: (value) {
              setState(() {
                _showGrid = value;
              });
            },
          ),
          Slider(
            label: '间隔: ${_interval.toInt()}',
            value: _interval,
            min: 20,
            max: 500,
            divisions: 8,
            onChanged: (value) {
              setState(() {
                _interval = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FlutterLogo(size: 80),
          SizedBox(height: 20),
          Text('对齐我！', style: TextStyle(fontSize: 24)),
        ],
      ),
    );
  }
}

// 4. LayerLink Demo
class LayerLinkDemo extends StatefulWidget {
  const LayerLinkDemo({super.key});

  @override
  State<LayerLinkDemo> createState() => _LayerLinkDemoState();
}

class _LayerLinkDemoState extends State<LayerLinkDemo> {
  final LayerLink _layerLink = LayerLink();
  bool _showDropdown = false;
  OverlayEntry? _overlayEntry;

  void _toggleDropdown() {
    if (_showDropdown) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    } else {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
    }
    setState(() {
      _showDropdown = !_showDropdown;
    });
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) => CompositedTransformFollower(
        link: _layerLink,
        showWhenUnlinked: false,
        targetAnchor: Alignment.bottomLeft,
        offset: const Offset(0, 8),
        child: Material(
          elevation: 4.0,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('选项 1'),
                const Divider(),
                const Text('选项 2'),
                const Divider(),
                const Text('选项 3'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            'LayerLink 可以让两个 Widget 保持相对位置关系',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Center(
            child: CompositedTransformTarget(
              link: _layerLink,
              child: ElevatedButton(
                onPressed: _toggleDropdown,
                child: Text(_showDropdown ? '隐藏菜单' : '显示菜单'),
              ),
            ),
          ),
          const SizedBox(height: 40),
          const Text(
            '点击按钮查看下拉菜单效果\n菜单会跟随按钮位置',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// 5. TickerMode Demo
class TickerModeDemo extends StatefulWidget {
  const TickerModeDemo({super.key});

  @override
  State<TickerModeDemo> createState() => _TickerModeDemoState();
}

class _TickerModeDemoState extends State<TickerModeDemo> {
  bool _tickerEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            'TickerMode 可以控制动画的启用/禁用状态',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          TickerMode(
            enabled: _tickerEnabled,
            child: const _AnimationWidget(),
          ),
          const SizedBox(height: 40),
          const CircularProgressIndicator(),
          const SizedBox(height: 40),
          SwitchListTile(
            title: const Text('启用动画'),
            value: _tickerEnabled,
            onChanged: (value) {
              setState(() {
                _tickerEnabled = value;
              });
            },
          ),
          Text(
            _tickerEnabled ? '动画正在运行' : '动画已暂停',
            style: TextStyle(
              color: _tickerEnabled ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimationWidget extends StatefulWidget {
  const _AnimationWidget();

  @override
  State<_AnimationWidget> createState() => _AnimationWidgetState();
}

class _AnimationWidgetState extends State<_AnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // return const CircularProgressIndicator();
        return Transform.rotate(
          angle: _controller.value * 2 * 3.14159,
          child: Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.refresh,
              color: Colors.white,
              size: 40,
            ),
          ),
        );
      },
    );
  }
}

// 6. SensitiveContent Demo
class SensitiveContentDemo extends StatefulWidget {
  const SensitiveContentDemo({super.key});

  @override
  State<SensitiveContentDemo> createState() => _SensitiveContentDemoState();
}

class _SensitiveContentDemoState extends State<SensitiveContentDemo> {
  bool _useSensitiveContent = true;
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Widget passwordField = TextField(
      controller: _passwordController,
      obscureText: true,
      decoration: const InputDecoration(
        labelText: '密码',
        hintText: '输入你的密码',
        border: OutlineInputBorder(),
      ),
    );

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            'SensitiveContent 可以保护敏感信息在录屏时不被显示',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          _useSensitiveContent
              ? Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.orange, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      const Text(
                        '敏感内容区域',
                        style: TextStyle(color: Colors.orange, fontSize: 12),
                      ),
                      // SensitiveContent 在某些 Flutter 版本中可能不可用
                      // 如果编译错误，请注释掉下面的代码并使用 passwordField
                      SensitiveContent(
                        sensitivity: ContentSensitivity.autoSensitive,
                        child: passwordField,
                      ),
                    ],
                  ),
                )
              : passwordField,
          const SizedBox(height: 20),
          SwitchListTile(
            title: const Text('使用 SensitiveContent'),
            subtitle: const Text('在 Android 15+ 上录屏时会被遮挡'),
            value: _useSensitiveContent,
            onChanged: (value) {
              setState(() {
                _useSensitiveContent = value;
              });
            },
          ),
          const SizedBox(height: 20),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                '注意：此功能仅在 Android 15+ 设备上生效。'
                '在录屏或屏幕共享时，被 SensitiveContent 包装的内容会被系统自动遮挡。',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 7. BlockSemantics Demo
class BlockSemanticsDemo extends StatefulWidget {
  const BlockSemanticsDemo({super.key});

  @override
  State<BlockSemanticsDemo> createState() => _BlockSemanticsDemoState();
}

class _BlockSemanticsDemoState extends State<BlockSemanticsDemo> {
  bool _showDialog = false;
  bool _useBlockSemantics = true;

  void _toggleDialog() {
    setState(() {
      _showDialog = !_showDialog;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackgroundContent(),
          if (_showDialog) _buildModalOverlay(),
        ],
      ),
    );
  }

  Widget _buildBackgroundContent() {
    Widget backgroundContent = Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'BlockSemantics 演示：无障碍功能测试',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: const Text(
              '💡 测试方法：\n'
              '1. 开启手机的无障碍服务（如 TalkBack/VoiceOver）\n'
              '2. 显示对话框后，尝试用手指滑动屏幕\n'
              '3. 对比开启/关闭 BlockSemantics 的差异',
              style: TextStyle(fontSize: 14),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            color: _showDialog && _useBlockSemantics
                ? Colors.grey.shade300
                : Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.accessibility,
                        color: _showDialog && _useBlockSemantics
                            ? Colors.grey
                            : Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '背景内容区域',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _showDialog && _useBlockSemantics
                              ? Colors.grey
                              : Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '当对话框显示时，这些内容应该被屏幕阅读器忽略',
                    style: TextStyle(
                      color: _showDialog && _useBlockSemantics
                          ? Colors.grey
                          : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('使用 BlockSemantics'),
            subtitle: Text(
                _useBlockSemantics ? '✅ 背景内容将被屏幕阅读器忽略' : '❌ 背景内容仍可被屏幕阅读器访问'),
            value: _useBlockSemantics,
            onChanged: (value) {
              setState(() {
                _useBlockSemantics = value;
              });
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _toggleDialog,
            icon: Icon(_showDialog ? Icons.visibility_off : Icons.visibility),
            label: Text(_showDialog ? '隐藏对话框' : '显示对话框'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _showDialog ? Colors.red : Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '测试按钮（用于无障碍测试）：',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('背景按钮 1 被点击')),
              );
            },
            child: const Text('📱 背景按钮 1'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('背景按钮 2 被点击')),
              );
            },
            child: const Text('🎯 背景按钮 2'),
          ),
          const SizedBox(height: 8),
          const TextField(
            decoration: InputDecoration(
              labelText: '背景输入框',
              hintText: '测试无障碍焦点',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );

    if (_showDialog && _useBlockSemantics) {
      return BlockSemantics(child: backgroundContent);
    }
    return backgroundContent;
  }

  Widget _buildModalOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(32.0),
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.priority_high,
                      color: Colors.orange,
                      size: 28,
                    ),
                    SizedBox(width: 8),
                    Text(
                      '模态对话框',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '🎯 无障碍测试重点：',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _useBlockSemantics
                            ? '✅ BlockSemantics 已启用\n屏幕阅读器只能访问此对话框'
                            : '❌ BlockSemantics 已禁用\n屏幕阅读器仍可访问背景内容',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _useBlockSemantics
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  '用手指滑动屏幕测试无障碍焦点范围',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _toggleDialog,
                      icon: const Icon(Icons.close),
                      label: const Text('取消'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _toggleDialog,
                      icon: const Icon(Icons.check),
                      label: const Text('确认'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 8. BeveledRectangleBorder Demo
class BeveledRectangleBorderDemo extends StatefulWidget {
  const BeveledRectangleBorderDemo({super.key});

  @override
  State<BeveledRectangleBorderDemo> createState() =>
      _BeveledRectangleBorderDemoState();
}

class _BeveledRectangleBorderDemoState
    extends State<BeveledRectangleBorderDemo> {
  double _borderRadius = 30.0;
  double _borderWidth = 2.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            'BeveledRectangleBorder 创建带有切角效果的矩形边框',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Center(
            child: Container(
              width: 200,
              height: 100,
              decoration: ShapeDecoration(
                color: Colors.blue,
                shape: BeveledRectangleBorder(
                  borderRadius: BorderRadius.circular(_borderRadius),
                  side: BorderSide(
                    color: Colors.purple,
                    width: _borderWidth,
                  ),
                ),
              ),
              child: const Center(
                child: Text(
                  '切角容器',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Text('边框半径: ${_borderRadius.toInt()}'),
          Slider(
            value: _borderRadius,
            min: 0,
            max: 80,
            divisions: 16,
            onChanged: (value) {
              setState(() {
                _borderRadius = value;
              });
            },
          ),
          const SizedBox(height: 20),
          Text('边框宽度: ${_borderWidth.toInt()}'),
          Slider(
            value: _borderWidth,
            min: 0,
            max: 10,
            divisions: 10,
            onChanged: (value) {
              setState(() {
                _borderWidth = value;
              });
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: BeveledRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {},
            child: const Text(
              '切角按钮',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
