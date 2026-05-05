import 'package:flutter/material.dart';

class NavigationService {
  NavigationService._();
  static final NavigationService instance = NavigationService._();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  Future<dynamic>? navigateTo(String routeName, {Object? arguments}){
    return navigatorKey.currentState
    ?.pushNamed(routeName, arguments: arguments);
  }

  Future<dynamic>? pushReplacement(String routeName, {Object? arguments}) {
    return navigatorKey.currentState
        ?.pushReplacementNamed(routeName, arguments: arguments);
  }
  Future<dynamic>? pushAndRemoveUntil(String routeName, {Object? arguments}) {
    return navigatorKey.currentState
        ?.pushNamedAndRemoveUntil(routeName, (route) => false, arguments: arguments);
  }
  bool goBack<T extends Object?>([T? result]){
    if (navigatorKey.currentState?.canPop()??false){
      navigatorKey.currentState?.pop(result);
      return true;
    }
    return false;
  }
}