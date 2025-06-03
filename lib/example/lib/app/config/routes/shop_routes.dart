import 'package:flutter/material.dart';
import 'package:nav_manager/example/lib/app/domains/domain_screen.dart';

/// Define as rotas relacionadas à Loja.
Map<String, Widget Function()> shopRoutes() {
  return {
    '/products': () => DomainScreen(
          title: 'Products',
          domain: 'Shop',
          icon: Icons.shopping_bag,
          color: Colors.orange,
        ),
    '/cart': () => DomainScreen(
          title: 'Cart',
          domain: 'Shop',
          icon: Icons.shopping_cart,
          color: Colors.orange,
        ),
  };
}
