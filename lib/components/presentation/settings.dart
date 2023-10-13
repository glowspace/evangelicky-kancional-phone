import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zpevnik/components/bottom_sheet_section.dart';
import 'package:zpevnik/constants.dart';
import 'package:zpevnik/providers/presentation.dart';

class PresentationSettingsWidget extends ConsumerWidget {
  const PresentationSettingsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    final settings = ref.watch(presentationProvider.select((presentationProvider) => presentationProvider.settings));

    return BottomSheetSection(
      title: 'Nastavení promítání',
      childrenPadding: false,
      children: [
        SwitchListTile.adaptive(
          title: Text('Zobrazovat pozadí', style: textTheme.bodyMedium),
          value: settings.showBackground,
          dense: true,
          onChanged: (value) =>
              ref.read(presentationProvider.notifier).changeSettings(settings.copyWith(showBackground: value)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 1.5 * kDefaultPadding),
        ),
        SwitchListTile.adaptive(
          title: Text('Světlé písmo', style: textTheme.bodyMedium),
          value: settings.darkMode,
          dense: true,
          onChanged: (value) =>
              ref.read(presentationProvider.notifier).changeSettings(settings.copyWith(darkMode: value)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 1.5 * kDefaultPadding),
        ),
        SwitchListTile.adaptive(
          title: Text('Zobrazovat název písně', style: textTheme.bodyMedium),
          value: settings.showName,
          dense: true,
          onChanged: (value) =>
              ref.read(presentationProvider.notifier).changeSettings(settings.copyWith(showName: value)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 1.5 * kDefaultPadding),
        ),
        SwitchListTile.adaptive(
          title: Text('Zobrazovat všechna písmena velká', style: textTheme.bodyMedium),
          value: settings.allCapital,
          dense: true,
          onChanged: (value) =>
              ref.read(presentationProvider.notifier).changeSettings(settings.copyWith(allCapital: value)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 1.5 * kDefaultPadding),
        ),
      ],
    );
  }
}
