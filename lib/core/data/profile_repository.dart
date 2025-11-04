import 'package:hive_flutter/hive_flutter.dart';
import 'package:macrolite/core/domain/user_profile.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_repository.g.dart';

class ProfileRepository {
  ProfileRepository(this.profileBox);

  final Box<UserProfile> profileBox;

  // Kasadan profili okur.
  UserProfile getProfile() {
    return profileBox.get(0, defaultValue: UserProfile.defaults())!;
  }

  Future<void> saveProfile(UserProfile profile) async {
    await profileBox.put(0, profile);
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