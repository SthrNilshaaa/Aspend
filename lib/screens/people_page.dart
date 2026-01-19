import 'package:flutter/material.dart';
//import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:ui';
import 'dart:io';
import '../models/person.dart';
import '../view_models/person_view_model.dart';
import '../view_models/theme_view_model.dart';
import '../person/person_details_page.dart';
import '../utils/responsive_utils.dart';
import '../widgets/modern_card.dart';

class PeopleTab extends StatefulWidget {
  const PeopleTab({super.key});

  @override
  State<PeopleTab> createState() => _PeopleTabState();
}

class _PeopleTabState extends State<PeopleTab> {
  late ScrollController _scrollController;
  bool _showFab = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;

      final atTop = _scrollController.position.pixels <= 0;
      final people = context.read<PersonViewModel>().people;
      final isEmpty = people.isEmpty;
      final shouldShowFab = atTop || isEmpty;

      // Only update state if there's an actual change
      if (shouldShowFab != _showFab) {
        setState(() => _showFab = shouldShowFab);
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            existingPerson == null ? 'Add New Person' : 'Edit Person',
            style: GoogleFonts.nunito(
              fontSize: 22,
              fontWeight: FontWeight.bold,
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
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: selectedPhotoPath != null
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: selectedPhotoPath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(48),
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
                              size: 30,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Add Photo',
                              style: GoogleFonts.nunito(
                                fontSize: 12,
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                existingPerson == null
                    ? 'Enter the name of the person you want to track transactions with'
                    : 'Update the details for this person',
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: 'Person Name',
                  labelStyle: GoogleFonts.nunito(fontSize: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  prefixIcon: Icon(Icons.person_outline,
                      color: theme.colorScheme.primary),
                ),
                style: GoogleFonts.nunito(fontSize: 16),
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.nunito(
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
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                existingPerson == null ? 'Add' : 'Update',
                style: GoogleFonts.nunito(
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
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context,
                  mobile: 13, tablet: 15, desktop: 17),
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.9),
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  color: color,
                  size: ResponsiveUtils.getResponsiveIconSize(context,
                      mobile: 18, tablet: 22, desktop: 26)),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  '₹${amount.toStringAsFixed(2)}',
                  style: GoogleFonts.nunito(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context,
                        mobile: 17, tablet: 20, desktop: 24),
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final personViewModel = context.watch<PersonViewModel>();
    final allPeople = personViewModel.people;
    final people = allPeople
        .where((p) => p.name.toLowerCase().contains(_searchQuery))
        .toList();
    final theme = Theme.of(context);
    final themeViewModel = context.watch<ThemeViewModel>();
    final isDark = themeViewModel.isDarkMode;
    final useAdaptive = themeViewModel.useAdaptiveColor;

    final double totalYouGet = personViewModel.overallTotalRent;
    final double totalYouGive = personViewModel.overallTotalGiven;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: ResponsiveUtils.getResponsiveAppBarHeight(context),
            floating: true,
            pinned: true,
            elevation: 1,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'People',
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.bold,
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context,
                      mobile: 24, tablet: 28, desktop: 32),
                  color: theme.colorScheme.onSurface,
                ),
              ),
              background: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: useAdaptive
                          ? LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                theme.colorScheme.primary,
                                theme.colorScheme.primaryContainer
                              ],
                            )
                          : isDark
                              ? LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    theme.colorScheme.primary
                                        .withValues(alpha: 0.8),
                                    theme.colorScheme.primaryContainer
                                        .withValues(alpha: 0.8)
                                  ],
                                )
                              : LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    theme.colorScheme.primary
                                        .withValues(alpha: 0.8),
                                    theme.colorScheme.primaryContainer
                                        .withValues(alpha: 0.8)
                                  ],
                                ),
                    ),
                  ),
                ),
              ),
            ),
            centerTitle: true,
          ),

          // NEW: Conditional Sliver for Total Debit and Credit Summary
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ModernCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _buildSummaryInfo(
                          context,
                          label: 'You Get',
                          amount: totalYouGet,
                          color: Colors.greenAccent.shade700,
                          icon: Icons.arrow_downward_rounded,
                        ),
                        Container(
                          height: 40,
                          width: 1,
                          color: theme.dividerColor.withValues(alpha: 0.1),
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        _buildSummaryInfo(
                          context,
                          label: 'You Give',
                          amount: totalYouGive,
                          color: Colors.redAccent,
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                onChanged: (val) =>
                    setState(() => _searchQuery = val.toLowerCase()),
                decoration: InputDecoration(
                  hintText: 'Search people...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                style: GoogleFonts.nunito(),
              ),
            ),
          ),

          if (people.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: useAdaptive
                            ? theme.colorScheme.primary.withValues(alpha: 0.1)
                            : theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(60),
                      ),
                      child: Icon(
                        Icons.people_outline,
                        size: 60,
                        color: useAdaptive
                            ? theme.colorScheme.primary
                            : theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No people added yet',
                      style: GoogleFonts.nunito(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add people to track transactions with them',
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final person = people[index];
                  final total = personViewModel.getTotalForPerson(person.name);
                  final isPositive = total >= 0;
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: person.photoPath == null
                                    ? theme.colorScheme.primary
                                        .withValues(alpha: 0.1)
                                    : Colors.transparent,
                                border: Border.all(
                                  color: theme.colorScheme.primary
                                      .withValues(alpha: 0.2),
                                  width: 1,
                                ),
                              ),
                              child: person.photoPath != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(28),
                                      child: Image.file(
                                        File(person.photoPath!),
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Icon(Icons.person,
                                      color: theme.colorScheme.primary,
                                      size: 28),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        person.name,
                                        style: GoogleFonts.nunito(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 17,
                                        ),
                                      ),
                                      // const SizedBox(width: 8),
                                      // GestureDetector(
                                      //   onTap: () => _showPersonDialog(context,
                                      //       existingPerson: person),
                                      //   child: Icon(
                                      //     Icons.edit_outlined,
                                      //     size: 16,
                                      //     color: theme.colorScheme.primary
                                      //         .withValues(alpha: 0.5),
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isPositive
                                        ? 'You will get'
                                        : 'You will give',
                                    style: GoogleFonts.nunito(
                                      fontSize: 12,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '₹${total.abs().toStringAsFixed(0)}',
                                  style: GoogleFonts.nunito(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18,
                                    color: isPositive
                                        ? Colors.greenAccent.shade700
                                        : Colors.redAccent,
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: (isPositive
                                            ? Colors.greenAccent.shade700
                                            : Colors.redAccent)
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    isPositive
                                        ? Icons.keyboard_arrow_down
                                        : Icons.keyboard_arrow_up,
                                    size: 14,
                                    color: isPositive
                                        ? Colors.greenAccent.shade700
                                        : Colors.redAccent,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                childCount: people.length,
              ),
            ),
          const SliverToBoxAdapter(
              child: SizedBox(height: 80)), // Your existing SizedBox
        ],
      ),
      floatingActionButton: people.isEmpty
          ? _buildAddPersonFab(context)
          : (_showFab ? _buildAddPersonFab(context) : null),
      // floatingActionButtonLocation is not specified in your code, so FAB will use default.
      // If you had it before (e.g. FloatingActionButtonLocation.centerFloat), you can add it back.
    );
  }

  // This method is PRESERVED EXACTLY AS YOU PROVIDED IT
  Widget _buildAddPersonFab(BuildContext context) {
    final theme = Theme.of(context);
    return ZoomTapAnimation(
      onTap: () {
        _showPersonDialog(context);
        HapticFeedback.lightImpact();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 60),
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
                  'Add Person',
                  style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme
                          .onSurface), // Added color for visibility if surface is transparent
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
