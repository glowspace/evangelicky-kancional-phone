import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:objectbox/objectbox.dart';
import 'package:zpevnik/models/model.dart';
import 'package:zpevnik/models/playlist_record.dart';
import 'package:zpevnik/models/tag.dart';

part 'playlist.freezed.dart';

const favoritesPlaylistId = 1;
const _favoritesName = 'Písně s hvězdičkou';

// offset for songbook tags, tags from API have id > 0, songbook tags have negative id starting from -1000, so offset -2000 should be enough
const _playlistIdOffset = -2000;

@freezed
class Playlist with _$Playlist implements Identifiable, RecentItem, SongsList {
  const Playlist._();

  @Entity(realClass: Playlist)
  const factory Playlist({
    @Id(assignable: true) required int id,
    @Unique(onConflict: ConflictStrategy.fail) required String name,
    required int rank,
    @Backlink() required ToMany<PlaylistRecord> records,
  }) = _Playlist;

  factory Playlist.favorites() => Playlist(
        id: favoritesPlaylistId,
        name: _favoritesName,
        rank: 0,
        records: ToMany(),
      );

  Tag get tag => Tag(id: id + _playlistIdOffset, name: name, dbType: TagType.playlist.rawValue);

  bool get isFavorites => id == favoritesPlaylistId;

  @override
  RecentItemType get recentItemType => RecentItemType.playlist;
}
