
import 'package:flutter/material.dart';
import 'package:practice/pages/go_route/normal/normal_route_app.dart';
import 'package:practice/pages/go_route/safe/type_safe_route_app.dart';
import 'package:practice/pages/go_route/shell/shell_route_app.dart';

class GoRouteApp extends StatefulWidget {
  const GoRouteApp({Key? key}) : super(key: key);

  @override
  State<GoRouteApp> createState() => _GoRouteAppState();
}

class _GoRouteAppState extends State<GoRouteApp> {
  String _routeType = '';

  @override
  Widget build(BuildContext context) {
    print(const String.fromEnvironment('ENV'));

    switch (_routeType) {
      case 'Normal Route App':
        return const NormalRouteApp();
      case 'Shell Route App':
        return ShellRouteExampleApp();
      case 'Safe Route App':
        return TypeSafeRouteApp();
    }
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Demo Home Page'),
        ),
        body: Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _routeType = 'Normal Route App';
                  });
                },
                child: const Text('Normal Route App'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _routeType = 'Shell Route App';
                  });
                },
                child: const Text('Shell Route App'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _routeType = 'Safe Route App';
                  });
                },
                child: const Text('Safe Route App'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}