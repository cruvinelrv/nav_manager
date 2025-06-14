import 'package:flutter/widgets.dart';

class NavRoute {
  final WidgetBuilder builder;
  const NavRoute({
    required this.builder,
  });
  @override
  String toString() {
    return 'NavRoute(builder: $builder)';
  }
}
