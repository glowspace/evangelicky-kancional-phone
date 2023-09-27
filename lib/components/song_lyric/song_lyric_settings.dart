import 'package:flutter/material.dart' hide Stepper;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zpevnik/components/bottom_sheet_section.dart';
import 'package:zpevnik/components/stepper.dart';
import 'package:zpevnik/constants.dart';
import 'package:zpevnik/components/highlightable.dart';
import 'package:zpevnik/components/selector_widget.dart';
import 'package:zpevnik/models/song_lyric.dart';
import 'package:zpevnik/providers/settings.dart';

class SongLyricSettingsWidget extends ConsumerWidget {
  final SongLyric songLyric;

  const SongLyricSettingsWidget({super.key, required this.songLyric});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final showChords =
        ref.watch(songLyricSettingsProvider(songLyric).select((songLyricSettings) => songLyricSettings.showChords));

    final accidentalsStyle = theme.textTheme.bodyMedium?.copyWith(
      fontFamily: 'KaiseiHarunoUmi',
      color: showChords ? null : theme.disabledColor,
    );

    return BottomSheetSection(
      title: 'Nastavení zobrazení',
      childrenPadding: false,
      children: [
        const SizedBox(height: kDefaultPadding),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding, vertical: kDefaultPadding / 2),
          child: Stepper(title: 'Transpozice', songLyric: songLyric, isEnabled: showChords),
        ),
        SelectorWidget(
          title: 'Posuvky',
          padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding, vertical: kDefaultPadding / 2),
          isEnabled: showChords,
          onSelected: ref.read(songLyricSettingsProvider(songLyric).notifier).changeAccidentals,
          segments: [
            ButtonSegment(value: 0, label: Text('#', style: accidentalsStyle, textAlign: TextAlign.center)),
            ButtonSegment(value: 1, label: Text('♭', style: accidentalsStyle, textAlign: TextAlign.center)),
          ],
          selected: ref
              .watch(songLyricSettingsProvider(songLyric).select((songLyricSettings) => songLyricSettings.accidentals)),
        ),
        SwitchListTile.adaptive(
          title: Text('Akordy', style: theme.textTheme.bodyMedium),
          activeColor: theme.colorScheme.primary,
          value: showChords,
          onChanged: (value) => ref.read(songLyricSettingsProvider(songLyric).notifier).changeShowChords(value),
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
        ),
        if (songLyric.hasLilypond)
          SwitchListTile.adaptive(
            title: Text('Zobrazit noty', style: theme.textTheme.bodyMedium),
            activeColor: theme.colorScheme.primary,
            contentPadding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
            dense: true,
            value: ref.watch(
                songLyricSettingsProvider(songLyric).select((songLyricSettings) => songLyricSettings.showMusicalNotes)),
            onChanged: ref.read(songLyricSettingsProvider(songLyric).notifier).changeShowMusicalNotes,
          ),
        const SizedBox(height: kDefaultPadding),
        Highlightable(
          onTap: ref.read(songLyricSettingsProvider(songLyric).notifier).reset,
          padding: const EdgeInsets.all(kDefaultPadding / 2),
          textStyle: theme.textTheme.bodySmall,
          child: const Text('Resetovat nastavení'),
        ),
      ],
    );
  }
}
