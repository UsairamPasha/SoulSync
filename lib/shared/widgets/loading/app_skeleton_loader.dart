import 'package:flutter/material.dart';
import 'package:soulsync/core/constants/app_radius.dart';
import 'package:soulsync/core/constants/app_spacing.dart';
import 'package:soulsync/core/extensions/context_extensions.dart';

/// Reusable Skeleton Shimmer Placeholder loader for track items and lists in SoulSync.
class AppSkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const AppSkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  static Widget listTile({Key? key}) {
    return AppSkeletonTile(key: key);
  }

  @override
  State<AppSkeletonLoader> createState() => _AppSkeletonLoaderState();
}

class _AppSkeletonLoaderState extends State<AppSkeletonLoader>
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
    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(_controller);
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
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: context.colorScheme.surfaceContainerHighest
                .withValues(alpha: _animation.value),
            borderRadius: widget.borderRadius ?? AppRadius.borderMD,
          ),
        );
      },
    );
  }
}

/// Helper skeleton tile representing a loading music track item.
class AppSkeletonTile extends StatelessWidget {
  const AppSkeletonTile({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(
          vertical: AppSpacing.xs, horizontal: AppSpacing.md),
      child: Row(
        children: [
          AppSkeletonLoader(width: 52, height: 52),
          AppSpacing.hGapMD,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSkeletonLoader(width: double.infinity, height: 16),
                AppSpacing.vGapXS,
                AppSkeletonLoader(width: 120, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
