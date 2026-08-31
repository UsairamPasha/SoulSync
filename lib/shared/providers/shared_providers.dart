import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soulsync/shared/models/user_model.dart';

/// Provider for holding current authenticated user state across features.
final currentUserProvider = StateProvider<UserModel?>((ref) => null);

/// Provider for global audio synchronization status.
final isSyncedProvider = StateProvider<bool>((ref) => false);

/// Provider for global active theme mode (Dark by default for audio streaming experience).
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);
