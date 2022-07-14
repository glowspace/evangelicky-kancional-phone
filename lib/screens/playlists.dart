import 'package:flutter/material.dart';
import 'package:zpevnik/components/custom/back_button.dart';
import 'package:zpevnik/components/playlist/playlists_list_view.dart';
import 'package:zpevnik/components/playlist/dialogs.dart';

class PlaylistsScreen extends StatelessWidget {
  const PlaylistsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const CustomBackButton(),
        title: const Text('Moje seznamy'),
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).canvasColor,
        child: const Icon(Icons.add),
        onPressed: () => showPlaylistDialog(context),
      ),
      body: const SafeArea(child: PlaylistsListView()),
    );
  }
}
