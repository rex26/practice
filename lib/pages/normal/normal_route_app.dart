import 'package:flutter/material.dart';
import 'package:practice/helper/go_router_helper.dart';
final GlobalKey<NavigatorState> globalNavigator = GlobalKey<NavigatorState>();
class NormalRouteApp extends StatelessWidget {
  const NormalRouteApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routerConfig: GoRouterHelper.getRouter(context),
    );
  }
}