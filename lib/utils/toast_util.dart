import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:practice/constants/constants.dart';
import 'package:practice/utils/navigator_util.dart';
import 'package:practice/utils/orientation_util.dart';

enum ToastType {
  normal,
  success,
  warning,
}

CancelFunc showLoading({
  BackButtonBehavior backButtonBehavior = BackButtonBehavior.close,
  bool crossPage = true,
  bool clickClose = false,
  bool allowClick = false,
  int duration = 30,
  VoidCallback? onClose,
  List<CancelToken>? cancelTokenList,
}) {
  return BotToast.showCustomLoading(
    toastBuilder: (_) => const _LoadingWidget(),
    duration: duration == -1 ? null : Duration(seconds: duration),
    onClose: () {
      if (onClose != null) onClose();
    },
    backButtonBehavior: backButtonBehavior,
    backgroundColor: Colors.transparent,
    ignoreContentClick: true,
  );
}

void dismissLoading({CancelToken? cancelToken}) {
  if (cancelToken != null) cancelToken.cancel();
  BotToast.closeAllLoading();
}

void showToast(String? content, {ToastType type = ToastType.normal, Alignment alignment = Alignment.center}) {
  final bool isDarkMode = Theme.of(navigatorKey.currentContext!).brightness == Brightness.dark;
  BotToast.showCustomText(
    duration: const Duration(seconds: 3),
    animationDuration: const Duration(milliseconds: 100),
    onlyOne: true,
    toastBuilder: (CancelFunc cancelFunc) {
      return SafeArea(
        child: Align(
          alignment: alignment,
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF505050) : Colors.black87,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text.rich(
              TextSpan(
                children: <InlineSpan>[
                  WidgetSpan(
                    child: _ToastIcon(type),
                  ),
                  TextSpan(text: content),
                ],
              ),
              style: const TextStyle(fontSize: 14, color: Colors.white),
            ),
          ),
        ),
      );
    },
  );
}

void showNotification({
  UniqueKey? key,
  IconData? icon,
  String? title,
  String? subtitle,
  ValueChanged? onDismiss,
}) {
  BotToast.showAnimationWidget(
    key: key,
    toastBuilder: (CancelFunc cancelFunc) {
      return _NotificationWidget(
        uniqueKey: key,
        icon: icon ?? Icons.notifications,
        title: title ?? '',
        subtitle: subtitle ?? '',
        onDismiss: onDismiss,
      );
    },
    duration: const Duration(seconds: Constants.intercomFcmMessageTTL),
    animationDuration: const Duration(milliseconds: 256),
    wrapToastAnimation: (AnimationController controller, CancelFunc cancelFunc, Widget child) => _NormalAnimation(
      controller: controller,
      child: child,
    ),
  );
}

void dismissNotification(UniqueKey key) {
  BotToast.remove(key);
}

class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: const CircularProgressIndicator(color: Colors.white),
    );
  }
}

class _ToastIcon extends StatelessWidget {
  const _ToastIcon(this.type);

  final ToastType type;

  @override
  Widget build(BuildContext context) {
    if (type == ToastType.normal) return const SizedBox();
    const double iconSize = 16;
    const Color iconColor = Colors.white;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Builder(
        builder: (BuildContext context) {
          switch (type) {
            case ToastType.success:
              return const Icon(Icons.check_circle_outline, size: iconSize, color: iconColor);
            case ToastType.warning:
              return const Icon(Icons.error_outline, size: iconSize, color: iconColor);
            default:
              return const SizedBox();
          }
        },
      ),
    );
  }
}

class _NotificationWidget extends StatelessWidget {
  const _NotificationWidget({
    this.uniqueKey,
    this.icon,
    required this.title,
    required this.subtitle,
    this.onDismiss,
  });

  final UniqueKey? uniqueKey;
  final IconData? icon;
  final String title;
  final String subtitle;

  final ValueChanged? onDismiss;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Dismissible(
      key: uniqueKey ?? UniqueKey(),
      direction: DismissDirection.up,
      behavior: HitTestBehavior.translucent,
      onDismissed: (DismissDirection direction) {
        onDismiss?.call(uniqueKey);
      },
      child: SafeArea(
        child: Container(
          width: screenWidth,
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: OrientationUtil.isPortrait(context) ? screenWidth : 0.35 * screenWidth,
            child: Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: ListTile(
                minLeadingWidth: 0,
                leading: Icon(
                  icon ?? Icons.notifications,
                  size: 24,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                title: Text(
                  title,
                  maxLines: 1,
                  softWrap: false,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  subtitle,
                  maxLines: 1,
                  softWrap: false,
                  style: const TextStyle(
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class _NormalAnimation extends StatefulWidget {
  final Widget child;
  final AnimationController controller;

  const _NormalAnimation({
    required this.child,
    required this.controller,
  });

  @override
  NormalAnimationState createState() => NormalAnimationState();
}

class NormalAnimationState extends State<_NormalAnimation>
    with SingleTickerProviderStateMixin {
  static final Tween<Offset> tweenOffset = Tween<Offset>(
    begin: const Offset(0, -40),
    end: Offset.zero,
  );
  static final Tween<double> tweenOpacity = Tween<double>(begin: 0, end: 1);
  late final Animation<double> animation;

  late final Animation<Offset> animationOffset;
  late final Animation<double> animationOpacity;

  @override
  void initState() {
    animation = CurvedAnimation(parent: widget.controller, curve: Curves.decelerate);
    animationOffset = tweenOffset.animate(animation);
    animationOpacity = tweenOpacity.animate(animation);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (_, Widget? child) {
        return Transform.translate(
          offset: animationOffset.value,
          child: Opacity(
            opacity: animationOpacity.value,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

