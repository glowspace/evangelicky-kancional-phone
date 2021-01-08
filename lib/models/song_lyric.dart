import 'package:flutter/material.dart';
import 'package:zpevnik/constants.dart';
import 'package:zpevnik/global.dart';
import 'package:zpevnik/models/entities/external.dart';
import 'package:zpevnik/models/entities/song_lyric.dart';
import 'package:zpevnik/models/song.dart';
import 'package:zpevnik/models/songbook.dart';
import 'package:zpevnik/providers/data_provider.dart';
import 'package:zpevnik/utils/database.dart';
import 'package:zpevnik/utils/song_lyrics_parser.dart';

final RegExp _chordsRE = RegExp(r'\[[^\]]+\]');

enum SongLyricType {
  original,
  translation,
  authorizedTranslation,
}

extension SongLyricTypeExtension on SongLyricType {
  static SongLyricType fromString(String string) {
    switch (string) {
      case "ORIGINAL":
        return SongLyricType.original;
      case "AUTHORIZED_TRANSLATION":
        return SongLyricType.authorizedTranslation;
      default:
        return SongLyricType.translation;
    }
  }

  int get rawValue => SongLyricType.values.indexOf(this);

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

  Color get color {
    switch (this) {
      case SongLyricType.original:
        return blue;
      case SongLyricType.authorizedTranslation:
        return yellow;
      default:
        return green;
    }
  }
}

class SongLyric extends ChangeNotifier {
  final SongLyricEntity _entity;
  final Song _song;

  static int _nextFavoriteOrder = 1;

  List<Verse> _verses;

  List<Verse> _versesNoChords;

  List<String> _numbers;

  bool _hasChords;

  SongLyric(this._entity, this._song) {
    if (_entity.favoriteOrder != null && _entity.favoriteOrder >= _nextFavoriteOrder)
      _nextFavoriteOrder = _entity.favoriteOrder + 1;
  }

  SongLyricEntity get entity => _entity;

  int get id => _entity.id;

  Key get key => Key(_entity.id.toString());

  String number(Songbook songbook) {
    return '${songbook.shortcut} ${_entity.songbookRecords.firstWhere((record) => record.songbookId == songbook.id).number}';
  }

  List<String> get numbers => _numbers ??= [id.toString()] +
      _entity.songbookRecords
          .where((record) => DataProvider.shared.songbook(record.songbookId) != null)
          .map((record) => '${DataProvider.shared.songbook(record.songbookId).shortcut}${record.number}')
          .toList();

  String get name {
    String name = _entity.name;

    if (_entity.secondaryName1 != null) name = '$name\n${_entity.secondaryName1}';
    if (_entity.secondaryName2 != null) name = '$name\n${_entity.secondaryName2}';

    return name;
  }

  String get displayName {
    String name = _entity.name;

    if (_entity.secondaryName1 != null) {
      if (_entity.secondaryName2 != null)
        name = '$name (${_entity.secondaryName1}, ${_entity.secondaryName2})';
      else
        name = '$name (${_entity.secondaryName1})';
    }

    return name;
  }

  List<Verse> get verses => showChords
      ? _verses ??= SongLyricsParser.shared.parseLyrics(_entity.lyrics, transposition, accidentals)
      : _versesNoChords ??= SongLyricsParser.shared.parseLyrics(_entity.lyrics.replaceAll(_chordsRE, ''), 0, false);

  String get lilypond => _entity.lilypond;

  SongLyricType get type => SongLyricType.values[_entity.type];

  bool get isFavorite => _entity.favoriteOrder != null;

  int get transposition => _entity.transposition ??= 0;

  bool get hasChords => _hasChords ??= _entity.lyrics.contains(_chordsRE);

  bool get showChords => _entity.showChords ?? hasChords && (Global.shared.prefs.getBool('show_chords') ?? true);

  bool get accidentals => _entity.accidentals ?? (Global.shared.prefs.getBool('accidentals') ?? false);

  bool get hasTranslations => _song.songLyrics.length > 1;

  bool get hasExternals => _entity.externals.isNotEmpty;

  String get authorsText {
    if (type == SongLyricType.original) {
      if (entity.authors.length == 0)
        return 'Autor neznámý';
      else if (entity.authors.length == 1)
        return 'Autor: ${entity.authors[0].name}';
      else
        return 'Autoři: ${entity.authors.map((author) => author.name).toList().join(", ")}';
    } else {
      String originalText = '';

      if (original.isNotEmpty) originalText = 'Originál: ${original[0].name}\n';

      if (original.isNotEmpty) originalText += '${original[0].authorsText}\n';

      if (entity.authors.length == 0)
        return '${originalText}Autor překladu neznámý';
      else if (entity.authors.length == 1)
        return '${originalText}Autor předkladu: ${entity.authors[0].name}';
      else
        return '${originalText}Autoři překladu: ${entity.authors.map((author) => author.name).toList().join(", ")}';
    }
  }

  List<SongLyric> get original =>
      _song.songLyrics.where((songLyric) => songLyric.type == SongLyricType.original).toList();

  List<SongLyric> get authorizedTranslations =>
      _song.songLyrics.where((songLyric) => songLyric.type == SongLyricType.authorizedTranslation).toList();

  List<SongLyric> get translations =>
      _song.songLyrics.where((songLyric) => songLyric.type == SongLyricType.translation).toList();

  List<ExternalEntity> get youtubes => _entity.externals.where((ext) => ext.mediaType == 'youtube').toList();

  void toggleFavorite() {
    if (isFavorite)
      _entity.favoriteOrder = null;
    else
      _entity.favoriteOrder = _nextFavoriteOrder++;

    Database.shared.updateSongLyric(_entity, ['favorite_order'].toSet());

    // fixme: it will also redraw lyrics because of this
    // it makes slower animation of filled star change
    notifyListeners();
  }

  set favoriteOrder(int value) {
    _entity.favoriteOrder = value;

    Database.shared.updateSongLyric(_entity, ['favorite_order'].toSet());
  }

  void changeTransposition(int byValue) {
    _entity.transposition += byValue;
    if (_entity.transposition == 12 || _entity.transposition == -12) _entity.transposition = 0;

    Database.shared.updateSongLyric(_entity, ['transposition'].toSet());

    verses.forEach((verse) =>
        verse.lines.forEach((line) => line.blocks.forEach((block) => block.transposition = _entity.transposition)));

    notifyListeners();
  }

  set accidentals(bool accidentals) {
    _entity.accidentals = accidentals;

    Database.shared.updateSongLyric(_entity, ['accidentals'].toSet());

    verses.forEach(
        (verse) => verse.lines.forEach((line) => line.blocks.forEach((block) => block.accidentals = accidentals)));

    notifyListeners();
  }

  set showChords(bool showChords) {
    _entity.showChords = showChords;

    Database.shared.updateSongLyric(_entity, ['show_chords'].toSet());

    notifyListeners();
  }
}

class Verse {
  final String number;
  final List<Line> lines;

  Verse(this.number, this.lines);

  factory Verse.fromMatch(RegExpMatch match) {
    if (match.group(1) == null && match.group(2).isEmpty) return null;

    if (match.group(1) == null)
      return Verse(
        '',
        SongLyricsParser.shared.lines(match.group(2)),
      );

    return Verse(
      match.group(1),
      SongLyricsParser.shared.lines(match.group(2)),
    );
  }

  factory Verse.withoutNumber(String verse) => Verse('', SongLyricsParser.shared.lines(verse));
}

class Line {
  final List<Block> blocks;

  List<List<Block>> _groupedBlocks;

  Line(this.blocks);

  List<List<Block>> get groupedBlocks {
    if (_groupedBlocks != null) return _groupedBlocks;

    List<List<Block>> grouped = [];

    List<Block> tmp = [];
    for (final block in blocks) {
      tmp.add(block);

      if (!block.shouldShowLine) {
        grouped.add(tmp);
        tmp = [];
      }
    }

    grouped.add(tmp);

    _groupedBlocks = grouped;

    return grouped;
  }
}

class Block {
  final String _chord;
  final String lyricsPart;
  final bool _shouldShowLine;

  int transposition;
  bool accidentals;

  Block(this._chord, this.lyricsPart, this._shouldShowLine);

  String get chord =>
      SongLyricsParser.shared.convertAccidentals(SongLyricsParser.shared.transpose(_chord, transposition), accidentals);

  bool get shouldShowLine => _shouldShowLine && lyricsPart.contains(new RegExp(r'[A-Za-z]'));
}
