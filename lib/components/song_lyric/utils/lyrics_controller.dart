import 'package:flutter/material.dart';
import 'package:zpevnik/models/song_lyric.dart';
import 'package:zpevnik/components/song_lyric/utils/parser.dart';

final _styleRE = RegExp(r'\<style[^\<]*\<\/style\>');
final _heightRE = RegExp(r'height="([\d\.]+)mm"');
final _widthRE = RegExp(r'width="([\d\.]+)"');

class LyricsController {
  final SongLyric songLyric;
  final SongLyricsParser parser;

  final BuildContext context;

  LyricsController(this.songLyric, this.context) : parser = SongLyricsParser(songLyric);

  double? _lilypondWidth;
  String? _lilypond;

  String get title => songLyric.name;

  bool get hasLilypond => songLyric.lilypond != null;

  double get lilypondWidth => _lilypondWidth ?? 0;

  String get lilypond {
    if (_lilypond != null) return _lilypond!;

    _lilypond = (songLyric.lilypond ?? '')
        .replaceAll(_styleRE, '')
        .replaceAll(_heightRE, '')
        .replaceFirstMapped(_widthRE, (match) {
      _lilypondWidth = double.tryParse(match.group(1) ?? '');

      return '';
    });

    return _lilypond!;
  }
}
