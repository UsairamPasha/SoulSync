import 'package:flutter/material.dart';
import 'package:soulsync/core/constants/app_colors.dart';

class AnimatedCoverArt extends StatefulWidget {
  final bool isPlaying;
  final String? songId;
  final double size;

  const AnimatedCoverArt({
    super.key,
    required this.isPlaying,
    this.songId,
    this.size = 240.0,
  });

  @override
  State<AnimatedCoverArt> createState() => _AnimatedCoverArtState();
}

class _AnimatedCoverArtState extends State<AnimatedCoverArt>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );
    if (widget.isPlaying) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedCoverArt oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.accent,
              AppColors.primaryDark,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 24,
              spreadRadius: 4,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Container(
            width: widget.size * 0.32,
            height: widget.size * 0.32,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.music_note_rounded,
              size: widget.size * 0.18,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}
