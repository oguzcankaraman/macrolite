import 'package:hive_flutter/hive_flutter.dart';
import 'package:macrolite/core/domain/user_profile.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_repository.g.dart';

class ProfileRepository {
  ProfileRepository(this.profileBox);

  final Box<UserProfile> profileBox;

  // Kasadan profili okur.
  UserProfile getProfile() {
    try {
      final profile = profileBox.get(0);
      if (profile == null) {
        return UserProfile.defaults();
      }
      // If old data is missing currentWeight field, it might cause issues
      // Return a new profile with all required fields
      return profile;
    } catch (e) {
      // If there's any error reading (e.g., missing fields), return defaults
      return UserProfile.defaults();
    }
  }

  Future<void> saveProfile(UserProfile profile) async {
    await profileBox.put(0, profile);
  }

  // Helper method to reset profile data (useful for migration issues)
  Future<void> resetProfile() async {
    await profileBox.clear();
    await saveProfile(UserProfile.defaults());
  }
}

@riverpod
Future<ProfileRepository> profileRepository(ProfileRepositoryRef ref) async {
  final profileBox = await ref.watch(profileBoxProvider.future);
  return ProfileRepository(profileBox);
}

@riverpod
Future<Box<UserProfile>> profileBox(ProfileBoxRef ref) async {
  ref.keepAlive();
  return await Hive.openBox<UserProfile>('user_profile');
}
