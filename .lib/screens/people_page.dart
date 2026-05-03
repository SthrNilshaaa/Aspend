import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:ui';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' hide GlassAppBar;

import '../core/const/app_assets.dart';
import '../core/models/person.dart';
import '../core/view_models/person_view_model.dart';
import '../core/view_models/theme_view_model.dart';
import '../person/person_details_page.dart';
import '../core/utils/responsive_utils.dart';
import '../widgets/header_delegate.dart';
import '../widgets/modern_card.dart';
import '../widgets/glass_app_bar.dart';
import '../widgets/empty_state_view.dart';
import '../core/const/app_strings.dart';
import '../core/const/app_colors.dart';
import '../core/const/app_dimensions.dart';
import '../core/const/app_typography.dart';
import '../core/utils/blur_utils.dart';

class PeopleTab extends StatefulWidget {
  const PeopleTab({super.key});

  @override
  State<PeopleTab> createState() => _PeopleTabState();
}

class _PeopleTabState extends State<PeopleTab> {
  late ScrollController _scrollController;
  bool _showFab = true;
  String? _searchQuery;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _searchController = TextEditingController();

    _scrollController.addListener(() {
      if (!_scrollController.hasClients || !mounted) return;

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
    _searchController.dispose();
    super.dispose();
  }

  void _showPersonDialog(BuildContext context, {Person? existingPerson}) {
    final controller = TextEditingController(text: existingPerson?.name);
    final upiController = TextEditingController(text: existingPerson?.upiId);
    final theme = Theme.of(context);
    String? selectedPhotoPath = existingPerson?.photoPath;

    BlurUtils.showBlurredDialog(
      context: context,
      child: StatefulBuilder(
        builder: (context, setStateDialog) => Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: GlassContainer(
            padding: const EdgeInsets.all(24),
            quality: GlassQuality.premium,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  existingPerson == null
                      ? AppStrings.addNewPerson
                      : AppStrings.editPerson,
                  style: GoogleFonts.dmSans(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 24),
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
                  child: GlassContainer(
                    width: 100,
                    height: 100,
                    shape: const LiquidOval(),
                    child: selectedPhotoPath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: selectedPhotoPath!.startsWith('assets/')
                                ? Image.asset(selectedPhotoPath!,
                                    width: 100, height: 100, fit: BoxFit.cover)
                                : Image.file(
                                    File(selectedPhotoPath!),
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo_rounded,
                                size: 32,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                AppStrings.addPhoto,
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: AppStrings.personName,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surface.withOpacity(0.5),
                    prefixIcon: Icon(Icons.person_outline_rounded,
                        color: theme.colorScheme.primary),
                  ),
                  style: GoogleFonts.dmSans(),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: upiController,
                  decoration: InputDecoration(
                    labelText: AppStrings.upiId,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surface.withOpacity(0.5),
                    prefixIcon: Icon(Icons.payment_rounded,
                        color: theme.colorScheme.primary),
                    hintText: 'user@upi',
                  ),
                  style: GoogleFonts.dmSans(),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.dmSans(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ZoomTapAnimation(
                      onTap: () {
                        final name = controller.text.trim();
                        if (name.isNotEmpty) {
                          HapticFeedback.lightImpact();
                          if (existingPerson == null) {
                            final person = Person(
                              name: name,
                              photoPath: selectedPhotoPath,
                              upiId: upiController.text.trim(),
                            );
                            context.read<PersonViewModel>().addPerson(person);
                          } else {
                            final updatedPerson = Person(
                              name: name,
                              photoPath: selectedPhotoPath,
                              upiId: upiController.text.trim(),
                            );
                            context
                                .read<PersonViewModel>()
                                .updatePerson(existingPerson, updatedPerson);
                          }
                          Navigator.pop(context);
                        }
                      },
                      child: GlassCard(
                        width: 100,
                        height: 48,
                        padding: EdgeInsets.zero,
                        child: Container(
                          color: theme.colorScheme.primary.withValues(alpha: 0.8),
                          child: Center(
                            child: Text(
                              existingPerson == null ? 'Add' : 'Update',
                              style: GoogleFonts.dmSans(
                                  fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryInfo(BuildContext context,
      {required String label,
      required double amount,
      required Color color,
      required dynamic icon}) {
    final theme = Theme.of(context);
    final formatted = NumberFormat.currency(
      symbol: '',
      decimalDigits: 2,
    ).format(amount);

    final parts = formatted.split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? parts[1] : '00';
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.paddingXSmall,
      ),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingXLarge,
          vertical: AppDimensions.paddingSmall,
        ),
        shape: LiquidRoundedSuperellipse(
          borderRadius: AppDimensions.borderRadiusXLarge,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: icon is String
                      ? SvgPicture.asset(
                          icon,
                          colorFilter:
                              ColorFilter.mode(color, BlendMode.srcIn),
                          width: AppDimensions.iconSizeXSmall,
                          height: AppDimensions.iconSizeXSmall,
                        )
                      : Icon(icon,
                          color: color,
                          size: AppDimensions.iconSizeSmall),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: GoogleFonts.dmSans(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context,
                        mobile: 12,
                        tablet: 14,
                        desktop: 16),
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant
                        .withOpacity(0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            RichText(
              text: TextSpan(children: [
                TextSpan(
                  text: '₹',
                  style: GoogleFonts.dmSans(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context,
                        mobile: 20,
                        tablet: 24,
                        desktop: 28),
                    fontWeight: FontWeight.w800,
                    color: color,
                    letterSpacing: -0.5,
                  ),
                ),
                const TextSpan(text: '  '),
                TextSpan(
                  children: [
                    TextSpan(
                      text: integerPart,
                      style: GoogleFonts.dmSans(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                            context,
                            mobile: 20,
                            tablet: 24,
                            desktop: 28),
                        fontWeight: FontWeight.w800,
                        color: color,
                        letterSpacing: -0.5,
                      ),
                    ),
                    TextSpan(
                      text: '.$decimalPart',
                      style: GoogleFonts.dmSans(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                            context,
                            mobile: 16,
                            tablet: 20,
                            desktop: 24),
                        fontWeight: FontWeight.w800,
                        color: color,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ]),
            ),
          ],
        ),
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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              const CustomGlassAppBar(
                title: AppStrings.people,
                centerTitle: true,
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: HomeHeaderDelegate(
                  height: 180,
                  child: _buildPinnedHeader(context, personViewModel),
                ),
              ),
              if (people.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
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
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: ResponsiveUtils.isMobile(context)
                          ? 4.5
                          : (ResponsiveUtils.isTablet(context) ? 2.8 : 3.2),
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final person = people[index];
                        final total =
                            personViewModel.getTotalForPerson(person.name);
                        final isPositive = total >= 0;
    
                        return RepaintBoundary(
                          child: ZoomTapAnimation(
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
                              padding: const EdgeInsets.all(16),
                              borderRadius: AppDimensions.borderRadiusXLarge,
                              color: theme.colorScheme.surface,
                              child: IntrinsicHeight(
                                child: Row(
                                  children: [
                                    Stack(
                                      children: [
                                        Container(
                                          width:
                                              ResponsiveUtils.getResponsiveIconSize(
                                                  context,
                                                  mobile: 60,
                                                  tablet: 56,
                                                  desktop: 64),
                                          height:
                                              ResponsiveUtils.getResponsiveIconSize(
                                                  context,
                                                  mobile: 60,
                                                  tablet: 56,
                                                  desktop: 64),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                                AppDimensions.borderRadiusLarge),
                                            color: theme.colorScheme.primary
                                                .withOpacity(0.1),
                                            border: Border.all(
                                              color: theme.colorScheme.primary
                                                  .withOpacity(0.1),
                                              width: 1,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: person.photoPath != null
                                                ? ClipRRect(
                                                    borderRadius: BorderRadius
                                                        .circular(AppDimensions
                                                            .borderRadiusMinLarge),
                                                    child: person.photoPath!
                                                            .startsWith('assets/')
                                                        ? Image.asset(
                                                            person.photoPath!,
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
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            person.name,
                                            style: GoogleFonts.dmSans(
                                              fontWeight: FontWeight.w700,
                                              fontSize: ResponsiveUtils
                                                  .getResponsiveFontSize(context,
                                                      mobile: AppTypography
                                                          .fontSizeMedium,
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
                                                ? AppStrings.youGet
                                                : AppStrings.youGive,
                                            style: GoogleFonts.dmSans(
                                              fontSize: 11,
                                              color: theme.colorScheme.onSurface
                                                  .withOpacity(0.7),
                                              fontWeight:
                                                  AppTypography.fontWeightMedium,
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
                                          '₹ ${total.abs().toStringAsFixed(0)}',
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
                            ),
                          ),
                        );
                      },
                      childCount: people.length,
                    ),
                  ),
                ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: people.isEmpty ? 100 : 80,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: people.isEmpty
          ? _buildAddPersonFab(context)
          : AnimatedSlide(
              offset: _showFab ? Offset.zero : const Offset(0, 2),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: AnimatedOpacity(
                opacity: _showFab ? 1.0 : 0.5,
                duration: const Duration(milliseconds: 300),
                child: _buildAddPersonFab(context),
              ),
            ),
    );
  }

  Widget _buildPinnedHeader(
      BuildContext context, PersonViewModel personViewModel) {
    final double totalYouGet = personViewModel.overallTotalRent;
    final double totalYouGive = personViewModel.overallTotalGiven;

    final theme = Theme.of(context);
    return GlassContainer(
      quality: GlassQuality.premium,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 2),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSummaryInfo(
                  context,
                  label: AppStrings.youGet,
                  amount: totalYouGet,
                  color: AppColors.accentGreen,
                  icon: SvgAppIcons.incomeIcon,
                ),
                Container(
                  height: 48,
                  width: 1.5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        theme.dividerColor.withOpacity(0.0),
                        theme.dividerColor.withOpacity(0.1),
                        theme.dividerColor.withOpacity(0.0),
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
                  icon: SvgAppIcons.expenseIcon,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildSearchSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingSmall),
      child: Row(
        children: [
          Expanded(
            child: GlassContainer(
              height: 56,
              quality: GlassQuality.premium,
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Icon(Icons.search_rounded, color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val.trim().isEmpty ? null : val.trim();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: AppStrings.searchPeople,
                        hintStyle: GoogleFonts.dmSans(
                          fontSize: AppTypography.fontSizeSmall,
                          color: theme.colorScheme.onSurface
                              .withOpacity(0.4),
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
                                    _searchController.clear();
                                  });
                                },
                              )
                            : null,
                      ),
                      style: GoogleFonts.dmSans(
                          fontSize: AppTypography.fontSizeRegular,
                          color: theme.colorScheme.onSurface,
                          letterSpacing: -0.1),
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
            child: GlassCard(
              width: 54,
              height: 54,
              padding: EdgeInsets.zero,
              child: Container(
                color: theme.colorScheme.surface.withValues(alpha: 0.8),
                child: Center(
                  child: SvgPicture.asset(
                    SvgAppIcons.filterIcon,
                    colorFilter: ColorFilter.mode(
                        theme.colorScheme.primary, BlendMode.srcIn),
                    width: 20,
                    height: 20,
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

    BlurUtils.showBlurredBottomSheet(
      context: context,
      child: GlassContainer(
        quality: GlassQuality.premium,
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
                  color: theme.dividerColor.withOpacity(0.2),
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
            _buildSortOption(
                context, 'Name (A-Z)', PersonSortOption.nameAZ, vm),
            _buildSortOption(
                context, 'Name (Z-A)', PersonSortOption.nameZA, vm),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 80),
      child: ZoomTapAnimation(
        onTap: () {
          _showPersonDialog(context);
          HapticFeedback.lightImpact();
        },
        child: GlassCard(
          width: 180,
          height: 56,
          padding: EdgeInsets.zero,
          child: Container(
            color: theme.colorScheme.primary.withValues(alpha: 0.8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person_add_alt_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  AppStrings.addPerson,
                  style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
