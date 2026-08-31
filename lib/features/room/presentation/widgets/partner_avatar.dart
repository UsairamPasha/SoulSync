import 'package:flutter/material.dart';
import 'package:soulsync/core/constants/app_colors.dart';
import 'package:soulsync/core/extensions/context_extensions.dart';

class PartnerAvatar extends StatefulWidget {
  final String name;
  final bool isOnline;
  final double size;

  const PartnerAvatar({
    super.key,
    required this.name,
    this.isOnline = true,
    this.size = 64.0,
  });

  @override
  State<PartnerAvatar> createState() => _PartnerAvatarState();
}

class _PartnerAvatarState extends State<PartnerAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    if (widget.isOnline) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant PartnerAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOnline != oldWidget.isOnline) {
      if (widget.isOnline) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final glowScale = 1.0 + (_pulseController.value * 0.12);

        return Stack(
          alignment: Alignment.center,
          children: [
            if (widget.isOnline)
              Transform.scale(
                scale: glowScale,
                child: Container(
                  width: widget.size + 12,
                  height: widget.size + 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.25),
                  ),
                ),
              ),
            Container(
              width: widget.size,
              height: widget.size,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.accent],
                ),
              ),
              child: Center(
                child: Text(
                  widget.name.isNotEmpty ? widget.name[0].toUpperCase() : 'P',
                  style: context.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 2,
              bottom: 2,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: widget.isOnline ? Colors.green : Colors.grey,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
