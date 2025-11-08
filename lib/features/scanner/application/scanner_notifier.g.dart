// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scanner_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$scannerControllerHash() => r'68e06cceb85c97ee38d8de942b70c51e4e012d74';

/// See also [scannerController].
@ProviderFor(scannerController)
final scannerControllerProvider =
    AutoDisposeProvider<MobileScannerController>.internal(
  scannerController,
  name: r'scannerControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$scannerControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ScannerControllerRef = AutoDisposeProviderRef<MobileScannerController>;
String _$dioHash() => r'a03da399b44b3740dc4fcfc6716203041d66ff01';

/// See also [dio].
@ProviderFor(dio)
final dioProvider = AutoDisposeProvider<Dio>.internal(
  dio,
  name: r'dioProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$dioHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DioRef = AutoDisposeProviderRef<Dio>;
String _$foodRepositoryHash() => r'df375b8cf83a5ecceccbee2fd90f85919a895b4e';

/// See also [foodRepository].
@ProviderFor(foodRepository)
final foodRepositoryProvider = AutoDisposeProvider<FoodRepository>.internal(
  foodRepository,
  name: r'foodRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$foodRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FoodRepositoryRef = AutoDisposeProviderRef<FoodRepository>;
String _$scannerNotifierHash() => r'281be55ebbd5f8c1036090fd8d18b3fb84abfa94';

/// See also [ScannerNotifier].
@ProviderFor(ScannerNotifier)
final scannerNotifierProvider =
    AutoDisposeAsyncNotifierProvider<ScannerNotifier, FoodProduct?>.internal(
  ScannerNotifier.new,
  name: r'scannerNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$scannerNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ScannerNotifier = AutoDisposeAsyncNotifier<FoodProduct?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
