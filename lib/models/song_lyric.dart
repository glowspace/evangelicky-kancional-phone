// ignore: unnecessary_import
import 'package:objectbox/objectbox.dart';
import 'package:zpevnik/models/author.dart';
import 'package:zpevnik/models/external.dart';
import 'package:zpevnik/models/objectbox.g.dart';
import 'package:zpevnik/models/playlist.dart';
import 'package:zpevnik/models/playlist_record.dart';
import 'package:zpevnik/models/settings.dart';
import 'package:zpevnik/models/song.dart';
import 'package:zpevnik/models/songbook_record.dart';
import 'package:zpevnik/models/tag.dart';
import 'package:zpevnik/models/utils.dart';

enum SongLyricType {
  original,
  translation,
  authorizedTranslation,
}

extension SongLyricTypeExtension on SongLyricType {
  static SongLyricType fromString(String? string) {
    switch (string) {
      case "ORIGINAL":
        return SongLyricType.original;
      case "AUTHORIZED_TRANSLATION":
        return SongLyricType.authorizedTranslation;
      default:
        return SongLyricType.translation;
    }
  }

  static SongLyricType fromRawValue(int rawValue) {
    switch (rawValue) {
      case 0:
        return SongLyricType.original;
      case 1:
        return SongLyricType.authorizedTranslation;
      default:
        return SongLyricType.translation;
    }
  }

  int get rawValue {
    switch (this) {
      case SongLyricType.original:
        return 0;
      case SongLyricType.authorizedTranslation:
        return 1;
      default:
        return 2;
    }
  }

  String get description {
    switch (this) {
      case SongLyricType.original:
        return "Originál";
      case SongLyricType.authorizedTranslation:
        return "Autorizovaný překlad";
      default:
        return "Překlad";
    }
  }
}

@Entity()
class SongLyric {
  @Id(assignable: true)
  final int id;

  final String name;
  final String? secondaryName1;
  final String? secondaryName2;

  final String? lyrics;
  final String? lilypond;

  final String? lang;
  final String? langDescription;

  final int dbType;
  final bool hasChords;

  int? accidentals;
  bool? showChords;
  int transposition = 0;

  final settings = ToOne<SongLyricSettingsModel>();

  final authors = ToMany<Author>();
  final song = ToOne<Song>();
  final tags = ToMany<Tag>();

  final externals = ToMany<External>();

  @Backlink()
  final songbookRecords = ToMany<SongbookRecord>();

  @Backlink()
  final playlistRecords = ToMany<PlaylistRecord>();

  SongLyric(
    this.id,
    this.name,
    this.secondaryName1,
    this.secondaryName2,
    this.lyrics,
    this.lilypond,
    this.lang,
    this.langDescription,
    this.dbType,
    this.hasChords,
  );

  factory SongLyric.fromJson(Map<String, dynamic> json, Store store) {
    final id = int.parse(json['id'] as String);

    final authors = store.box<Author>().getMany(
        (json['authors_pivot'] as List).map((json) => int.parse(json['pivot']['author']['id'] as String)).toList());
    final tags =
        store.box<Tag>().getMany((json['tags'] as List).map((json) => int.parse(json['id'] as String)).toList());

    final songbookRecords =
        readJsonList(json[SongbookRecord.fieldKey], mapper: (json) => SongbookRecord.fromJson(json['pivot']));
    final externals = readJsonList(json[External.fieldKey], mapper: External.fromJson);

    final query = store.box<SongLyric>().query(SongLyric_.id.equals(id)).build();

    final transpositions = query.property(SongLyric_.transposition).find();
    final accidentals = query.property(SongLyric_.accidentals).find();

    return SongLyric(
      id,
      json['name'] as String,
      json['secondary_name_1'] as String?,
      json['secondary_name_2'] as String?,
      json['lyrics'] as String?,
      json['lilypond_svg'] as String?,
      json['lang'] as String,
      json['lang_string'] as String,
      SongLyricTypeExtension.fromString(json['type_enum'] as String?).rawValue,
      json['has_chords'] as bool,
    )
      ..transposition = transpositions.isEmpty ? 0 : transpositions.first
      ..accidentals = accidentals.isEmpty ? 0 : accidentals.first
      ..authors.addAll(authors.cast())
      ..song.targetId = json['song'] == null ? null : int.parse(json['song']['id'] as String)
      ..tags.addAll(tags.cast())
      ..externals.addAll(externals)
      ..songbookRecords.addAll(songbookRecords);
  }

  static List<SongLyric> fromMapList(Map<String, dynamic> json, Store store) {
    return (json['song_lyrics'] as List).map((json) => SongLyric.fromJson(json, store)).toList();
  }

  static List<SongLyric> load(Store store) {
    final query = store.box<SongLyric>().query(SongLyric_.lyrics.notNull().or(SongLyric_.lilypond.notNull()));
    query.order(SongLyric_.name);

    return query.build().find();
  }

  SongLyricType get type => SongLyricTypeExtension.fromRawValue(dbType);

  bool get hasTranslations => (song.target?.songLyrics.length ?? 1) > 1;

  bool get hasLyrics => lyrics != null && lyrics!.isNotEmpty;
  bool get hasFiles =>
      externals.any((external) => external.mediaType == MediaType.pdf || external.mediaType == MediaType.jpg);
  bool get hasRecordings =>
      externals.any((external) => external.mediaType == MediaType.youtube || external.mediaType == MediaType.mp3);

  bool get isFavorite =>
      playlistRecords.any((playlistRecord) => playlistRecord.playlist.targetId == favoritesPlaylistId);

  String get authorsText {
    if (type == SongLyricType.original) {
      if (authors.isEmpty) {
        return 'Autor neznámý';
      } else if (authors.length == 1) {
        return 'Autor: ${authors[0].name}';
      } else {
        return 'Autoři: ${authors.map((author) => author.name).toList().join(", ")}';
      }
    } else {
      String originalText = '';

      final original = song.target?.songLyrics
          .cast()
          .firstWhere((songLyric) => songLyric.type == SongLyricType.original, orElse: () => null);

      if (original != null) {
        originalText = 'Originál: ${original.name}\n';

        originalText += '${original.authorsText}\n';
      }

      if (authors.isEmpty) {
        return '${originalText}Autor překladu neznámý';
      } else if (authors.length == 1) {
        return '${originalText}Autor překladu: ${authors[0].name}';
      } else {
        return '${originalText}Autoři překladu: ${authors.map((author) => author.name).toList().join(", ")}';
      }
    }
  }

  List<External> get files => externals
      .where((external) => external.mediaType == MediaType.pdf || external.mediaType == MediaType.jpg)
      .toList();
  List<External> get youtubes => externals.where((external) => external.mediaType == MediaType.youtube).toList();
  List<External> get mp3s => externals.where((external) => external.mediaType == MediaType.mp3).toList();

  @override
  String toString() => 'SongLyric(id: $id, name: $name)';

  @override
  bool operator ==(Object other) => other is SongLyric && id == other.id;

  @override
  int get hashCode => id;
}
