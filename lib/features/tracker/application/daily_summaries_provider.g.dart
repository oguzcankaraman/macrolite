// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_summaries_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dailySummariesHash() => r'007b5332f01b5ffcb30cefc76a256543f7b5433d';

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

/// See also [dailySummaries].
@ProviderFor(dailySummaries)
const dailySummariesProvider = DailySummariesFamily();

/// See also [dailySummaries].
class DailySummariesFamily extends Family<AsyncValue<List<DailyMacroSummary>>> {
  /// See also [dailySummaries].
  const DailySummariesFamily();

  /// See also [dailySummaries].
  DailySummariesProvider call({
    required DateTime start,
    required DateTime end,
  }) {
    return DailySummariesProvider(
      start: start,
      end: end,
    );
  }

  @override
  DailySummariesProvider getProviderOverride(
    covariant DailySummariesProvider provider,
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
  String? get name => r'dailySummariesProvider';
}

/// See also [dailySummaries].
class DailySummariesProvider
    extends AutoDisposeFutureProvider<List<DailyMacroSummary>> {
  /// See also [dailySummaries].
  DailySummariesProvider({
    required DateTime start,
    required DateTime end,
  }) : this._internal(
          (ref) => dailySummaries(
            ref as DailySummariesRef,
            start: start,
            end: end,
          ),
          from: dailySummariesProvider,
          name: r'dailySummariesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$dailySummariesHash,
          dependencies: DailySummariesFamily._dependencies,
          allTransitiveDependencies:
              DailySummariesFamily._allTransitiveDependencies,
          start: start,
          end: end,
        );

  DailySummariesProvider._internal(
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
    FutureOr<List<DailyMacroSummary>> Function(DailySummariesRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DailySummariesProvider._internal(
        (ref) => create(ref as DailySummariesRef),
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
  AutoDisposeFutureProviderElement<List<DailyMacroSummary>> createElement() {
    return _DailySummariesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DailySummariesProvider &&
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

mixin DailySummariesRef
    on AutoDisposeFutureProviderRef<List<DailyMacroSummary>> {
  /// The parameter `start` of this provider.
  DateTime get start;

  /// The parameter `end` of this provider.
  DateTime get end;
}

class _DailySummariesProviderElement
    extends AutoDisposeFutureProviderElement<List<DailyMacroSummary>>
    with DailySummariesRef {
  _DailySummariesProviderElement(super.provider);

  @override
  DateTime get start => (origin as DailySummariesProvider).start;
  @override
  DateTime get end => (origin as DailySummariesProvider).end;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
