import 'package:flutter/material.dart';

class NavRouteInformationParser
    extends RouteInformationParser<RouteInformation> {
  @override
  Future<RouteInformation> parseRouteInformation(
      RouteInformation routeInformation) async {
    final uri = routeInformation.uri;

    return RouteInformation(uri: uri);
  }

  @override
  RouteInformation restoreRouteInformation(RouteInformation configuration) {
    return configuration;
  }
}
