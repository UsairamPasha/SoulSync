import 'package:flutter/material.dart';
import 'package:soulsync/core/constants/app_colors.dart';
import 'package:soulsync/core/constants/app_radius.dart';

/// Lightweight, high-performance shimmer loader for SoulSync skeleton states.
class AppShimmer extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final ShapeBorder? shapeBorder;

  const AppShimmer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
    this.shapeBorder,
  });

  const factory AppShimmer.card({
    Key? key,
    double height,
    double width,
  }) = _AppShimmerCard;

  const factory AppShimmer.circle({
    Key? key,
    required double size,
  }) = _AppShimmerCircle;

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.25, end: 0.65).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final color = AppColors.surfaceDarkVariant.withValues(alpha: _animation.value);
        if (widget.shapeBorder != null) {
          return Container(
            width: widget.width,
            height: widget.height,
            decoration: ShapeDecoration(
              color: color,
              shape: widget.shapeBorder!,
            ),
          );
        }
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: widget.borderRadius ?? AppRadius.borderMD,
          ),
        );
      },
    );
  }
}

class _AppShimmerCard extends AppShimmer {
  const _AppShimmerCard({
    super.key,
    super.height = 100,
    super.width = double.infinity,
  }) : super(borderRadius: AppRadius.borderLG);
}

class _AppShimmerCircle extends AppShimmer {
  const _AppShimmerCircle({
    super.key,
    required double size,
  }) : super(width: size, height: size, shapeBorder: const CircleBorder());
}
