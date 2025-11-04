import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:macrolite/core/data/profile_repository.dart';
import 'package:macrolite/core/domain/user_profile.dart';

part 'profile_notifier.g.dart';

@riverpod
class ProfileNotifier extends _$ProfileNotifier {
  @override
  Future<UserProfile> build() async {
    final repository = await ref.watch(profileRepositoryProvider.future);
    return repository.getProfile();
  }

  Future<void> updateProfile(UserProfile newProfile) async {
    final repository = await ref.read(profileRepositoryProvider.future);

    state = AsyncData(newProfile);
    await repository.saveProfile(newProfile);
  }
}