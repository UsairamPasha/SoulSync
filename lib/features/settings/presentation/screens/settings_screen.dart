import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soulsync/core/constants/app_colors.dart';
import 'package:soulsync/core/constants/app_spacing.dart';
import 'package:soulsync/features/auth/presentation/providers/auth_provider.dart';
import 'package:soulsync/features/room/presentation/providers/room_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _crossfadeEnabled = true;
  bool _gaplessPlayback = true;
  bool _backgroundSync = true;
  bool _driftCorrection = true;
  bool _darkMode = true;
  bool _notificationsEnabled = true;
  String _audioQuality = 'High-Res (320kbps)';

  void _showClearCacheDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Audio Cache'),
        content: const Text('This will free up local temporary audio buffers. Your queue and listening session will remain intact.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Local audio cache cleared successfully.')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Clear Cache'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out of SoulSync?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authNotifierProvider.notifier).logout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authUser = ref.watch(authNotifierProvider).user;
    final roomState = ref.watch(roomNotifierProvider);
    final theme = Theme.of(context);

    final roomCode = roomState.room?.inviteCode ?? 'soul_sync_room_default';
    final partnerOnline = roomState.members.any((m) => m.isOnline);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: ListView(
          padding: AppSpacing.paddingMD,
          children: [
            // User Profile Section
            Card(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        authUser?.displayName.isNotEmpty == true ? authUser!.displayName[0].toUpperCase() : 'U',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            authUser?.displayName ?? 'SoulSync Partner',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            authUser?.email ?? 'partner@soulsync.app',
                            style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: partnerOnline ? Colors.green.withValues(alpha: 0.2) : Colors.orange.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  partnerOnline ? 'Partner Connected' : 'Room Active',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: partnerOnline ? Colors.green : Colors.orange,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Code: $roomCode',
                                style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Audio & Playback Section
            const Text(
              'AUDIO & PLAYBACK',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: AppColors.primary),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.high_quality_rounded, color: AppColors.primary),
              title: const Text('Audio Stream Quality'),
              subtitle: Text(_audioQuality),
              trailing: PopupMenuButton<String>(
                initialValue: _audioQuality,
                onSelected: (val) => setState(() => _audioQuality = val),
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'Standard (128kbps)', child: Text('Standard (128kbps)')),
                  PopupMenuItem(value: 'High-Res (320kbps)', child: Text('High-Res (320kbps)')),
                  PopupMenuItem(value: 'Lossless FLAC', child: Text('Lossless FLAC')),
                ],
              ),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.waves_rounded, color: AppColors.primary),
              title: const Text('Crossfade Transitions'),
              subtitle: const Text('Smoothly blend between queue tracks'),
              value: _crossfadeEnabled,
              onChanged: (val) => setState(() => _crossfadeEnabled = val),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.queue_music_rounded, color: AppColors.primary),
              title: const Text('Gapless Playback'),
              subtitle: const Text('Eliminate silent gaps between songs'),
              value: _gaplessPlayback,
              onChanged: (val) => setState(() => _gaplessPlayback = val),
            ),
            const Divider(height: 32),

            // Room Synchronization Section
            const Text(
              'ROOM SYNCHRONIZATION',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: AppColors.primary),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              secondary: const Icon(Icons.sync_rounded, color: AppColors.primary),
              title: const Text('Background Audio Sync'),
              subtitle: const Text('Maintain room playback when app is minimized'),
              value: _backgroundSync,
              onChanged: (val) => setState(() => _backgroundSync = val),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.av_timer_rounded, color: AppColors.primary),
              title: const Text('Auto Drift Correction'),
              subtitle: const Text('Auto-correct playback timing within <50ms'),
              value: _driftCorrection,
              onChanged: (val) => setState(() => _driftCorrection = val),
            ),
            const Divider(height: 32),

            // App Preferences & Storage Section
            const Text(
              'PREFERENCES & STORAGE',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: AppColors.primary),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              secondary: const Icon(Icons.dark_mode_rounded, color: AppColors.primary),
              title: const Text('Dark Mode / OLED Theme'),
              value: _darkMode,
              onChanged: (val) => setState(() => _darkMode = val),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.notifications_active_rounded, color: AppColors.primary),
              title: const Text('Push Notifications'),
              subtitle: const Text('Partner invitations & chat alerts'),
              value: _notificationsEnabled,
              onChanged: (val) => setState(() => _notificationsEnabled = val),
            ),
            ListTile(
              leading: const Icon(Icons.cleaning_services_rounded, color: AppColors.primary),
              title: const Text('Clear Temporary Audio Cache'),
              subtitle: const Text('Free up local storage space'),
              onTap: _showClearCacheDialog,
            ),
            const Divider(height: 32),

            // About & App Details
            Center(
              child: Column(
                children: [
                  const Icon(Icons.favorite_rounded, color: AppColors.primary, size: 32),
                  const SizedBox(height: 8),
                  const Text('SoulSync', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('Synchronized Audio for Couples', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text('v2.4.8 (Build 108)', style: TextStyle(color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6), fontSize: 11)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Logout Button
            ElevatedButton.icon(
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Sign Out'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _showLogoutDialog,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
