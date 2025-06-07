// Em algum lugar acessível, talvez no seu package ou em um arquivo de utils
import 'package:flutter/material.dart';
import 'package:nav_manager/nav_manager.dart';

extension NavServiceContextExtension on BuildContext {
  NavManagerService get navService => NavManagerService.of(this);
  NavInjector get navInjector => NavManagerService.injectorOf(this);
  T getService<T>() => NavManagerService.getService<T>(this);
}
