import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../core/services/native_bridge.dart';
import '../screens/app_selection_page.dart';

class MonitoringSetupDialog extends StatefulWidget {
  const MonitoringSetupDialog({super.key});

  @override
  State<MonitoringSetupDialog> createState() => _MonitoringSetupDialogState();
}

class _MonitoringSetupDialogState extends State<MonitoringSetupDialog>
    with WidgetsBindingObserver {
  bool _isNotificationPermissionGranted = false;
  bool _isAccessibilityPermissionGranted = false;
  bool _isSmsPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions() async {
    final notificationStatus = await NativeBridge.checkNotificationPermission();
    final accessibilityStatus =
        await NativeBridge.checkAccessibilityPermission();
    final smsStatus = await NativeBridge.checkSmsPermission();

    if (mounted) {
      setState(() {
        _isNotificationPermissionGranted = notificationStatus;
        _isAccessibilityPermissionGranted = accessibilityStatus;
        _isSmsPermissionGranted = smsStatus;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Auto-Detection Setup'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'To automatically detect transactions, we need specific permissions. We only monitor the apps you select.',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 20),
          _buildPermissionStep(
            '1. Notification Access',
            'Allows us to read transaction alerts from bank and payment apps.',
            _isNotificationPermissionGranted,
            () async {
              await NativeBridge.requestNotificationPermission();
            },
          ),
          const SizedBox(height: 12),
          _buildPermissionStep(
            '2. SMS Permission',
            'Enables reading transaction SMS from your bank.',
            _isSmsPermissionGranted,
            () async {
              await NativeBridge.requestSmsPermission();
            },
          ),
          const SizedBox(height: 12),
          _buildPermissionStep(
            '3. Accessibility Service',
            'Enables screen-based detection for selected payment apps.',
            _isAccessibilityPermissionGranted,
            () async {
              await NativeBridge.requestAccessibilityPermission();
            },
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline,
                    color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'IMPORTANT: You MUST select the apps you want to monitor in the next step.',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: (_isNotificationPermissionGranted ||
                  _isAccessibilityPermissionGranted ||
                  _isSmsPermissionGranted)
              ? () {
                  Navigator.pop(context, true);
                  // Navigate to app selection
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AppSelectionPage()),
                  );
                }
              : null,
          child: const Text('Finish & Select Apps'),
        ),
      ],
    );
  }

  Widget _buildPermissionStep(
    String title,
    String description,
    bool isGranted,
    VoidCallback onGrant,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(description,
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
        const SizedBox(width: 10),
        if (isGranted)
          const Icon(Icons.check_circle, color: Colors.green)
        else
          ElevatedButton(
            onPressed: onGrant,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: const Size(80, 40),
            ),
            child: const Text('Grant'),
          ),
      ],
    );
  }
}
