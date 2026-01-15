import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

CustomTransitionPage<dynamic> slideTransition({
  required GoRouterState state,
  required Widget child,
  bool toLeft = true,
}) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          end: Offset.zero,
          begin: toLeft ? const Offset(1.5, 0.0) : const Offset(-1.5, 0.0),
        ).animate(animation),
        child: child,
      );
    },
  );
}
