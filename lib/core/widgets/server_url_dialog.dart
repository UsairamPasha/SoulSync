import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soulsync/core/config/app_config.dart';
import 'package:soulsync/core/constants/app_colors.dart';
import 'package:soulsync/core/network/dio_client.dart';
import 'package:soulsync/core/storage/server_url_storage_service.dart';
import 'package:soulsync/features/playback/presentation/providers/playback_session_provider.dart';
import 'package:soulsync/features/player/presentation/providers/player_provider.dart';
import 'package:soulsync/features/realtime/presentation/providers/realtime_providers.dart';

class ServerUrlDialog extends ConsumerStatefulWidget {
  const ServerUrlDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const ServerUrlDialog(),
    );
  }

  @override
  ConsumerState<ServerUrlDialog> createState() => _ServerUrlDialogState();
}

class _ServerUrlDialogState extends ConsumerState<ServerUrlDialog> {
  late TextEditingController _urlController;
  bool _isTesting = false;
  bool _isSaving = false;
  String? _statusMessage;
  bool? _testSuccess;

  @override
  void initState() {
    super.initState();
    final activeUrl = ref.read(activeServerUrlNotifierProvider);
    _urlController = TextEditingController(text: activeUrl);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.trim().isNotEmpty) {
      final clean = ServerUrlStorageService.cleanUrl(data.text!);
      setState(() {
        _urlController.text = clean;
        _statusMessage = null;
        _testSuccess = null;
      });
    }
  }

  Future<bool> _testConnection(String rawUrl) async {
    final cleanUrl = ServerUrlStorageService.cleanUrl(rawUrl);
    setState(() {
      _isTesting = true;
      _statusMessage = 'Testing connection...';
      _testSuccess = null;
    });

    try {
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 8),
      ));
      final resp = await dio.get<Map<String, dynamic>>(
        '$cleanUrl/api/v1/health/',
        options: Options(headers: {
          'ngrok-skip-browser-warning': '69420',
          'User-Agent': 'SoulSyncApp/1.0',
        }),
      );

      final isOk = resp.statusCode == 200;
      if (mounted) {
        setState(() {
          _isTesting = false;
          _testSuccess = isOk;
          _statusMessage = isOk
              ? '✅ Connection Successful! (Server Healthy)'
              : '⚠️ Connection warning: HTTP ${resp.statusCode}';
        });
      }
      return isOk;
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTesting = false;
          _testSuccess = false;
          _statusMessage = '❌ Could not connect: Check URL or internet';
        });
      }
      return false;
    }
  }

  Future<void> _saveAndApply() async {
    final rawUrl = _urlController.text.trim();
    if (rawUrl.isEmpty) return;

    setState(() => _isSaving = true);
    final cleanUrl = ServerUrlStorageService.cleanUrl(rawUrl);

    final isConnected = await _testConnection(cleanUrl);

    final success = await ref
        .read(activeServerUrlNotifierProvider.notifier)
        .updateUrl(cleanUrl);

    if (success && mounted) {
      // Invalidate network & websocket providers to apply new URL
      ref.invalidate(dioClientProvider);
      ref.invalidate(musicRepositoryProvider);
      ref.invalidate(webSocketServiceProvider);
      ref.invalidate(playbackSessionNotifierProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Server URL updated to: $cleanUrl'),
          backgroundColor: isConnected ? Colors.green : AppColors.primary,
        ),
      );
      Navigator.of(context).pop();
    }
    if (mounted) setState(() => _isSaving = false);
  }

  Future<void> _resetDefault() async {
    await ref.read(activeServerUrlNotifierProvider.notifier).resetToDefault();
    final defaultUrl = ref.read(activeServerUrlNotifierProvider);
    setState(() {
      _urlController.text = defaultUrl;
      _statusMessage = 'Reset to default Cloudflare Tunnel URL.';
      _testSuccess = null;
    });
    ref.invalidate(dioClientProvider);
    ref.invalidate(musicRepositoryProvider);
    ref.invalidate(webSocketServiceProvider);
    ref.invalidate(playbackSessionNotifierProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: const Color(0xFF1E1E2E),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.dns_rounded,
                        color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Backend Server URL',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Update when Cloudflare URL changes',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _urlController,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  labelText: 'Cloudflare Tunnel Domain',
                  labelStyle: const TextStyle(color: Colors.white60),
                  hintText: 'https://xxx.trycloudflare.com',
                  hintStyle: const TextStyle(color: Colors.white30),
                  filled: true,
                  fillColor: const Color(0xFF2A2A3D),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.content_paste_rounded,
                        color: AppColors.primary),
                    tooltip: 'Paste from clipboard',
                    onPressed: _pasteFromClipboard,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (_statusMessage != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _testSuccess == true
                        ? Colors.green.withOpacity(0.15)
                        : _testSuccess == false
                            ? Colors.red.withOpacity(0.15)
                            : AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _statusMessage!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _testSuccess == true
                          ? Colors.greenAccent
                          : _testSuccess == false
                              ? Colors.redAccent
                              : Colors.white,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: _isTesting ? null : () => _testConnection(_urlController.text),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                    ),
                    child: _isTesting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Test Link'),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _resetDefault,
                    child: const Text(
                      'Reset',
                      style: TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveAndApply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 4,
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Save & Connect',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
