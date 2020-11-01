import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:zpevnik/models/songLyric.dart';
import 'package:zpevnik/models/tag.dart';
import 'package:zpevnik/providers/data_provider.dart';
import 'package:zpevnik/providers/tags_provider.dart';

class SongLyricsProvider extends ChangeNotifier {
  final List<SongLyric> _allSongLyrics;

  final TagsProvider _tagsProvider;

  List<SongLyric> _songLyrics;

  String _searchText;

  SongLyricsProvider(this._allSongLyrics)
      : _searchText = '',
        _songLyrics = _allSongLyrics,
        _tagsProvider = TagsProvider(DataProvider.shared.tags) {
    _tagsProvider.addListener(_update);
  }

  List<SongLyric> get songLyrics => _songLyrics;

  TagsProvider get tagsProvider => _tagsProvider;

  void search(String searchText) {
    _searchText = searchText;

    _update();
  }

  List<bool Function(SongLyric, String)> get _predicates => [
        (songLyric, searchText) => songLyric.name.toLowerCase().startsWith(searchText),
        (songLyric, searchText) => removeDiacritics(songLyric.name.toLowerCase()).startsWith(searchText),
        (songLyric, searchText) => songLyric.name.toLowerCase().contains(searchText),
        (songLyric, searchText) => removeDiacritics(songLyric.name.toLowerCase()).contains(searchText),
        (songLyric, searchText) => songLyric.numbers.any((number) => number.toLowerCase().contains(searchText)),
        (songLyric, searchText) => removeDiacritics(songLyric.entity.lyrics.toLowerCase()).contains(searchText),
      ];

  List<SongLyric> _filter(List<SongLyric> songLyrics) {
    Map<TagType, List<Tag>> tagGroups = {};

    for (final tag in _tagsProvider.selectedTags) {
      if (!tagGroups.containsKey(tag.type)) tagGroups[tag.type] = [];

      tagGroups[tag.type].add(tag);
    }

    return songLyrics
        .where((songLyric) => tagGroups.entries
            .map((entry) => songLyric.entity.tags.any((tag) => entry.value.any((other) => tag.id == other.id)))
            .reduce((value, element) => value && element))
        .toList();
  }

  void _update() {
    final predicates = _predicates;

    List<SongLyric> filtered = _tagsProvider.selectedTags.isEmpty ? _allSongLyrics : _filter(_allSongLyrics);

    List<List<SongLyric>> searchResults = List<List<SongLyric>>.generate(predicates.length, (index) => []);

    for (final songLyric in filtered) {
      for (int i = 0; i < predicates.length; i++) {
        if (predicates[i](songLyric, _searchText.toLowerCase())) {
          searchResults[i].add(songLyric);
          break;
        }
      }
    }

    _songLyrics = searchResults.reduce((result, list) {
      result.addAll(list);
      return result;
    }).toList();

    notifyListeners();
  }

  @override
  void dispose() {
    _tagsProvider.removeListener(_update);

    super.dispose();
  }
}
