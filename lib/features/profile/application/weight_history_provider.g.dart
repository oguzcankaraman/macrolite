// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weight_history_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$weightHistoryHash() => r'874896dd4d2d8172d9943f2bb6793911550fd06c';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [weightHistory].
@ProviderFor(weightHistory)
const weightHistoryProvider = WeightHistoryFamily();

/// See also [weightHistory].
class WeightHistoryFamily extends Family<AsyncValue<List<WeightEntry>>> {
  /// See also [weightHistory].
  const WeightHistoryFamily();

  /// See also [weightHistory].
  WeightHistoryProvider call({
    required DateTime start,
    required DateTime end,
  }) {
    return WeightHistoryProvider(
      start: start,
      end: end,
    );
  }

  @override
  WeightHistoryProvider getProviderOverride(
    covariant WeightHistoryProvider provider,
  ) {
    return call(
      start: provider.start,
      end: provider.end,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'weightHistoryProvider';
}

/// See also [weightHistory].
class WeightHistoryProvider
    extends AutoDisposeFutureProvider<List<WeightEntry>> {
  /// See also [weightHistory].
  WeightHistoryProvider({
    required DateTime start,
    required DateTime end,
  }) : this._internal(
          (ref) => weightHistory(
            ref as WeightHistoryRef,
            start: start,
            end: end,
          ),
          from: weightHistoryProvider,
          name: r'weightHistoryProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$weightHistoryHash,
          dependencies: WeightHistoryFamily._dependencies,
          allTransitiveDependencies:
              WeightHistoryFamily._allTransitiveDependencies,
          start: start,
          end: end,
        );

  WeightHistoryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.start,
    required this.end,
  }) : super.internal();

  final DateTime start;
  final DateTime end;

  @override
  Override overrideWith(
    FutureOr<List<WeightEntry>> Function(WeightHistoryRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: WeightHistoryProvider._internal(
        (ref) => create(ref as WeightHistoryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        start: start,
        end: end,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<WeightEntry>> createElement() {
    return _WeightHistoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WeightHistoryProvider &&
        other.start == start &&
        other.end == end;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, start.hashCode);
    hash = _SystemHash.combine(hash, end.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin WeightHistoryRef on AutoDisposeFutureProviderRef<List<WeightEntry>> {
  /// The parameter `start` of this provider.
  DateTime get start;

  /// The parameter `end` of this provider.
  DateTime get end;
}

class _WeightHistoryProviderElement
    extends AutoDisposeFutureProviderElement<List<WeightEntry>>
    with WeightHistoryRef {
  _WeightHistoryProviderElement(super.provider);

  @override
  DateTime get start => (origin as WeightHistoryProvider).start;
  @override
  DateTime get end => (origin as WeightHistoryProvider).end;
}

String _$latestWeightHash() => r'85c63d905747ff70fdd10925b78d0545ab5591b3';

/// See also [latestWeight].
@ProviderFor(latestWeight)
final latestWeightProvider = AutoDisposeFutureProvider<WeightEntry?>.internal(
  latestWeight,
  name: r'latestWeightProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$latestWeightHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef LatestWeightRef = AutoDisposeFutureProviderRef<WeightEntry?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
