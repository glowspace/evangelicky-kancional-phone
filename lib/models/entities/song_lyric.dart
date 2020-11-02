import 'package:flutter_svg/flutter_svg.dart';
import 'package:jaguar_orm/jaguar_orm.dart';
import 'package:zpevnik/models/entities/author.dart';
import 'package:zpevnik/models/entities/external.dart';
import 'package:zpevnik/models/entities/playlist.dart';
import 'package:zpevnik/models/entities/songbook_record.dart';
import 'package:zpevnik/models/entities/tag.dart';
import 'package:zpevnik/models/songLyric.dart';
import 'package:zpevnik/utils/beans.dart';

class SongLyricEntity {
  @PrimaryKey()
  final int id;

  final String name;

  @Column(isNullable: true)
  final String lyrics;

  final String language;
  final int type;

  // fixme: store it as raw data instead of string
  @Column(isNullable: true)
  final String lilypond;

  @Column(isNullable: true)
  int favoriteOrder;

  @Column(isNullable: true)
  int transposition;

  @Column(isNullable: true)
  bool showChords;

  @Column(isNullable: true)
  bool accidentals;

  @ManyToMany(SongLyricAuthorBean, AuthorBean)
  List<AuthorEntity> authors;

  @HasMany(ExternalBean)
  List<ExternalEntity> externals;

  @ManyToMany(SongLyricTagBean, TagBean)
  List<TagEntity> tags;

  @ManyToMany(SongLyricPlaylistBean, PlaylistBean)
  List<Playlist> playlists;

  @HasMany(SongbookRecordBean)
  List<SongbookRecord> songbookRecords;

  @BelongsTo(SongBean, isNullable: true)
  int songId;

  SongLyricEntity({
    this.id,
    this.name,
    this.lyrics,
    this.language,
    this.type,
    this.lilypond,
  });

  factory SongLyricEntity.fromJson(Map<String, dynamic> json) {
    final id = int.parse(json['id']);
    final songId = json['song'] == null ? null : (json['song'] as Map<String, dynamic>)['id'];

    return SongLyricEntity(
      id: id,
      name: json['name'],
      lyrics: json['lyrics'],
      language: json['lang_string'],
      type: SongLyricTypeExtension.fromString(json['type_enum']).rawValue,
      lilypond: json['lilypond_svg'],
    )
      ..authors = (json['authors_pivot'] as List<dynamic>).map((json) => AuthorEntity.fromJson(json['author'])).toList()
      ..externals =
          (json['externals'] as List<dynamic>).map((json) => ExternalEntity.fromJson(json)..songLyricId = id).toList()
      ..tags = (json['tags'] as List<dynamic>).map((json) => TagEntity.fromJson(json)).toList()
      ..playlists = []
      ..songbookRecords = (json['songbook_records'] as List<dynamic>)
          .map((json) => SongbookRecord.fromJson(json)..songLyricId = id)
          .toList()
      ..songId = songId == null ? null : int.parse(songId);
  }
}
