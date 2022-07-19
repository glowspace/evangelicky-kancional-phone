import 'package:flutter/material.dart';

class CustomNavigatorObserver extends NavigatorObserver {
  final Function? onNavigationStackChanged;

  final List<String> navigationStack;

  CustomNavigatorObserver({this.onNavigationStackChanged}) : navigationStack = [];

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);

    final name = route.settings.name;

    if (name != null) {
      navigationStack.add(name);

      if (navigationStack.length != 1) onNavigationStackChanged?.call();
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);

    if (route.settings.name != null) {
      navigationStack.removeLast();
      onNavigationStackChanged?.call();
    }
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    super.didRemove(route, previousRoute);

    navigationStack.removeWhere((name) => name == route.settings.name);
    onNavigationStackChanged?.call();
  }
}
