import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soulsync/shared/widgets/loading/app_circular_loader.dart';
import 'package:soulsync/shared/widgets/states/app_empty_state.dart';
import 'package:soulsync/shared/widgets/states/app_error_state.dart';

class AsyncView<T> extends StatelessWidget {
  final AsyncValue<T> asyncValue;
  final Widget Function(T data) builder;
  final String? emptyTitle;
  final String? emptyDescription;
  final IconData? emptyIcon;
  final bool Function(T data)? isEmpty;
  final VoidCallback? onRetry;

  const AsyncView({
    super.key,
    required this.asyncValue,
    required this.builder,
    this.emptyTitle,
    this.emptyDescription,
    this.emptyIcon,
    this.isEmpty,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return asyncValue.when(
      data: (data) {
        if (isEmpty != null && isEmpty!(data)) {
          return AppEmptyState(
            title: emptyTitle ?? 'No Data',
            description:
                emptyDescription ?? 'No items available at this moment.',
            icon: emptyIcon ?? Icons.inbox_rounded,
          );
        }
        return builder(data);
      },
      loading: () => const Center(child: AppCircularLoader()),
      error: (error, stackTrace) => Center(
        child: AppErrorState.generic(
          message: error.toString(),
          onRetry: onRetry,
        ),
      ),
    );
  }
}
