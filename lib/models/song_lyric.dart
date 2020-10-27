import 'package:jaguar_orm/jaguar_orm.dart';
import 'package:zpevnik/models/author.dart';
import 'package:zpevnik/models/external.dart';
import 'package:zpevnik/models/playlist.dart';
import 'package:zpevnik/models/songbook.dart';
import 'package:zpevnik/models/songbook_record.dart';
import 'package:zpevnik/models/tag.dart';
import 'package:zpevnik/utils/beans.dart';

class SongLyric {
  @PrimaryKey()
  final int id;

  final String name;

  @Column(isNullable: true)
  final String lyrics;

  final String language;
  final int type;

  @ManyToMany(SongLyricAuthorBean, AuthorBean)
  List<Author> authors;

  @HasMany(ExternalBean)
  List<External> externals;

  @ManyToMany(SongLyricTagBean, TagBean)
  List<Tag> tags;

  @ManyToMany(SongLyricPlaylistBean, PlaylistBean)
  List<Playlist> playlists;

  @HasMany(SongbookRecordBean)
  List<SongbookRecord> songbookRecords;

  @BelongsTo(SongBean, isNullable: true)
  int songId;

  SongLyric({
    this.id,
    this.name,
    this.lyrics,
    this.language,
    this.type,
  });

  factory SongLyric.fromJson(Map<String, dynamic> json) {
    // print(json['song']);

    final id = int.parse(json['id']);
    final songId = json['song'] == null
        ? null
        : (json['song'] as Map<String, dynamic>)['id'];

    return SongLyric(
      id: id,
      name: json['name'],
      lyrics: json['lyrics'],
      language: json['lang_string'],
      // todo: handle type
      type: 1,
    )
      ..authors = (json['authors_pivot'] as List<dynamic>)
          .map((json) => Author.fromJson(json['author']))
          .toList()
      ..externals = (json['externals'] as List<dynamic>)
          .map((json) => External.fromJson(json))
          .toList()
      ..tags = (json['tags'] as List<dynamic>)
          .map((json) => Tag.fromJson(json))
          .toList()
      ..playlists = []
      ..songbookRecords = (json['songbook_records'] as List<dynamic>)
          .map((json) => SongbookRecord.fromJson(json)..songLyricId = id)
          .toList()
      ..songId = songId == null ? null : int.parse(songId);
  }
}
