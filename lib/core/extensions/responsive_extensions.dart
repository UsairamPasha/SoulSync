import 'package:flutter/material.dart';
import 'package:soulsync/core/constants/app_breakpoints.dart';

/// Extension on [BuildContext] for responsive layout helpers.
extension ResponsiveExtensions on BuildContext {
  bool get isPhone => MediaQuery.of(this).size.width < AppBreakpoints.phone;
  bool get isTablet =>
      MediaQuery.of(this).size.width >= AppBreakpoints.phone &&
      MediaQuery.of(this).size.width < AppBreakpoints.tablet;
  bool get isDesktop => MediaQuery.of(this).size.width >= AppBreakpoints.tablet;

  T responsiveValue<T>({
    required T phone,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop && desktop != null) return desktop;
    if (isTablet && tablet != null) return tablet;
    return phone;
  }
}

/// Widget builder for constructing responsive layouts.
class AppResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, BoxConstraints constraints) phone;
  final Widget Function(BuildContext context, BoxConstraints constraints)?
      tablet;
  final Widget Function(BuildContext context, BoxConstraints constraints)?
      desktop;

  const AppResponsiveBuilder({
    super.key,
    required this.phone,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= AppBreakpoints.tablet && desktop != null) {
          return desktop!(context, constraints);
        }
        if (constraints.maxWidth >= AppBreakpoints.phone && tablet != null) {
          return tablet!(context, constraints);
        }
        return phone(context, constraints);
      },
    );
  }
}
