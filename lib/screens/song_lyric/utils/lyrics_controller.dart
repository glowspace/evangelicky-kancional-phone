import 'package:flutter/material.dart';
import 'package:zpevnik/models/song_lyric.dart';
import 'package:zpevnik/providers/settings.dart';
import 'package:zpevnik/screens/song_lyric/utils/converter.dart';
import 'package:zpevnik/screens/song_lyric/utils/parser.dart';

final _styleRE = RegExp(r'\<style[^\<]*\<\/style\>');

class LyricsController extends ChangeNotifier {
  final SongLyric songLyric;
  final SettingsProvider settingsProvider;

  LyricsController(this.songLyric, this.settingsProvider)
      : _isProjectionEnabled = false,
        _currentlyProjectedVerse = 0;

  String get title => songLyric.name;
  bool get hasLilypond => songLyric.lilypond != null;

  String prepareLilypond(Color textColor) {
    String lilypond = songLyric.lilypond ?? '';

    final color =
        '#${textColor.red.toRadixString(16)}${textColor.green.toRadixString(16)}${textColor.blue.toRadixString(16)}';

    return lilypond.replaceAll(_styleRE, '').replaceAll('currentColor', color);
  }

  List<Verse>? _preparedLyrics;
  List<Verse>? _preparedLyricsNoChords;

  List<Verse> get preparedLyrics {
    if (_preparedLyrics == null) {
      _preparedLyrics ??= parseLyrics(songLyric.lyrics);

      _convertChords();
    }

    _preparedLyricsNoChords ??= parseLyrics(songLyric.lyrics, showChords: false);

    return showChords ? _preparedLyrics! : _preparedLyricsNoChords!;
  }

  bool _isProjectionEnabled;
  int _currentlyProjectedVerse;
  bool get isProjectionEnabled => _isProjectionEnabled;
  int get currentlyProjectedVerse => _currentlyProjectedVerse;

  void toggleisProjectionEnabled() {
    _isProjectionEnabled = !_isProjectionEnabled;

    if (isProjectionEnabled) _currentlyProjectedVerse = 0;

    notifyListeners();
  }

  void nextVerse() {
    if (_currentlyProjectedVerse + 1 < (_preparedLyrics?.length ?? 0)) _currentlyProjectedVerse += 1;

    notifyListeners();
  }

  void previousVerse() {
    if (_currentlyProjectedVerse > 0) _currentlyProjectedVerse -= 1;

    notifyListeners();
  }

  bool get showChords => songLyric.showChords ?? settingsProvider.showChords;
  int get accidentals => songLyric.accidentals ?? settingsProvider.accidentals;

  void changeTransposition(int byValue) {
    songLyric.transposition += byValue;

    _convertChords();

    notifyListeners();
  }

  void accidentalsChanged(int accidentals) {
    songLyric.accidentals = accidentals;

    _convertChords();

    notifyListeners();
  }

  void showChordsChanged(bool showChords) {
    songLyric.showChords = showChords;

    notifyListeners();
  }

  void resetSettings() {
    songLyric.showChords = null;
    songLyric.accidentals = null;
    songLyric.transposition = 0;

    settingsProvider.fontSizeScale = 1;

    _convertChords();

    notifyListeners();
  }

  void _convertChords() {
    for (final verse in _preparedLyrics ?? [])
      for (final line in verse.lines)
        for (final block in line.blocks)
          block.updatedChord = convertAccidentals(transpose(block.chord ?? '', songLyric.transposition), accidentals);
  }
}
