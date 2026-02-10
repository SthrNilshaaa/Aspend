import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:ui';
import 'dart:io';
import '../const/app_assets.dart';
import '../models/person.dart';
import '../view_models/person_view_model.dart';
import '../view_models/theme_view_model.dart';
import '../person/person_details_page.dart';
import '../utils/responsive_utils.dart';
import '../widgets/modern_card.dart';
import '../widgets/glass_app_bar.dart';
import '../widgets/empty_state_view.dart';
import '../const/app_strings.dart';
import '../const/app_colors.dart';
import '../const/app_dimensions.dart';
import '../const/app_typography.dart';

class PeopleTab extends StatefulWidget {
  const PeopleTab({super.key});

  @override
  State<PeopleTab> createState() => _PeopleTabState();
}

class _PeopleTabState extends State<PeopleTab> {
  late ScrollController _scrollController;
  bool _showFab = true;
  String? _searchQuery;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;

      final position = _scrollController.position;
      final atTop = position.pixels <= 0;
      final people = context.read<PersonViewModel>().people;
      final isEmpty = people.isEmpty;

      final scrollingUp =
          position.userScrollDirection == ScrollDirection.forward;
      final scrollingDown =
          position.userScrollDirection == ScrollDirection.reverse;

      bool nextShowFab = _showFab;

      if (isEmpty || atTop || scrollingUp) {
        nextShowFab = true;
      } else if (scrollingDown) {
        nextShowFab = false;
      }

      if (nextShowFab != _showFab) {
        setState(() => _showFab = nextShowFab);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showPersonDialog(BuildContext context, {Person? existingPerson}) {
    final controller = TextEditingController(text: existingPerson?.name);
    final theme = Theme.of(context);
    String? selectedPhotoPath = existingPerson?.photoPath;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(AppDimensions.borderRadiusLarge)),
          title: Text(
            existingPerson == null
                ? AppStrings.addNewPerson
                : AppStrings.editPerson,
            style: GoogleFonts.dmSans(
              fontSize: AppTypography.fontSizeLarge,
              fontWeight: AppTypography.fontWeightBold,
              color: theme.colorScheme.primary,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Photo Selection
              GestureDetector(
                onTap: () async {
                  final ImagePicker picker = ImagePicker();
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.gallery,
                  );

                  if (image != null) {
                    setStateDialog(() {
                      selectedPhotoPath = image.path;
                    });
                  }
                },
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: selectedPhotoPath != null
                        ? theme.colorScheme.primary.withValues(alpha: 0.1)
                        : theme.colorScheme.surface,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.borderRadiusFull),
                    border: Border.all(
                      color: selectedPhotoPath != null
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: selectedPhotoPath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(
                              AppDimensions.borderRadiusFull),
                          child: selectedPhotoPath!.startsWith('assets/')
                              ? Image.asset(selectedPhotoPath!,
                                  width: 96, height: 96, fit: BoxFit.cover)
                              : Image.file(
                                  File(selectedPhotoPath!),
                                  width: 96,
                                  height: 96,
                                  fit: BoxFit.cover,
                                ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo,
                              size: AppDimensions.iconSizeXLarge + 2,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppStrings.addPhoto,
                              style: GoogleFonts.dmSans(
                                fontSize: AppTypography.fontSizeXSmall,
                                color: theme.colorScheme.primary,
                                fontWeight: AppTypography.fontWeightSemiBold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                existingPerson == null
                    ? AppStrings.enterNameHint
                    : AppStrings.updateDetailsHint,
                style: GoogleFonts.dmSans(
                  fontSize: AppTypography.fontSizeSmall,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: AppStrings.personName,
                  labelStyle: GoogleFonts.dmSans(fontSize: 16),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.borderRadiusSmall),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  prefixIcon: Icon(Icons.person_outline,
                      color: theme.colorScheme.primary),
                ),
                style: GoogleFonts.dmSans(fontSize: 16),
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.dmSans(
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  HapticFeedback.lightImpact();
                  if (existingPerson == null) {
                    final person =
                        Person(name: name, photoPath: selectedPhotoPath);
                    context.read<PersonViewModel>().addPerson(person);
                  } else {
                    final updatedPerson = Person(
                      name: name,
                      photoPath: selectedPhotoPath,
                    );
                    context
                        .read<PersonViewModel>()
                        .updatePerson(existingPerson, updatedPerson);
                  }
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.borderRadiusSmall)),
              ),
              child: Text(
                existingPerson == null ? 'Add' : 'Update',
                style: GoogleFonts.dmSans(
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // NEW: Helper widget for the summary info at the top
  Widget _buildSummaryInfo(BuildContext context,
      {required String label,
      required double amount,
      required Color color,
      required IconData icon}) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon,
                    color: color,
                    size: ResponsiveUtils.getResponsiveIconSize(context,
                        mobile: 14, tablet: 16, desktop: 18)),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context,
                      mobile: 12, tablet: 14, desktop: 16),
                  fontWeight: FontWeight.w600,
                  color:
                      theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: GoogleFonts.dmSans(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context,
                  mobile: 20, tablet: 24, desktop: 28),
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: -0.5,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final personViewModel = context.watch<PersonViewModel>();
    final allSortedPeople = personViewModel.sortedPeople;
    final people = allSortedPeople
        .where((p) =>
            _searchQuery == null ||
            p.name.toLowerCase().contains(_searchQuery!.toLowerCase()))
        .toList();
    final theme = Theme.of(context);
    final double totalYouGet = personViewModel.overallTotalRent;
    final double totalYouGive = personViewModel.overallTotalGiven;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          GlassAppBar(
            title: AppStrings.people,

            centerTitle: true,

          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: ModernCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _buildSummaryInfo(
                          context,
                          label: AppStrings.youGet,
                          amount: totalYouGet,
                          color: AppColors.accentGreen,
                          icon: Icons.arrow_downward_rounded,
                        ),
                        Container(
                          height: 48,
                          width: 1.5,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                theme.dividerColor.withValues(alpha: 0.0),
                                theme.dividerColor.withValues(alpha: 0.1),
                                theme.dividerColor.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        _buildSummaryInfo(
                          context,
                          label: AppStrings.youGive,
                          amount: totalYouGive,
                          color: AppColors.accentRed,
                          icon: Icons.arrow_upward_rounded,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: _buildSearchSection(context),
          ),

          if (people.isEmpty)
            SliverFillRemaining(
              child: EmptyStateView(
                icon: Icons.people_outline,
                title: AppStrings.noPeopleYet,
                description: 'Add people to track transactions with them',
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:
                      ResponsiveUtils.getResponsiveGridCrossAxisCount(context),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: ResponsiveUtils.isMobile(context)
                      ? 4.5
                      : (ResponsiveUtils.isTablet(context) ? 2.5 : 3.0),
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final person = people[index];
                    final total =
                        personViewModel.getTotalForPerson(person.name);
                    final isPositive = total >= 0;

                    return ZoomTapAnimation(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PersonDetailPage(person: person),
                          ),
                        );
                      },
                      child: ModernCard(
                        padding: const EdgeInsets.all(12),
                        color: theme.colorScheme.surface,
                        child: Row(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  width: ResponsiveUtils.getResponsiveIconSize(
                                      context,
                                      mobile: 48,
                                      tablet: 56,
                                      desktop: 64),
                                  height: ResponsiveUtils.getResponsiveIconSize(
                                      context,
                                      mobile: 48,
                                      tablet: 56,
                                      desktop: 64),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: person.photoPath == null
                                        ? theme.colorScheme.primary
                                            .withValues(alpha: 0.1)
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: theme.colorScheme.primary
                                          .withValues(alpha: 0.1),
                                      width: 1,
                                    ),
                                  ),
                                  child: person.photoPath != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                              AppDimensions.borderRadiusFull),
                                          child: person.photoPath!
                                                  .startsWith('assets/')
                                              ? Image.asset(person.photoPath!,
                                                  fit: BoxFit.cover)
                                              : Image.file(
                                                  File(person.photoPath!),
                                                  fit: BoxFit.cover,
                                                ),
                                        )
                                      : Icon(Icons.person_rounded,
                                          color: theme.colorScheme.primary,
                                          size: 24),
                                ),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: 14,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      color: isPositive
                                          ? AppColors.accentGreen
                                          : AppColors.accentRed,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: theme.colorScheme.surface,
                                          width: 2),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    person.name,
                                    style: GoogleFonts.dmSans(
                                      fontWeight: FontWeight.w700,
                                      fontSize:
                                          ResponsiveUtils.getResponsiveFontSize(
                                              context,
                                              mobile: 15,
                                              tablet: 17,
                                              desktop: 19),
                                      color: theme.colorScheme.onSurface,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isPositive
                                        ? AppStrings.youWillGet
                                        : AppStrings.youWillGive,
                                    style: GoogleFonts.dmSans(
                                      fontSize: 11,
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.5),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '₹${total.abs().toStringAsFixed(0)}',
                                  style: GoogleFonts.dmSans(
                                    fontWeight: FontWeight.w900,
                                    fontSize:
                                        ResponsiveUtils.getResponsiveFontSize(
                                            context,
                                            mobile: 16,
                                            tablet: 18,
                                            desktop: 20),
                                    color: isPositive
                                        ? AppColors.accentGreen
                                        : AppColors.accentRed,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: people.length,
                ),
              ),
            ),
          const SliverToBoxAdapter(
              child: SizedBox(height: 80)), // Your existing SizedBox
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: people.isEmpty
          ? _buildAddPersonFab(context)
          : (_showFab ? _buildAddPersonFab(context) : null),
    );
  }

  Widget _buildSearchSection(BuildContext context) {
    final theme = Theme.of(context);
    final themeViewModel = context.watch<ThemeViewModel>();
    final isDark = themeViewModel.isDarkMode;

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingStandard,
          vertical: AppDimensions.paddingSmall),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.5),
                borderRadius:
                    BorderRadius.circular(AppDimensions.borderRadiusFull),
                border: Border.all(
                  color: theme.dividerColor.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          SvgAppIcons.searchIcon,
                          colorFilter: ColorFilter.mode(
                              theme.colorScheme.primary, BlendMode.srcIn),
                          width: 25,
                          height: 25,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 24,
                    color: theme.dividerColor.withValues(alpha: 0.2),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val.trim().isEmpty ? null : val.trim();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: AppStrings.searchPeople,
                        hintStyle: GoogleFonts.dmSans(
                          fontSize: AppTypography.fontSizeSmall,
                          color:
                              theme.colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                        suffixIcon: _searchQuery != null
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  setState(() {
                                    _searchQuery = null;
                                  });
                                },
                              )
                            : null,
                      ),
                      style: GoogleFonts.dmSans(
                        fontSize: AppTypography.fontSizeSmall,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          ZoomTapAnimation(
            onTap: () {
              HapticFeedback.mediumImpact();
              _showSortDialog(context);
            },
            child: Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.dividerColor.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Center(
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      SvgAppIcons.filterIcon,
                      colorFilter: ColorFilter.mode(
                          theme.colorScheme.primary, BlendMode.srcIn),
                      width: 16,
                      height: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSortDialog(BuildContext context) {
    final theme = Theme.of(context);
    final vm = context.read<PersonViewModel>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppDimensions.borderRadiusXLarge)),
        ),
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.dividerColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Sort By',
              style: GoogleFonts.dmSans(
                fontSize: AppTypography.fontSizeLarge,
                fontWeight: AppTypography.fontWeightBold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSortOption(context, 'Name (A-Z)', PersonSortOption.nameAZ, vm),
            _buildSortOption(context, 'Name (Z-A)', PersonSortOption.nameZA, vm),
            _buildSortOption(context, 'Balance (Highest)',
                PersonSortOption.balanceHighest, vm),
            _buildSortOption(context, 'Balance (Lowest)',
                PersonSortOption.balanceLowest, vm),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(BuildContext context, String title,
      PersonSortOption option, PersonViewModel vm) {
    final theme = Theme.of(context);
    final isSelected = vm.currentSortOption == option;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: GoogleFonts.dmSans(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary)
          : null,
      onTap: () {
        vm.setSortOption(option);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildAddPersonFab(BuildContext context) {
    final theme = Theme.of(context);
    return ZoomTapAnimation(
      onTap: () {
        _showPersonDialog(context);
        HapticFeedback.lightImpact();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 80),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: FloatingActionButton.extended(
                onPressed: null, // Tap is handled by ZoomTapAnimation
                backgroundColor: Colors.transparent,
                elevation: 0,
                icon: const Icon(Icons.person_add, size: 24),
                label: Text(
                  AppStrings.addPerson,
                  style: GoogleFonts.dmSans(
                      fontSize: AppTypography.fontSizeMedium,
                      fontWeight: AppTypography.fontWeightSemiBold,
                      color: theme.colorScheme.onSurface),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
