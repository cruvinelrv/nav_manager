import 'package:flutter/material.dart';

class NavRouteInformationParser extends RouteInformationParser<String> {
  @override
  Future<String> parseRouteInformation(
      RouteInformation routeInformation) async {
    final uri = routeInformation.uri;

    return uri.path.isNotEmpty ? uri.path : '/';
  }

  @override
  RouteInformation restoreRouteInformation(String configuration) {
    return RouteInformation(uri: Uri.parse(configuration));
  }
}
