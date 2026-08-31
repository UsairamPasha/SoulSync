import 'package:flutter/material.dart';
import 'package:soulsync/shared/widgets/inputs/app_text_field.dart';

/// Reusable Search Input Field component with clear button for SoulSync.
class AppSearchTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  const AppSearchTextField({
    super.key,
    this.controller,
    this.hintText = 'Search tracks, artists, playlists...',
    this.onChanged,
    this.onClear,
  });

  @override
  State<AppSearchTextField> createState() => _AppSearchTextFieldState();
}

class _AppSearchTextFieldState extends State<AppSearchTextField> {
  late final TextEditingController _effectiveController;
  bool _showClear = false;

  @override
  void initState() {
    super.initState();
    _effectiveController = widget.controller ?? TextEditingController();
    _effectiveController.addListener(_onTextChanged);
    _showClear = _effectiveController.text.isNotEmpty;
  }

  void _onTextChanged() {
    final hasText = _effectiveController.text.isNotEmpty;
    if (hasText != _showClear) {
      setState(() {
        _showClear = hasText;
      });
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _effectiveController.dispose();
    } else {
      _effectiveController.removeListener(_onTextChanged);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: _effectiveController,
      hintText: widget.hintText,
      prefixIcon: const Icon(Icons.search_rounded, size: 22),
      suffixIcon: _showClear
          ? IconButton(
              icon: const Icon(Icons.close_rounded, size: 20),
              onPressed: () {
                _effectiveController.clear();
                if (widget.onChanged != null) {
                  widget.onChanged!('');
                }
                if (widget.onClear != null) {
                  widget.onClear!();
                }
              },
            )
          : null,
      onChanged: widget.onChanged,
      textInputAction: TextInputAction.search,
    );
  }
}
