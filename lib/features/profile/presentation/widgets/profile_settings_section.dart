import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macrolite/core/domain/user_profile.dart';
import 'package:macrolite/features/profile/profile_notifier.dart';
import 'package:macrolite/features/onboarding/onboarding_screen.dart';
import 'package:macrolite/core/theme/theme_notifier.dart';

class ProfileSettingsSection extends ConsumerWidget {
  const ProfileSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileNotifierProvider);

    return profileAsync.when(
      data: (profile) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Recalculate Macros Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        const OnboardingScreen(fromProfile: true),
                  ),
                );
              },
              icon: const Icon(Icons.calculate),
              label: const Text('Makroları Yeniden Hesapla'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Karanlık Mod'),
            value: ref.watch(themeNotifierProvider),
            onChanged: (_) => ref.read(themeNotifierProvider.notifier).toggle(),
            secondary: const Icon(Icons.brightness_6),
          ),
          const Divider(),
          _buildSettingItem(
            context,
            ref,
            'Current Weight',
            '${profile.currentWeight} kg',
            (value) => profile.copyWith(currentWeight: value),
            profile.currentWeight,
          ),
          _buildSettingItem(
            context,
            ref,
            'Height',
            '${profile.height.toInt()} cm',
            (value) => profile.copyWith(height: value),
            profile.height,
          ),
          const Divider(),
          _buildSettingItem(
            context,
            ref,
            'Calorie Target',
            '${profile.targetCalories.toInt()} kcal',
            (value) => profile.copyWith(targetCalories: value),
            profile.targetCalories,
          ),
          _buildSettingItem(
            context,
            ref,
            'Protein Target',
            '${profile.targetProtein.toInt()} g',
            (value) => profile.copyWith(targetProtein: value),
            profile.targetProtein,
          ),
          _buildSettingItem(
            context,
            ref,
            'Carb Target',
            '${profile.targetCarbs.toInt()} g',
            (value) => profile.copyWith(targetCarbs: value),
            profile.targetCarbs,
          ),
          _buildSettingItem(
            context,
            ref,
            'Fat Target',
            '${profile.targetFat.toInt()} g',
            (value) => profile.copyWith(targetFat: value),
            profile.targetFat,
          ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildSettingItem(
    BuildContext context,
    WidgetRef ref,
    String title,
    String value,
    UserProfile Function(double) onUpdate,
    double currentValue,
  ) {
    return ListTile(
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.edit, size: 16, color: Colors.grey),
        ],
      ),
      onTap: () => _showEditDialog(context, ref, title, currentValue, onUpdate),
    );
  }

  Future<void> _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    String title,
    double currentValue,
    UserProfile Function(double) onUpdate,
  ) async {
    final controller = TextEditingController(text: currentValue.toString());

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $title'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newValue = double.tryParse(controller.text);
              if (newValue != null) {
                final newProfile = onUpdate(newValue);
                ref
                    .read(profileNotifierProvider.notifier)
                    .updateProfile(newProfile);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
