import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zpevnik/models/song_lyric.dart';
import 'package:zpevnik/providers/data.dart';
import 'package:zpevnik/providers/settings.dart';
import 'package:zpevnik/components/song_lyric/utils/parser.dart';

final _styleRE = RegExp(r'\<style[^\<]*\<\/style\>');
final _heightRE = RegExp(r'height="([\d\.]+)mm"');
final _widthRE = RegExp(r'width="([\d\.]+)"');

class LyricsController extends ChangeNotifier {
  final SongLyric songLyric;
  final SongLyricsParser parser;

  final BuildContext context;

  LyricsController(this.songLyric, this.context) : parser = SongLyricsParser(songLyric);

  double? _lilypondWidth;
  String? _lilypond;

  String get title => songLyric.name;

  bool get hasLilypond => songLyric.lilypond != null;

  double get lilypondWidth => _lilypondWidth ?? 0;

  String lilypond(String hexColor) {
    if (_lilypond != null) return _lilypond!;

    updateLilypondColor(hexColor);

    return _lilypond!;
  }

  void updateLilypondColor(String hexColor) {
    _lilypond = (songLyric.lilypond ?? '')
        .replaceAll(_styleRE, '')
        .replaceAll('currentColor', hexColor)
        .replaceFirst(_heightRE, '')
        .replaceFirstMapped(_widthRE, (match) {
      _lilypondWidth = double.tryParse(match.group(1) ?? '');

      return '';
    });
  }

  // TODO: handle this when it has access to `SettingsProvider`
  bool get showChords => songLyric.showChords ?? true; //context.read<SettingsProvider>().showChords;
  int get accidentals => songLyric.accidentals ?? 1; //context.read<SettingsProvider>().accidentals;

  void changeTransposition(int byValue) {
    songLyric.transposition += byValue;

    if (songLyric.transposition.abs() == 12) songLyric.transposition = 0;

    _songLyricUpdated();
  }

  void accidentalsChanged(int accidentals) {
    songLyric.accidentals = accidentals;

    _songLyricUpdated();
  }

  void showChordsChanged(bool showChords) {
    songLyric.showChords = showChords;

    _songLyricUpdated();
  }

  void resetSettings() {
    songLyric.showChords = null;
    songLyric.accidentals = null;
    songLyric.transposition = 0;

    // TODO: handle this when it has access to `SettingsProvider`
    // context.read<SettingsProvider>().fontSizeScale = 1;

    _songLyricUpdated();
  }

  void _songLyricUpdated() {
    context.read<DataProvider>().store.box<SongLyric>().put(songLyric);

    notifyListeners();
  }
}
