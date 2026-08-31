import 'package:flutter/material.dart';
import 'package:soulsync/shared/widgets/cards/app_base_card.dart';

/// Legacy alias for AppBaseCard maintaining backwards compatibility.
class CustomCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  const CustomCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return AppBaseCard(
      onTap: onTap,
      padding: padding,
      child: child,
    );
  }
}
