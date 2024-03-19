import 'package:flutter/material.dart';
import 'package:practice/pages/normal/normal_route_app.dart';
import 'package:practice/pages/shell/shell_route_app.dart';

void main() {
  bool isShellRoute = false;
  runApp(isShellRoute ? ShellRouteExampleApp() : NormalRouteApp());
}
