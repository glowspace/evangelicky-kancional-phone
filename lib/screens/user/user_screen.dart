import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reorderable_list/flutter_reorderable_list.dart';
import 'package:provider/provider.dart';
import 'package:zpevnik/constants.dart';
import 'package:zpevnik/custom_icon_icons.dart';
import 'package:zpevnik/models/playlist.dart';
import 'package:zpevnik/providers/playlists_provider.dart';
import 'package:zpevnik/screens/components/highlightable_button.dart';
import 'package:zpevnik/screens/components/highlightable_row.dart';
import 'package:zpevnik/screens/components/menu_item.dart';
import 'package:zpevnik/screens/components/playlist_row.dart';
import 'package:zpevnik/screens/components/popup_menu.dart';
import 'package:zpevnik/screens/user/components/user_menu.dart';
import 'package:zpevnik/screens/user/favorite_screen.dart';
import 'package:zpevnik/status_bar_wrapper.dart';
import 'package:zpevnik/theme.dart';
import 'package:zpevnik/utils/platform.dart';
import 'package:zpevnik/screens/components/search_widget.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> with PlatformStateMixin {
  final _searchFieldFocusNode = FocusNode();

  ValueNotifier<bool> _showingMenu;
  ValueNotifier<GlobalKey> _showingMenuKey;
  Playlist _activePlaylist;

  bool _showingArchived;

  @override
  void initState() {
    super.initState();

    _showingArchived = false;
    _showingMenu = ValueNotifier(false);
    _showingMenuKey = ValueNotifier(null)
      ..addListener(() {
        _showingMenu.value = _showingMenuKey.value != null;

        if (_showingMenu.value) setState(() => {});
      });
    _activePlaylist = null;

    PlaylistsProvider.shared.addListener(_update);
  }

  @override
  Widget iOSWidget(BuildContext context) => StatusBarWrapper(child: CupertinoPageScaffold(child: _body(context)));

  @override
  Widget androidWidget(BuildContext context) => StatusBarWrapper(child: Scaffold(body: _body(context)));

  Widget _body(BuildContext context) {
    final playlists = PlaylistsProvider.shared.playlists;
    final archivedPlaylists = PlaylistsProvider.shared.archivedPlaylists;

    return SafeArea(
      child: Stack(
        children: [
          GestureDetector(
            onPanDown: _showingMenuKey.value == null ? null : (_) => _showingMenuKey.value = null,
            behavior: HitTestBehavior.translucent,
            child: Column(
              children: [
                Container(padding: EdgeInsets.symmetric(horizontal: kDefaultPadding), child: _searchWidget(context)),
                Scrollbar(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (PlaylistsProvider.shared.searchText.isEmpty)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 1.5 * kDefaultPadding, vertical: kDefaultPadding),
                            child: Text(
                              'Seznamy písní',
                              style: AppThemeNew.of(context).bodyTextStyle.copyWith(color: red),
                            ),
                          ),
                        if (PlaylistsProvider.shared.searchText.isEmpty)
                          HighlightableRow(
                              onPressed: () => Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) => FavoriteScreen()),
                                  ),
                              child: Row(
                                children: [
                                  Container(padding: EdgeInsets.only(right: kDefaultPadding), child: Icon(Icons.star)),
                                  Text('Písně s hvězdičkou', style: AppThemeNew.of(context).bodyTextStyle),
                                ],
                              )),
                        ReorderableList(
                          onReorder: _onReorder,
                          onReorderDone: _onReorderDone,
                          child: ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: playlists.length,
                            itemBuilder: (context, index) => PlaylistRow(
                              playlist: playlists[index],
                              select: (playlist) => _activePlaylist = playlist,
                              showingMenuKey: _showingMenuKey,
                              reorderable: true,
                            ),
                          ),
                        ),
                        if (archivedPlaylists.isNotEmpty)
                          GestureDetector(
                            onTap: () => setState(() => _showingArchived = !_showingArchived),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 1.5 * kDefaultPadding,
                                vertical: kDefaultPadding,
                              ),
                              child: Row(children: [
                                Container(
                                  padding: EdgeInsets.only(right: kDefaultPadding),
                                  child: Icon(Icons.archive_outlined),
                                ),
                                Expanded(child: Text('Archiv')),
                                // todo: add animation
                                Icon(_showingArchived ? Icons.arrow_upward : Icons.arrow_downward),
                              ]),
                            ),
                          ),
                        if (_showingArchived)
                          ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: archivedPlaylists.length,
                            itemBuilder: (context, index) => PlaylistRow(
                              playlist: archivedPlaylists[index],
                              select: (playlist) => _activePlaylist = playlist,
                              showingMenuKey: _showingMenuKey,
                              reorderable: false,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.all(kDefaultPadding),
                  child: Row(children: [
                    Text('Ostatní'),
                    Spacer(),
                    GestureDetector(onTap: () => _showUserMenu(context), child: Icon(Icons.menu)),
                  ]),
                ),
              ],
            ),
          ),
          if (playlists.isEmpty && archivedPlaylists.isEmpty)
            Center(
              child: GestureDetector(
                onTap: () => PlaylistsProvider.shared.showPlaylistDialog(context, callback: () => setState(() => {})),
                child: Container(
                  padding: EdgeInsets.all(kDefaultPadding),
                  child: Text(
                    'Nemáte žádný playlist. Vytvořit si jej můžete v${unbreakableSpace}náhledu písně nebo kliknutím na${unbreakableSpace}tento text.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          Positioned(right: kDefaultPadding, top: _top, child: _popupWidget)
        ],
      ),
    );
  }

  double get _top {
    if (_showingMenuKey.value == null || _showingMenuKey.value.currentContext == null) return 0;

    RenderBox box = _showingMenuKey.value.currentContext.findRenderObject();

    return box.localToGlobal(Offset.zero).dy;
  }

  Widget get _popupWidget {
    final isArchived = _activePlaylist != null && _activePlaylist.isArchived;

    return PopupMenu(
      showing: _showingMenu,
      border: Border.all(color: AppTheme.shared.borderColor(context)),
      animateHide: false, // todo: animate hide, it looks really bad now
      children: [
        MenuItem(
          title: 'Přejmenovat',
          icon: Icons.drive_file_rename_outline,
          onPressed: () => _showRenameDialog(context),
        ),
        if (!isArchived)
          MenuItem(
            title: 'Duplikovat',
            icon: CustomIcon.content_duplicate,
            onPressed: () {
              setState(() => PlaylistsProvider.shared.duplicate(_activePlaylist));
              _showingMenuKey.value = null;
            },
          ),
        MenuItem(
          title: isArchived ? 'Zrušit archivaci' : 'Archivovat',
          icon: Icons.archive,
          onPressed: () {
            setState(() => _activePlaylist.isArchived = !_activePlaylist.isArchived);
            _showingMenuKey.value = null;
          },
        ),
        if (isArchived)
          MenuItem(
            title: 'Odstranit',
            icon: Icons.delete,
            onPressed: () {
              setState(() => PlaylistsProvider.shared.remove(_activePlaylist));
              _showingArchived &= PlaylistsProvider.shared.archivedPlaylists.isNotEmpty;
              _showingMenuKey.value = null;
            },
          ),
      ],
    );
  }

  Widget _searchWidget(BuildContext context) => SearchWidget(
        key: PageStorageKey('user_screen_search_widget'),
        placeholder: 'Zadejte název seznamu písní',
        focusNode: _searchFieldFocusNode,
        search: PlaylistsProvider.shared.search,
        prefix: HighlightableButton(
          icon: Icon(Icons.search),
          onPressed: () => FocusScope.of(context).requestFocus(_searchFieldFocusNode),
        ),
      );

  void _showUserMenu(BuildContext context) => showPlatformBottomSheet(
        context: context,
        child: UserMenuWidget(),
        height: 0.5 * MediaQuery.of(context).size.height,
      );

  void _showRenameDialog(BuildContext context) {
    final textFieldController = TextEditingController()..text = _activePlaylist.name;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Přejmenovat playlist'),
        content: Container(
          child: TextField(
            decoration: InputDecoration(border: InputBorder.none, hintText: 'Název'),
            controller: textFieldController,
          ),
        ),
        actions: [
          TextButton(
            child: Text('Zrušit', style: AppThemeNew.of(context).bodyTextStyle.copyWith(color: Colors.red)),
            onPressed: () {
              Navigator.of(context).pop();
              _showingMenuKey.value = null;
            },
          ),
          // fixme: don't know better way to do it now, but there must be
          ChangeNotifierProvider.value(
            value: textFieldController,
            child: Consumer<TextEditingController>(
              builder: (context, controller, _) => TextButton(
                child: Text('Přejmenovat'),
                onPressed: controller.text.isEmpty
                    ? null
                    : () {
                        setState(() => _activePlaylist.name = controller.text);
                        Navigator.of(context).pop();
                        _showingMenuKey.value = null;
                      },
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _onReorder(Key from, Key to) {
    int fromIndex = PlaylistsProvider.shared.allPlaylists.indexWhere((playlist) => playlist.key == from);
    int toIndex = PlaylistsProvider.shared.allPlaylists.indexWhere((playlist) => playlist.key == to);

    final playlist = PlaylistsProvider.shared.allPlaylists[fromIndex];
    setState(() {
      PlaylistsProvider.shared.allPlaylists.removeAt(fromIndex);
      PlaylistsProvider.shared.allPlaylists.insert(toIndex, playlist);
    });
    return true;
  }

  void _onReorderDone(_) {
    for (int i = 0; i < PlaylistsProvider.shared.allPlaylists.length; i++)
      PlaylistsProvider.shared.allPlaylists[i].orderValue = i;
  }

  void _update() => setState(() {});

  @override
  void dispose() {
    PlaylistsProvider.shared.removeListener(_update);

    super.dispose();
  }
}
