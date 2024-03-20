import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:practice/global/global_value.dart';
import 'package:practice/pages/normal/home_page.dart';
import 'package:practice/pages/normal/home_sub_route_page.dart';
import 'package:practice/pages/normal/login_page.dart';
import 'package:practice/pages/normal/modal_page.dart';
import 'package:practice/pages/normal/normal_page.dart';
import 'package:practice/pages/normal/param_page.dart';
import 'package:practice/pages/normal/sub_route_page.dart';
import 'package:practice/pages/normal/top_route_page.dart';
import 'package:practice/pages/shell/shell_route_app.dart';
import 'package:practice/utils/navigation_history_observer.dart';

import '../pages/custom_error_screen.dart';

class GoRouterHelper {
  static GoRouter getRouter(BuildContext context) {
    commonPageCounter = 0;
    return GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: true,
      navigatorKey: rootNavigatorKey,
      observers: [
        NavigationHistoryObserver.singleInstance,
      ],
      redirect: (BuildContext context, GoRouterState state) {
        if (GlobalValue.isLogin) {
          return null;
        } else {
          return '/login';
        }
      },
      errorBuilder: (context, state) => CustomErrorScreen(state.error),
      // onException: (BuildContext context, GoRouterState state, GoRouter router) {
      //   print('onException: ${state.error}');
      // },
      routes: [
        // top-level route
        GoRoute(
          path: '/',
          builder: (context, state) => const HomePage(),
          routes: [
            // one sub-route
            GoRoute(
              path: 'home_sub_route_page',
              builder: (context, state) => const ModalPage(), // 失效，会使用 pageBuilder
              pageBuilder: (context, state) {
                return CustomTransitionPage(
                  key: state.pageKey,
                  child: const HomeSubRoutePage(),
                  transitionDuration: const Duration(milliseconds: 1000),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: CurveTween(curve: Curves.easeInOutCirc).animate(animation),
                      child: child,
                    );
                  },
                );
              },
            ),
            // another sub-route
            GoRoute(
              path: 'modal_page',
              pageBuilder: (context, state) => const MaterialPage(
                fullscreenDialog: true,
                child: ModalPage(),
              ),
            )
          ],
        ),
        GoRoute(
          path: '/login',
          name: 'login_route',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/normal_page',
          name: 'normal_page_route',
          builder: (context, state) {
            var number = state.uri.queryParameters['number'];
            return NormalPage(number: number);
          },
        ),
        GoRoute(
          path: '/params_page/:id',
          builder: (context, GoRouterState state) {
            final id = state.pathParameters['id']; // Get "id" param from URL
            return ParamsPage(id: id);
          },
        ),
        GoRoute(
          path: '/params_page',
          builder: (context, GoRouterState state) {
            final search = state.uri.queryParameters['search'];
            return ParamsPage(search: search);
          },
        ),
        GoRoute(
          path: '/top_route_page',
          builder: (context, state) => const TopRoutePage(),
          routes: <RouteBase>[
            // Add child routes
            GoRoute(
              path: 'sub_route_page', // NOTE: Don't need to specify "/" character for router’s parents
              builder: (context, state) => const SubRoutePage(),
            ),
          ],
        ),
      ],
    );
  }
}
