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

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

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
        title: const Text('Profil Kurulumu'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Progress indicator
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: List.generate(
                4,
                (index) => Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
                    decoration: BoxDecoration(
                      color: index <= _currentPage
                          ? Theme.of(context).primaryColor
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
          ),

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
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      await _finishOnboarding();
                    }
                  },
                  child: Text(_currentPage < 3 ? 'İleri' : 'Tamamla'),
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
          const SizedBox(height: 8),
          Slider(
            value: _age.toDouble(),
            min: 15,
            max: 80,
            divisions: 65,
            label: _age.toString(),
            onChanged: (value) => setState(() => _age = value.toInt()),
          ),
          Text('$_age yaş', style: const TextStyle(fontSize: 16)),

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
          const SizedBox(height: 8),
          Slider(
            value: _weight,
            min: 40,
            max: 150,
            divisions: 110,
            label: _weight.toStringAsFixed(0),
            onChanged: (value) => setState(() => _weight = value),
          ),
          Text(
            '${_weight.toStringAsFixed(0)} kg',
            style: const TextStyle(fontSize: 16),
          ),

          const SizedBox(height: 32),
          const Text(
            'Boy (cm)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Slider(
            value: _height,
            min: 140,
            max: 220,
            divisions: 80,
            label: _height.toStringAsFixed(0),
            onChanged: (value) => setState(() => _height = value),
          ),
          Text(
            '${_height.toStringAsFixed(0)} cm',
            style: const TextStyle(fontSize: 16),
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

    // Navigate to tracker
    if (mounted) {
      context.go(AppRoute.tracker);
    }
  }
}
