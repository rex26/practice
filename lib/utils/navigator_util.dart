import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:practice/constants/app_routes.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<U?> pushToScreen<U extends Object>(
    BuildContext? context,
    Widget screen, {
      bool useFadeRoute = false,
      String? routeName,
    }) async {
  if (context == null) return null;

  final NavigatorState navigator = Navigator.of(context, rootNavigator: true);
  final RouteSettings settings = RouteSettings(
    name: routeName ?? AppRoutes.nameFor(screen.runtimeType),
  );

  final PageRoute<U> route = useFadeRoute
      ? FadeRoute<U>(page: screen, settings: settings)
      : CupertinoPageRoute<U>(
    builder: (_) => screen,
    settings: settings,
  );

  return navigator.push(route);
}

Future<U?> pushScreenWithoutContext<U extends Object>(Widget screen) async {
  final BuildContext? context = navigatorKey.currentState?.context;
  if (context == null) {
    return null;
  }
  return Navigator.of(context).push(
    CupertinoPageRoute<U>(
      builder: (_) => screen,
      settings: RouteSettings(name: AppRoutes.nameFor(screen.runtimeType)),
    ),
  );
}

void popWithoutContext<T extends Object?>([T? result]) {
  final BuildContext? context = navigatorKey.currentState?.context;
  if (context == null) {
    return;
  }
  Navigator.of(context).pop(result);
}

void popToHomeWithoutContext<T extends Object?>([T? result]) {
  final BuildContext? context = navigatorKey.currentState?.context;
  if (context == null) {
    return;
  }
  if (Navigator.canPop(context)) {
    Navigator.of(context).popUntil((Route<dynamic> route) => route.isFirst);
  }
}

Future<T?> pushAndRemoveUntil<T extends Object>(BuildContext context, Widget screen) {
  return Navigator.pushAndRemoveUntil(
    context,
    CupertinoPageRoute<T>(
      builder: (BuildContext context) => screen,
      settings: RouteSettings(name: AppRoutes.nameFor(screen.runtimeType)),
    ),
    (Route<dynamic> route) => false,
  );
}

Future<T?> pushReplacement<T extends Object>(BuildContext context, Widget screen, {T? result}) {
  return Navigator.pushReplacement(
    context,
    CupertinoPageRoute<T>(
      builder: (BuildContext context) => screen,
      settings: RouteSettings(name: AppRoutes.nameFor(screen.runtimeType)),
    ),
    result: result,
  );
}

void pushNamedAndRemoveUntil(BuildContext context, {String newRouteName = AppRoutes.home}) {
  unawaited(Navigator.pushNamedAndRemoveUntil(
    context,
    newRouteName,
    (Route<dynamic> route) => false,
  ));
}

/// main target is replacing code: [pushNamedAndRemoveUntil]
void backToHomePage(BuildContext context, {bool alwaysCreate = false}) {
  unawaited(
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
      (Route<dynamic> route) => false,
    ),
  );
}

class FadeRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  FadeRoute({super.settings, required this.page})
      : super(
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
}

class NavigatorUtil {
  NavigatorUtil._();

  static String? getTopRouteName() {
    final NavigationHistoryObserver historyObserver = NavigationHistoryObserver.singleInstance;
    if (historyObserver.history.isEmpty) {
      return null;
    }

    return historyObserver.top?.settings.name;
  }

  static MediaQueryData? get mediaQueryData {
    final BuildContext? context = navigatorKey.currentContext;
    return context != null ? MediaQuery.of(context) : null;
  }

  static double get paddingTop {
    final MediaQueryData? mediaQueryData = NavigatorUtil.mediaQueryData;
    return mediaQueryData?.viewPadding.top ?? 0;
  }

  static double get paddingBottom {
    final MediaQueryData? mediaQueryData = NavigatorUtil.mediaQueryData;
    return mediaQueryData?.viewPadding.bottom ?? 0;
  }

  static EdgeInsetsGeometry safePadding({
    double vertical = 0.0,
    double horizontal = 0.0,
    bool includeTop = false,
    bool includeBottom = true,
  }) {
    return EdgeInsets.only(
      left: horizontal,
      top: vertical + (includeTop ? paddingTop : 0),
      right: horizontal,
      bottom: vertical + (includeBottom ? paddingBottom : 0),
    );
  }
}

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
  List<Route<dynamic>> get poppedRoutes => List<Route<dynamic>>.from(_poppedRoutes);

  /// Gets the next route in the navigation history, which is the most recently popped route.
  Route<dynamic>? get next => _poppedRoutes.last;

  static final NavigationHistoryObserver _singleton = NavigationHistoryObserver._internal();

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
    final int oldRouteIndex = _history.indexOf(oldRoute);
    _history.replaceRange(
      oldRouteIndex,
      oldRouteIndex + 1,
      <Route<dynamic>?>[newRoute],
    );
  }

  bool containRouteName(String routeName) {
    final int index = history.indexWhere((Route<dynamic> route) {
      return routeName == route.settings.name;
    });
    return 0 <= index;
  }

  String? previousRouteName(String routeName) {
    final int preIndex = history.indexWhere((Route<dynamic> e) => routeName == e.settings.name) - 1;
    if (0 <= preIndex) {
      return history[preIndex].settings.name;
    }
    return null;
  }
}
