import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zpevnik/components/song_lyric/utils/parser.dart';
import 'package:zpevnik/models/model.dart';
import 'package:zpevnik/models/presentation.dart';
import 'package:zpevnik/utils/services/presentation.dart';

final presentationProvider = ChangeNotifierProvider((ref) => PresentationProvider());

class PresentationProvider extends ChangeNotifier {
  SongLyricsParser? _songLyricsParser;
  StreamController<PresentationData>? _showingDataStreamController;
  Function? _nextAction;

  bool _isPresenting = false;
  bool _isPresentingLocally = false;
  bool _isPaused = false;

  bool get isPresenting => _isPresenting;
  bool get isPresentingLocally => _isPresentingLocally;
  bool get isPaused => _isPaused;

  bool _isBeforeStart = false;
  bool _isAfterEnd = false;

  int _verseOrder = 0;

  PresentationData _showingData = defaultPresentationData;
  PresentationSettings get settings => _showingData.settings;

  PresentationData get showingData => _showingData;
  Stream<PresentationData> get showingDataStream => _showingDataStreamController!.stream;

  void start(SongLyricsParser songLyricsParser) async {
    _isPresenting = true;
    _isPresentingLocally = !(await onExternalDisplay);
    _verseOrder = 0;

    _songLyricsParser = songLyricsParser;

    if (_isPresentingLocally) {
      _showingDataStreamController = StreamController.broadcast(
        onListen: () => _changeShowingData(
          _showingData.copyWith(
            songLyricId: songLyricsParser.songLyric.id,
            name: songLyricsParser.songLyric.name,
            text: songLyricsParser.getVerse(_verseOrder),
          ),
        ),
      );
    } else {
      PresentationService.instance.startPresentation();
      _changeShowingData(_showingData.copyWith(
        songLyricId: songLyricsParser.songLyric.id,
        name: songLyricsParser.songLyric.name,
        text: songLyricsParser.getVerse(_verseOrder),
      ));
    }

    notifyListeners();
  }

  void stop() {
    _isPresenting = false;

    _showingDataStreamController?.close();

    PresentationService.instance.stopPresentation();

    notifyListeners();
  }

  void nextVerse() {
    if (_isAfterEnd) return;
    _isBeforeStart = false;

    _verseOrder++;

    final verse = _songLyricsParser!.getVerse(_verseOrder);
    if (verse.isEmpty) _isAfterEnd = true;

    if (isPaused) {
      _nextAction = () => _changeShowingData(_showingData.copyWith(text: verse));
    } else {
      _changeShowingData(_showingData.copyWith(text: verse));
    }
  }

  void prevVerse() {
    if (_isBeforeStart) return;
    _isAfterEnd = false;

    _verseOrder--;

    final verse = _songLyricsParser!.getVerse(_verseOrder);
    if (verse.isEmpty) _isBeforeStart = true;

    if (isPaused) {
      _nextAction = () => _changeShowingData(_showingData.copyWith(text: verse));
    } else {
      _changeShowingData(_showingData.copyWith(text: verse));
    }
  }

  void togglePause() {
    _isPaused = !_isPaused;

    if (!_isPaused) _nextAction?.call();

    notifyListeners();
  }

  void changeSettings(PresentationSettings settings) {
    _changeShowingData(_showingData.copyWith(settings: settings));

    notifyListeners();
  }

  void change(DisplayableItem displayableItem) {
    _verseOrder = 0;

    final changeFunction = displayableItem.when(
      bibleVerse: (bibleVerse) => () {
        _changeShowingData(_showingData.copyWith(
          songLyricId: null,
          name: bibleVerse.name,
          text: bibleVerse.text,
        ));
      },
      customText: (customText) => () {
        _changeShowingData(_showingData.copyWith(
          songLyricId: null,
          name: customText.name,
          text: customText.content,
        ));
      },
      songLyric: (songLyric) {
        final songLyricsParser = SongLyricsParser(songLyric);

        _songLyricsParser = songLyricsParser;

        return () {
          _changeShowingData(_showingData.copyWith(
            songLyricId: songLyricsParser.songLyric.id,
            name: songLyricsParser.songLyric.name,
            text: songLyricsParser.getVerse(_verseOrder),
          ));
        };
      },
    );

    // if presentation is paused store it as pending action otherwise execute it immediately
    if (isPaused) {
      _nextAction = changeFunction;
    } else {
      changeFunction();
    }
  }

  void _changeShowingData(PresentationData data) {
    _showingData = data;

    if (_isPresentingLocally) {
      _showingDataStreamController!.add(_showingData);
    } else {
      PresentationService.instance.transferData(data);
    }
  }

  Future<bool> get onExternalDisplay => PresentationService.instance.isExternalScreenConnected();
}
