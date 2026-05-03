import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../core/view_models/theme_view_model.dart';
import '../core/const/app_dimensions.dart';
import '../core/const/app_colors.dart';

class RequestMoneyDialog extends StatelessWidget {
  final String personName;
  final double amount;
  final GlobalKey _qrKey = GlobalKey();

  RequestMoneyDialog({
    super.key,
    required this.personName,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final themeViewModel = context.watch<ThemeViewModel>();
    final upiId = themeViewModel.upiId;
    final upiName = themeViewModel.upiName ?? 'Recipient';
    final theme = Theme.of(context);

    if (upiId == null || upiId.isEmpty) {
      return AlertDialog(
        title: const Text('UPI ID Missing'),
        content: const Text(
          'Please set your UPI ID in Settings to request money via QR code.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigation to settings is handled by the caller or we can use a callback
            },
            child: const Text('Open Settings'),
          ),
        ],
      );
    }

    // Construct UPI URI
    // upi://pay?pa=upiid@bank&pn=Name&am=100.00&cu=INR
    final upiUri = 'upi://pay?pa=$upiId&pn=${Uri.encodeComponent(upiName)}&am=${amount.toStringAsFixed(2)}&cu=INR';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusXLarge),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Request Money',
              style: GoogleFonts.dmSans(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Requesting from $personName',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            RepaintBoundary(
              key: _qrKey,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: QrImageView(
                  data: upiUri,
                  version: QrVersions.auto,
                  size: 200.0,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '₹ ${amount.toStringAsFixed(2)}',
              style: GoogleFonts.dmSans(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: AppColors.accentGreen,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'UPI ID: $upiId',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: upiUri));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Payment link copied!')),
                      );
                    },
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    label: const Text('Link'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _shareQrImage(context),
                    icon: const Icon(Icons.share_rounded, size: 18),
                    label: const Text('Share QR'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareQrImage(BuildContext context) async {
    try {
      final boundary =
          _qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final pngBytes = byteData.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/upi_qr_${DateTime.now().millisecondsSinceEpoch}.png').create();
      await file.writeAsBytes(pngBytes);

      final result = await SharePlus.instance.share(ShareParams(
        files: [XFile(file.path)],
        text: 'Pay via UPI QR for $personName',
        subject: 'UPI Payment Link',
      ));

      if (result.status == ShareResultStatus.success) {
        debugPrint('Sharing success!');
      }
    } catch (e) {
      debugPrint('Error sharing QR: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share QR image: $e')),
        );
      }
    }
  }
}
