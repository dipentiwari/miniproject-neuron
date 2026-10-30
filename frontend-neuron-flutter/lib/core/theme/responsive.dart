import 'package:flutter/material.dart';

/// Responsive helper class providing standard breakpoints and constraints
/// for Mobile (<600px), Tablet (600px - 1023px), and Desktop (>=1024px).
class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const Responsive({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 1024.0;
  static const double maxContentWidth = 1240.0;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mobileBreakpoint;

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= mobileBreakpoint &&
      MediaQuery.sizeOf(context).width < tabletBreakpoint;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tabletBreakpoint;

  static bool isNarrow(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 380;

  static double screenWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.sizeOf(context).height;

  static EdgeInsets screenPadding(BuildContext context) {
    final width = screenWidth(context);
    if (width < 380) {
      return const EdgeInsets.symmetric(horizontal: 12, vertical: 12);
    } else if (width < mobileBreakpoint) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 16);
    } else if (width < tabletBreakpoint) {
      return const EdgeInsets.symmetric(horizontal: 24, vertical: 20);
    } else {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 24);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= tabletBreakpoint) {
      return desktop;
    } else if (width >= mobileBreakpoint && tablet != null) {
      return tablet!;
    } else {
      return mobile;
    }
  }
}

