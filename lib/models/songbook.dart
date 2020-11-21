import 'package:collection/collection.dart';
import 'package:zpevnik/models/entities/songbook.dart';
import 'package:zpevnik/models/songLyric.dart';
import 'package:zpevnik/providers/data_provider.dart';
import 'package:zpevnik/utils/database.dart';

class Songbook extends Comparable {
  final SongbookEntity _entity;

  List<SongLyric> _songLyrics;

  Songbook(this._entity);

  int get id => _entity.id;

  String get name => _entity.name;

  String get shortcut => _entity.shortcut;

  bool get isPinned => _entity.isPinned;

  set pinned(value) {
    _entity.isPinned = value;
    Database.shared.updateSongbook(_entity, ['is_pinned'].toSet());
  }

  // todo: probably can be optmized using db, but it's good enough for now
  List<SongLyric> get songLyrics => _songLyrics ??= DataProvider.shared.songLyrics
      .where((songLyric) => songLyric.entity.songbookRecords.any((record) => record.songbookId == _entity.id))
      .toList()
        ..sort((first, second) => compareNatural(
            first.entity.songbookRecords.firstWhere((record) => record.songbookId == _entity.id).number,
            (second.entity.songbookRecords.firstWhere((record) => record.songbookId == _entity.id).number)));

  @override
  int compareTo(_other) {
    Songbook other = _other;

    if (isPinned && !other.isPinned) return -1;
    if (!isPinned && other.isPinned) return 1;

    return name.compareTo(other.name);
  }
}
