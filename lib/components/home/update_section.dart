import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zpevnik/components/highlightable.dart';
import 'package:zpevnik/components/section.dart';
import 'package:zpevnik/components/song_lyric/song_lyric_row.dart';
import 'package:zpevnik/constants.dart';
import 'package:zpevnik/links.dart';
import 'package:zpevnik/providers/data.dart';
import 'package:zpevnik/providers/utils/updater.dart';

class UpdateSection extends StatelessWidget {
  const UpdateSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final updater = context.read<DataProvider>().updater;

    return ValueListenableBuilder<UpdaterState>(
      valueListenable: updater.state,
      builder: (context, value, __) => updater.isUpdating ? _buildUpdateInfo(context, value) : Container(),
    );
  }

  Widget _buildUpdateInfo(BuildContext context, UpdaterState state) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final Text text;

    if (state is UpdaterStateLoading) {
      text = Text('Probíhá stahování písní', style: textTheme.bodyMedium);
    } else if (state is UpdaterStateUpdating) {
      text = Text('Probíhá stahování písní ($state)', style: textTheme.bodyMedium);
    } else if (state is UpdaterStateDone) {
      text = Text('Počet aktualizovaných písní: ${state.updatedCount}', style: textTheme.bodyMedium);
    } else if (state is UpdaterStateError) {
      text = Text('Nastala chyba při aktualizaci', style: textTheme.bodyMedium);
    } else {
      text = Text('', style: textTheme.bodyMedium);
    }

    return Container(
      padding: const EdgeInsets.only(bottom: 2 * kDefaultPadding),
      child: Section(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    text,
                    if (state is UpdaterStateError || state is UpdaterStateDone)
                      const SizedBox(height: kDefaultPadding / 2),
                    if (state is UpdaterStateError)
                      Highlightable(
                        onTap: () => launchUrl(
                            Uri.parse('$reportUrl?summary=Chyba při aktualizaci písní&description=${state.error}')),
                        child: Text('Nahlásit chybu', style: textTheme.bodyMedium?.copyWith(color: red)),
                      ),
                    if (state is UpdaterStateDone)
                      Highlightable(
                        onTap: () => Navigator.of(context).pushNamed('/updated_song_lyrics'),
                        child:
                            Text('Zobrazit', style: textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary)),
                      ),
                  ],
                ),
              ),
              if (state is UpdaterStateDone || state is UpdaterStateError)
                Highlightable(
                  onTap: () => context.read<DataProvider>().updater.state.value = UpdaterStateIdle(),
                  child: const Icon(Icons.close),
                )
            ]),
            if (state is UpdaterStateUpdating)
              Container(
                padding: const EdgeInsets.only(top: kDefaultPadding / 2),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(kDefaultRadius)),
                child: AnimatedSize(
                  alignment: Alignment.centerLeft,
                  curve: Curves.easeInOut,
                  duration: updateAnimationDuration,
                  child: Container(
                    width: state.current / state.count * (MediaQuery.of(context).size.width - 4 * kDefaultPadding),
                    height: 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(kDefaultRadius),
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
