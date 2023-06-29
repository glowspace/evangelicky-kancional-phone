import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zpevnik/components/highlightable.dart';
import 'package:zpevnik/constants.dart';
import 'package:zpevnik/models/external.dart';
import 'package:zpevnik/models/song_lyric.dart';

class SongLyricFilesWidget extends StatelessWidget {
  final SongLyric songLyric;

  const SongLyricFilesWidget({super.key, required this.songLyric});

  @override
  Widget build(BuildContext context) {
    final files = songLyric.files;

    return SafeArea(
      top: false,
      bottom: false,
      child: Wrap(
        children: [
          Container(
            padding: const EdgeInsets.all(kDefaultPadding),
            child: Text('Noty', style: Theme.of(context).textTheme.titleLarge),
          ),
          SingleChildScrollView(
            child: ListView.builder(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
              itemCount: files.length,
              itemBuilder: (context, index) => _buildFileTile(context, files[index]),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileTile(BuildContext context, External file) {
    return Highlightable(
      highlightBackground: true,
      onTap: () => file.mediaType == MediaType.pdf ? _pushPdf(context, file) : _pushJpg(context, file),
      padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding, vertical: kDefaultPadding / 2),
      child: Row(children: [
        const FaIcon(FontAwesomeIcons.filePdf),
        const SizedBox(width: kDefaultPadding),
        Expanded(child: Text(file.name)),
      ]),
    );
  }

  void _pushPdf(BuildContext context, External pdf) {
    Navigator.popAndPushNamed(context, '/pdf', arguments: pdf);
  }

  void _pushJpg(BuildContext context, External jpg) {
    Navigator.popAndPushNamed(context, '/jpg', arguments: jpg);
  }
}
