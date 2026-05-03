import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import '../core/services/speech_service.dart';
import '../core/utils/voice_parser.dart';
import '../core/const/app_dimensions.dart';
import '../core/const/app_typography.dart';
import '../core/utils/blur_utils.dart';
import 'add_transaction_dialog.dart';

class VoiceInputOverlay extends StatefulWidget {
  const VoiceInputOverlay({super.key});

  @override
  State<VoiceInputOverlay> createState() => _VoiceInputOverlayState();
}

class _VoiceInputOverlayState extends State<VoiceInputOverlay> with SingleTickerProviderStateMixin {
  final SpeechService _speechService = SpeechService();
  String _currentText = "Listening...";
  bool _isInitialized = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    
    _initAndStart();
  }

  Future<void> _initAndStart() async {
    final success = await _speechService.initSpeech();
    if (success) {
      if (mounted) setState(() => _isInitialized = true);
      _startRecording();
    } else {
      if (mounted) {
        setState(() => _currentText = "Speech recognition unavaiable");
      }
    }
  }

  void _startRecording() {
    _speechService.startListening((text) {
      if (mounted) {
        setState(() {
          _currentText = text.isEmpty ? "Listening..." : text;
        });
      }
    });
  }

  void _finishRecording() {
    //wait s after stopt recording
    
    _speechService.stopListening();
    final result = VoiceParser.parse(_currentText);
    
    Navigator.pop(context); // Close overlay
    
    // Open AddTransactionDialog with parsed data
    BlurUtils.showBlurredBottomSheet(
      context: context,
      child: AddTransactionDialog(
        isIncome: result.isIncome ?? false,
        initialAmount: result.amount,
        initialNote: result.note,
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _speechService.cancelListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.8),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.dividerColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 32),
            ScaleTransition(
              scale: Tween(begin: 1.0, end: 1.1).animate(_pulseController),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.mic_rounded,
                  size: 48,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              "Keep speaking...",
              style: GoogleFonts.dmSans(
                fontSize: AppTypography.fontSizeSmall,
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              constraints: const BoxConstraints(minHeight: 100),
              child: Text(
                _currentText,
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: AppTypography.fontSizeLarge,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "Cancel",
                      style: GoogleFonts.dmSans(color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ZoomTapAnimation(
                    onTap: _finishRecording,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.secondary,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          "Done",
                          style: GoogleFonts.dmSans(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
