import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/const/app_colors.dart';
import '../core/const/app_dimensions.dart';
import '../core/const/app_typography.dart';
import '../core/services/native_bridge.dart';
import '../core/view_models/theme_view_model.dart';
import '../../widgets/glass_app_bar.dart';
import '../../widgets/empty_state_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/const/app_assets.dart';

class AppSelectionPage extends StatefulWidget {
  const AppSelectionPage({super.key});

  @override
  State<AppSelectionPage> createState() => _AppSelectionPageState();
}

class _AppSelectionPageState extends State<AppSelectionPage> {
  List<Map<String, String>> _allApps = [];
  List<Map<String, String>> _filteredApps = [];
  Set<String> _selectedPackages = {};
  static List<Map<String, String>>? _cachedApps;
  static Set<String>? _cachedSelected;
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (_cachedApps != null && _cachedSelected != null) {
      if (mounted) {
        setState(() {
          _allApps = _cachedApps!;
          _filteredApps = _cachedApps!;
          _selectedPackages = _cachedSelected!;
          _isLoading = false;
        });
      }
      // Still refresh in background to get latest
    } else {
      setState(() => _isLoading = true);
    }

    try {
      final apps = await NativeBridge.getInstalledApps();
      final monitored = await NativeBridge.getMonitoredApps();

      // Sort apps: selected first, then by name
      apps.sort((a, b) {
        final aSelected = monitored.contains(a['packageName']);
        final bSelected = monitored.contains(b['packageName']);

        if (aSelected != bSelected) {
          return aSelected ? -1 : 1;
        }
        return a['appName']!
            .toLowerCase()
            .compareTo(b['appName']!.toLowerCase());
      });

      if (mounted) {
        setState(() {
          _allApps = apps;
          _filteredApps = apps;
          _selectedPackages = monitored.toSet();
          _isLoading = false;

          _cachedApps = apps;
          _cachedSelected = _selectedPackages;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading apps: $e')),
        );
      }
    }
  }

  void _filterApps(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredApps = _allApps;
      } else {
        _filteredApps = _allApps
            .where((app) =>
                app['appName']!.toLowerCase().contains(query.toLowerCase()) ||
                app['packageName']!.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  Future<void> _toggleApp(String packageName) async {
    setState(() {
      if (_selectedPackages.contains(packageName)) {
        _selectedPackages.remove(packageName);
      } else {
        _selectedPackages.add(packageName);
      }
    });

    await NativeBridge.saveMonitoredApps(_selectedPackages.toList());
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          GlassAppBar(
            title: 'Monitored Apps',
            centerTitle: true,
            leading: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.only(
                    left: AppDimensions.paddingSmall +
                        AppDimensions.paddingSmall),
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
                      padding: const EdgeInsets.all(15.0),
                      child: SvgPicture.asset(
                        SvgAppIcons.backButtonIcon,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _buildSearchSection(context),
          ),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_allApps.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyStateView(
                icon: Icons.apps_outage_rounded,
                title: 'No eligible apps found',
              ),
            )
          else if (_filteredApps.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyStateView(
                icon: Icons.search_off_rounded,
                title: 'No apps match your search',
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingStandard,
                vertical: AppDimensions.paddingSmall,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final app = _filteredApps[index];
                    final packageName = app['packageName']!;
                    final isSelected = _selectedPackages.contains(packageName);

                    return _AppListTile(
                      app: app,
                      isSelected: isSelected,
                      onToggle: () => _toggleApp(packageName),
                    );
                  },
                  childCount: _filteredApps.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchSection(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = context.watch<ThemeViewModel>().isDarkMode;

    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingStandard),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: isDark
              ? theme.primaryColor.withValues(alpha: 0.05)
              : Colors.white.withValues(alpha: 0.2),
          borderRadius:
              BorderRadius.circular(AppDimensions.borderRadiusMinLarge),
          border: Border.all(
            color: theme.dividerColor.withValues(alpha: 0.2),
            width: 1.4,
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Icon(Icons.search,
                color: theme.colorScheme.primary.withValues(alpha: 0.5)),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                onChanged: _filterApps,
                decoration: InputDecoration(
                  hintText: 'Search payment or banking apps...',
                  hintStyle: GoogleFonts.dmSans(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    fontSize: AppTypography.fontSizeSmall,
                  ),
                  border: InputBorder.none,
                ),
                style: GoogleFonts.dmSans(
                  fontSize: AppTypography.fontSizeRegular,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            if (_searchQuery.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () {
                  _filterApps('');
                  FocusScope.of(context).unfocus();
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _AppListTile extends StatelessWidget {
  final Map<String, String> app;
  final bool isSelected;
  final VoidCallback onToggle;

  const _AppListTile({
    required this.app,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Uint8List? iconBytes;
    if (app['icon'] != null && app['icon']!.isNotEmpty) {
      try {
        iconBytes = base64Decode(app['icon']!);
      } catch (e) {
        // Ignore
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
        border: Border.all(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.2)
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius:
                BorderRadius.circular(AppDimensions.borderRadiusMedium),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(AppDimensions.borderRadiusMedium),
            child: iconBytes != null
                ? Image.memory(iconBytes, fit: BoxFit.cover)
                : Icon(Icons.apps,
                    color: theme.colorScheme.primary.withValues(alpha: 0.5)),
          ),
        ),
        title: Text(
          app['appName'] ?? 'Unknown App',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.bold,
            fontSize: AppTypography.fontSizeSmall,
          ),
        ),
        subtitle: Text(
          app['packageName'] ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.dmSans(
            fontSize: 11,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ),
        trailing: Switch(
          value: isSelected,
          activeThumbColor: AppColors.accentGreen,
          onChanged: (_) => onToggle(),
        ),
      ),
    );
  }
}
