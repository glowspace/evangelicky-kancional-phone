import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:zpevnik/providers/data_provider.dart';
import 'package:zpevnik/providers/song_lyrics_provider.dart';
import 'package:zpevnik/providers/tags_provider.dart';
import 'package:zpevnik/screens/components/custom_icon_button.dart';
import 'package:zpevnik/screens/components/song_lyrics_list.dart';
import 'package:zpevnik/screens/filters/widget.dart';
import 'package:zpevnik/theme.dart';
import 'package:zpevnik/utils/platform.dart';
import 'package:zpevnik/screens/components/search_widget.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with PlatformStateMixin {
  final SongLyricsProvider _songLyricsProvider = SongLyricsProvider(DataProvider.shared.songLyrics);

  final TagsProvider _tagsProvider = TagsProvider(DataProvider.shared.tags);

  @override
  Widget iOSWidget(BuildContext context) => CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: _searchWidget(context),
        ),
        child: _body(context),
      );

  @override
  Widget androidWidget(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: _searchWidget(context),
        ),
        body: _body(context),
      );

  Widget _body(BuildContext context) => SafeArea(
        child: ChangeNotifierProvider.value(value: _songLyricsProvider, child: SongLyricsListView()),
      );

  Widget _searchWidget(BuildContext context) => SearchWidget(
        placeholder: 'Zadejte slovo nebo číslo',
        search: _songLyricsProvider.search,
        leading: CustomIconButton(
          onPressed: null,
          icon: Icon(Icons.search, color: AppTheme.shared.searchFieldIconColor(context)),
        ),
        trailing: CustomIconButton(
          onPressed: () => _showFilters(context),
          icon: Icon(Icons.filter_list, color: AppTheme.shared.searchFieldIconColor(context)),
        ),
      );

  void _showFilters(BuildContext context) => showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
        ),
        builder: (context) => SizedBox(
          height: 0.67 * MediaQuery.of(context).size.height,
          child: ChangeNotifierProvider.value(
            value: _tagsProvider,
            child: FiltersWidget(),
          ),
        ),
        useRootNavigator: true,
      );

  // void _showFilters(BuildContext context) => showCupertinoModalBottomSheet(
  //       context: context,
  //       builder: (context, scrollController) => SizedBox(
  //         height: 0.67 * MediaQuery.of(context).size.height,
  //         child: ChangeNotifierProvider.value(
  //           value: _tagsProvider,
  //           child: FiltersWidget(key: Key('test')),
  //         ),
  //       ),
  //       useRootNavigator: true,
  //     );
}
