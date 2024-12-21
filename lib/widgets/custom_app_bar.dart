import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:practice/pages/go_route/shell/shell_route_app.dart';

class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      actions: [
        IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            rootNavigatorKey.currentContext?.go('/');
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
