import 'package:flutter/widgets.dart';

class NavigationHistoryObserver extends NavigatorObserver {
  /// A list of all the past routes
  final List<Route<dynamic>?> _history = <Route<dynamic>?>[];

  /// Gets a clone of the navigation history as an immutable list.
  List<Route<dynamic>> get history => List<Route<dynamic>>.from(_history);

  /// Gets the top route in the navigation stack.
  Route<dynamic>? get top => _history.last;

  /// A list of all routes that were popped to reach the current.
  final List<Route<dynamic>?> _poppedRoutes = <Route<dynamic>?>[];

  /// Gets a clone of the popped routes as an immutable list.
  List<Route<dynamic>> get poppedRoutes =>
      List<Route<dynamic>>.from(_poppedRoutes);

  /// Gets the next route in the navigation history, which is the most recently popped route.
  Route<dynamic>? get next => _poppedRoutes.last;

  static final NavigationHistoryObserver _singleton =
      NavigationHistoryObserver._internal();

  NavigationHistoryObserver._internal();

  static NavigationHistoryObserver get singleInstance => _singleton;

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _poppedRoutes.add(_history.last);
    _history.removeLast();
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _history.add(route);
    _poppedRoutes.remove(route);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _history.remove(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    var oldRouteIndex = _history.indexOf(oldRoute);
    _history.replaceRange(oldRouteIndex, oldRouteIndex + 1, [newRoute]);
  }

  bool containRouteName(String routeName) {
    var index = history.indexWhere((route) {
      return routeName == route.settings.name;
    });
    return 0 <= index;
  }

  String? previousRouteName(String routeName) {
    int preIndex = history.indexWhere((e) => routeName == e.settings.name) - 1;
    if (0 <= preIndex) {
      return history[preIndex].settings.name;
    }
    return null;
  }
}
