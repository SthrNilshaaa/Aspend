import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import '../../core/const/app_dimensions.dart';
import '../../core/const/app_assets.dart';
import '../../core/const/app_strings.dart';
import '../../widgets/glass_app_bar.dart';
import '../../screens/detection_history_page.dart';

class HomeAppBar extends StatelessWidget {
  final bool isDark;
  final double turns;
  final bool isSyncing;
  final VoidCallback onLeadingTap;

  const HomeAppBar({
    super.key,
    required this.isDark,
    required this.turns,
    required this.isSyncing,
    required this.onLeadingTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomGlassAppBar(
      automaticallyImplyLeading: false,
      centerTitle: false,
      floating: false,
      title: AppStrings.appNameShort,
      leading: GestureDetector(
        onTap: onLeadingTap,
        child: Padding(
          padding: const EdgeInsets.only(
              left: AppDimensions.paddingSmall + AppDimensions.paddingSmall),
          child: AnimatedRotation(
            turns: turns,
            duration: const Duration(seconds: 1),
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.dividerColor.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: SvgPicture.asset(
                    SvgAppIcons.appBarIcon,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      actions: [
        // Padding(
        //   padding: const EdgeInsets.only(right: 8.0),
        //   child: GestureDetector(
        //     onTap: () {
        //       HapticFeedback.lightImpact();
        //       _showScanOptions(context);
        //     },
        //     child: Container(
        //       width: 50,
        //       height: 50,
        //       decoration: BoxDecoration(
        //         color: theme.colorScheme.surface.withValues(alpha: 0.1),
        //         shape: BoxShape.circle,
        //         border: Border.all(
        //           color: theme.dividerColor.withValues(alpha: 0.1),
        //           width: 1.3,
        //         ),
        //       ),
        //       child: const Icon(Icons.document_scanner_outlined),
        //     ),
        //   ),
        // ),
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: isSyncing 
            ? const SizedBox(
                width: 50,
                height: 50,
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                ),
              )
            : GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const DetectionHistoryPage()),
                  );
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.dividerColor.withValues(alpha: 0.1),
                      width: 1.3,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(13.0),
                    child: SvgPicture.asset(
                      SvgAppIcons.notificationLogoIcon,
                      colorFilter: ColorFilter.mode(
                          theme.colorScheme.onSurface, BlendMode.srcIn),
                    ),
                  ),
                ),
              ),
        ),
      ],
    );
  }

  // void _showScanOptions(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (context) => SafeArea(
  //       child: Wrap(
  //         children: [
  //           ListTile(
  //             leading: const Icon(Icons.photo_library),
  //             title: const Text('Scan from Gallery'),
  //             onTap: () {
  //               Navigator.pop(context);
  //               TransactionDetectionService.processImageFromSource(
  //                   ImageSource.gallery);
  //             },
  //           ),
  //           ListTile(
  //             leading: const Icon(Icons.camera_alt),
  //             title: const Text('Scan from Camera'),
  //             onTap: () {
  //               Navigator.pop(context);
  //               TransactionDetectionService.processImageFromSource(
  //                   ImageSource.camera);
  //             },
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
