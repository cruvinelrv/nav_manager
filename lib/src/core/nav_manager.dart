import 'package:flutter/material.dart';

import '../../nav_manager.dart';

abstract class NavManager extends StatelessWidget {
  final NavModule module; // Propriedade para o módulo
  final Widget child; // Propriedade para o widget principal

  const NavManager({
    super.key,
    required this.module,
    required this.child,
  });

  @override
  Widget build(BuildContext context);
}
