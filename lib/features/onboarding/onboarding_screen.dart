import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:macrolite/core/domain/user_profile.dart';
import 'package:macrolite/core/domain/gender.dart';
import 'package:macrolite/core/domain/activity_level.dart';
import 'package:macrolite/core/domain/goal.dart';
import 'package:macrolite/core/utils/macro_calculator.dart';
import 'package:macrolite/features/profile/profile_notifier.dart';
import 'package:macrolite/core/navigation/app_router_provider.dart';
import 'package:macrolite/core/widgets/custom_slider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key, this.fromProfile = false});

  final bool fromProfile;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Form data
  int _age = 25;
  Gender _gender = Gender.male;
  double _weight = 70;
  double _height = 170;
  ActivityLevel _activityLevel = ActivityLevel.moderate;
  Goal _goal = Goal.maintain;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fromProfile ? 'Makro Güncelle' : 'Profil Kurulumu'),
        leading: widget.fromProfile
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        automaticallyImplyLeading: widget.fromProfile,
      ),
      body: Column(
        children: [
          // Animated Progress indicator
          _AnimatedProgressBar(currentPage: _currentPage, totalPages: 4),

          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (page) => setState(() => _currentPage = page),
              children: [
                _buildBasicInfoPage(),
                _buildBodyMetricsPage(),
                _buildActivityPage(),
                _buildGoalPage(),
              ],
            ),
          ),

          // Navigation buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                if (_currentPage > 0)
                  TextButton(
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: const Text('Geri'),
                  ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () async {
                    if (_currentPage < 3) {
                      await _pageController.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutCubic,
                      );
                    } else {
                      await _finishOnboarding();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _currentPage < 3 ? 'İleri' : 'Tamamla',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Temel Bilgiler',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Senin için en uygun makro değerlerini hesaplayalım',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 32),

          const Text(
            'Yaş',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          CustomSlider(
            value: _age.toDouble(),
            min: 15,
            max: 80,
            divisions: 65,
            label: _age.toString(),
            unit: 'yaş',
            onChanged: (value) => setState(() => _age = value.toInt()),
          ),

          const SizedBox(height: 32),
          const Text(
            'Cinsiyet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          SegmentedButton<Gender>(
            segments: Gender.values
                .map((g) => ButtonSegment(value: g, label: Text(g.label)))
                .toList(),
            selected: {_gender},
            onSelectionChanged: (Set<Gender> newSelection) {
              setState(() => _gender = newSelection.first);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBodyMetricsPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vücut Ölçüleri',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),

          const Text(
            'Kilo (kg)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          CustomSlider(
            value: _weight,
            min: 40,
            max: 150,
            divisions: 110,
            label: _weight.toStringAsFixed(0),
            unit: 'kg',
            onChanged: (value) => setState(() => _weight = value),
          ),

          const SizedBox(height: 32),
          const Text(
            'Boy (cm)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          CustomSlider(
            value: _height,
            min: 140,
            max: 220,
            divisions: 80,
            label: _height.toStringAsFixed(0),
            unit: 'cm',
            onChanged: (value) => setState(() => _height = value),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Aktivite Seviyesi',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Günlük hareketliliğiniz nasıl?',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),

          Expanded(
            child: ListView(
              children: ActivityLevel.values.map((level) {
                final isSelected = _activityLevel == level;
                return Card(
                  elevation: isSelected ? 4 : 1,
                  color: isSelected
                      ? Theme.of(context).primaryColor.withOpacity(0.1)
                      : null,
                  child: ListTile(
                    title: Text(
                      level.label,
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(level.description),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle,
                            color: Theme.of(context).primaryColor,
                          )
                        : null,
                    onTap: () => setState(() => _activityLevel = level),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hedefin Nedir?',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Bu hedefe göre makrolarını ayarlayacağız',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),

          Expanded(
            child: ListView(
              children: Goal.values.map((goal) {
                final isSelected = _goal == goal;
                return Card(
                  elevation: isSelected ? 4 : 1,
                  color: isSelected
                      ? Theme.of(context).primaryColor.withOpacity(0.1)
                      : null,
                  child: ListTile(
                    title: Text(
                      goal.label,
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text(goal.description),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle,
                            color: Theme.of(context).primaryColor,
                          )
                        : null,
                    onTap: () => setState(() => _goal = goal),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _finishOnboarding() async {
    // Calculate macros
    final macros = MacroCalculator.calculateMacros(
      weight: _weight,
      height: _height,
      age: _age,
      gender: _gender,
      activityLevel: _activityLevel,
      goal: _goal,
    );

    // Create new profile
    final newProfile = UserProfile(
      targetCalories: macros['calories']!.toDouble(),
      targetProtein: macros['protein']!.toDouble(),
      targetCarbs: macros['carbs']!.toDouble(),
      targetFat: macros['fat']!.toDouble(),
      currentWeight: _weight,
      height: _height,
      age: _age,
      gender: _gender,
      activityLevel: _activityLevel,
      goal: _goal,
    );

    // Save profile
    await ref.read(profileNotifierProvider.notifier).updateProfile(newProfile);

    if (!mounted) return;

    if (widget.fromProfile) {
      // If opened from profile screen, just pop back
      Navigator.of(context).pop();
    } else {
      // If first onboarding, go to tracker
      context.go(AppRoute.tracker);
    }
  }
}

// Animated Progress Bar Widget
class _AnimatedProgressBar extends StatelessWidget {
  const _AnimatedProgressBar({
    required this.currentPage,
    required this.totalPages,
  });

  final int currentPage;
  final int totalPages;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: List.generate(totalPages, (index) {
          final isCompleted = index < currentPage;
          final isActive = index == currentPage;

          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: index < totalPages - 1 ? 8 : 0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background track
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Animated progress fill
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutCubic,
                    height: 4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isCompleted || isActive
                            ? [Colors.blue.shade400, Colors.blue.shade600]
                            : [Colors.grey.shade300, Colors.grey.shade300],
                      ),
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: Colors.blue.shade400.withOpacity(0.5),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                  ),
                  // Checkmark for completed steps
                  if (isCompleted)
                    AnimatedScale(
                      duration: const Duration(milliseconds: 300),
                      scale: isCompleted ? 1.0 : 0.0,
                      curve: Curves.elasticOut,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade600,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
