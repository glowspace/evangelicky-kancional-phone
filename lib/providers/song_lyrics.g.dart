// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song_lyrics.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$songLyricsHash() => r'75f1eb03410d154cd267379b51056b736017d0d9';

/// See also [songLyrics].
@ProviderFor(songLyrics)
final songLyricsProvider = Provider<List<SongLyric>>.internal(
  songLyrics,
  name: r'songLyricsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$songLyricsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SongLyricsRef = ProviderRef<List<SongLyric>>;
String _$songsListSongLyricsHash() =>
    r'5be5b2d1ea1000c78c94c7133639aa835b0eefae';

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

/// See also [songsListSongLyrics].
@ProviderFor(songsListSongLyrics)
const songsListSongLyricsProvider = SongsListSongLyricsFamily();

/// See also [songsListSongLyrics].
class SongsListSongLyricsFamily extends Family<List<SongLyric>> {
  /// See also [songsListSongLyrics].
  const SongsListSongLyricsFamily();

  /// See also [songsListSongLyrics].
  SongsListSongLyricsProvider call(
    SongsList songsList,
  ) {
    return SongsListSongLyricsProvider(
      songsList,
    );
  }

  @override
  SongsListSongLyricsProvider getProviderOverride(
    covariant SongsListSongLyricsProvider provider,
  ) {
    return call(
      provider.songsList,
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
  String? get name => r'songsListSongLyricsProvider';
}

/// See also [songsListSongLyrics].
class SongsListSongLyricsProvider extends AutoDisposeProvider<List<SongLyric>> {
  /// See also [songsListSongLyrics].
  SongsListSongLyricsProvider(
    SongsList songsList,
  ) : this._internal(
          (ref) => songsListSongLyrics(
            ref as SongsListSongLyricsRef,
            songsList,
          ),
          from: songsListSongLyricsProvider,
          name: r'songsListSongLyricsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$songsListSongLyricsHash,
          dependencies: SongsListSongLyricsFamily._dependencies,
          allTransitiveDependencies:
              SongsListSongLyricsFamily._allTransitiveDependencies,
          songsList: songsList,
        );

  SongsListSongLyricsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.songsList,
  }) : super.internal();

  final SongsList songsList;

  @override
  Override overrideWith(
    List<SongLyric> Function(SongsListSongLyricsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SongsListSongLyricsProvider._internal(
        (ref) => create(ref as SongsListSongLyricsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        songsList: songsList,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<List<SongLyric>> createElement() {
    return _SongsListSongLyricsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SongsListSongLyricsProvider && other.songsList == songsList;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, songsList.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin SongsListSongLyricsRef on AutoDisposeProviderRef<List<SongLyric>> {
  /// The parameter `songsList` of this provider.
  SongsList get songsList;
}

class _SongsListSongLyricsProviderElement
    extends AutoDisposeProviderElement<List<SongLyric>>
    with SongsListSongLyricsRef {
  _SongsListSongLyricsProviderElement(super.provider);

  @override
  SongsList get songsList => (origin as SongsListSongLyricsProvider).songsList;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
