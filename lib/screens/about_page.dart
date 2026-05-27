import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/const/app_colors.dart';
import '../core/const/app_constants.dart';
import '../core/const/app_dimensions.dart';
import '../core/const/app_strings.dart';
import '../core/view_models/theme_view_model.dart';
import '../widgets/settings_widgets.dart';
import 'package:aspends_tracker/l10n/generated/app_localizations.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeViewModel = context.watch<ThemeViewModel>();
    final isDark = themeViewModel.isDarkMode;
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 48, bottom: 16),
              title: Text(
                l10n.aboutApp,
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isDark
                                ? [
                                    AppColors.balanceCardDarkStart,
                                    AppColors.balanceCardDarkEnd
                                  ]
                                : [
                                    AppColors.balanceCardLightStart,
                                    AppColors.balanceCardLightEnd
                                  ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Decorative circles
                  Positioned(
                    top: -20,
                    right: -20,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Hero(
                          tag: 'app_logo',
                          child: Container(
                            width: 100,
                            height: 100,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.black26 : Colors.white,
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.borderRadiusLarge),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withValues(alpha: 0.15),
                                  blurRadius: 30,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/icons/Main_logo_transparent.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                                AppDimensions.borderRadiusFull),
                          ),
                          child: Text(
                            'v5.9.1',
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(AppDimensions.paddingLarge),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildHowItWorksSection(context),
                _buildSectionHeader(context, l10n.developerDesigner),
                _buildDeveloperCard(context, 'SthrKaran', l10n.leadDesigner,
                    'SK'),
                const SizedBox(height: 8),
                _buildDeveloperCard(context, 'nilshaaa', l10n.developer,
                    'N'),
                const SizedBox(height: 32),
                _buildSectionHeader(context, l10n.supportLegal),
                SettingTile(
                  icon: Icons.description_outlined,
                  title: l10n.privacyPolicy,
                  subtitle: l10n.privacyPolicyDesc,
                  onTap: () =>
                      _launchUrl(context, AppConstants.privacyPolicyUrl),
                ),
                SettingTile(
                  icon: Icons.help_outline_rounded,
                  title: l10n.helpSupport,
                  subtitle: l10n.telegramSupportDesc,
                  onTap: () =>
                      _launchUrl(context, AppConstants.supportTelegramUrl),
                ),
                const SizedBox(height: 32),
                _buildSectionHeader(context, l10n.projectInfo),
                SettingTile(
                  icon: Icons.code_rounded,
                  title: l10n.openSource,
                  subtitle: l10n.openSourceDesc,
                  onTap: () => _launchUrl(
                      context, 'https://github.com/SthrNilshaaa/Aspend'),
                ),
                SettingTile(
                  icon: Icons.star_outline_rounded,
                  title: l10n.rateApp,
                  subtitle: l10n.rateAppDesc,
                  onTap: () {
                    // Placeholder for store link
                  },
                ),
                const SizedBox(height: 48),
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Made with ❤️ for better finance',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.developedBy,
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white24 : Colors.black26,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  Widget _buildDeveloperCard(
      BuildContext context, String title, String subtitle, String initials) {
    final isDark = context.watch<ThemeViewModel>().isDarkMode;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.04),
            borderRadius:
                BorderRadius.circular(AppDimensions.borderRadiusLarge),
            border: Border.all(
              color: primaryColor.withValues(alpha: 0.08),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, primaryColor.withValues(alpha: 0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.dmSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.verified_rounded,
                color: primaryColor,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(BuildContext context, String urlString) async {
    final url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not launch URL')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Widget _buildHowItWorksSection(BuildContext context) {
    final isDark = context.watch<ThemeViewModel>().isDarkMode;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final l10n = AppLocalizations.of(context)!;

    final steps = [
      {
        'icon': Icons.notifications_active_rounded,
        'title': l10n.howItWorksTitle1,
        'desc': l10n.howItWorksDesc1,
      },
      {
        'icon': Icons.psychology_rounded,
        'title': l10n.howItWorksTitle2,
        'desc': l10n.howItWorksDesc2,
      },
      {
        'icon': Icons.sync_rounded,
        'title': l10n.howItWorksTitle3,
        'desc': l10n.howItWorksDesc3,
      },
      {
        'icon': Icons.security_rounded,
        'title': l10n.howItWorksTitle4,
        'desc': l10n.howItWorksDesc4,
      },
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.08),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: primaryColor, size: 22),
              const SizedBox(width: 8),
              Text(
                l10n.howAspendWorks,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...steps.map((step) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      step['icon'] as IconData,
                      color: primaryColor,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step['title'] as String,
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          step['desc'] as String,
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            height: 1.4,
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
