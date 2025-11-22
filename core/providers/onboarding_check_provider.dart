import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:macrolite/features/profile/profile_notifier.dart';

part 'onboarding_check_provider.g.dart';

@riverpod
Future<bool> onboardingNeeded(OnboardingNeededRef ref) async {
  final profileAsync = await ref.watch(profileNotifierProvider.future);

  // Check if profile is still at defaults (age 25 is our default)
  // This indicates user hasn't completed onboarding
  return profileAsync.age == 25 &&
      profileAsync.currentWeight == 70 &&
      profileAsync.height == 170;
}
