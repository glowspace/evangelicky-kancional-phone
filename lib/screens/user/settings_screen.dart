import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zpevnik/constants.dart';
import 'package:zpevnik/providers/settings_provider.dart';
import 'package:zpevnik/screens/song_lyric/components/selector_widget.dart';
import 'package:zpevnik/theme.dart';
import 'package:zpevnik/utils/platform.dart';

class SettingsScreen extends StatelessWidget with PlatformWidgetMixin {
  @override
  Widget iOSWidget(BuildContext context) => CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(middle: Text('Nastavení')),
        child: _body(context),
      );

  @override
  Widget androidWidget(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Nastavení', style: AppTheme.of(context).bodyTextStyle),
          shadowColor: AppTheme.of(context).appBarDividerColor,
          brightness: AppTheme.of(context).brightness,
        ),
        body: _body(context),
      );

  Widget _body(BuildContext context) {
    final accidentalsStyle = AppTheme.of(context).bodyTextStyle.copyWith(fontSize: 20, fontFamily: 'Hiragino Sans');

    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(kDefaultPadding),
        child: Consumer<SettingsProvider>(
          builder: (context, settingsProvider, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _section(
                context,
                'Nastavení zobrazení',
                [
                  _row(
                      'Blokovat zhasínání displeje',
                      Switch(
                          value: settingsProvider.blockDisplayOff, onChanged: settingsProvider.changeBlockDisplayOff)),
                ],
              ),
              _section(
                context,
                'Nastavení písní',
                [
                  _row(
                    'Posuvky',
                    SelectorWidget(
                      onSelected: (index) => settingsProvider.accidentals = index == 1,
                      options: [
                        Text('#', style: accidentalsStyle, textAlign: TextAlign.center),
                        Text('♭', style: accidentalsStyle, textAlign: TextAlign.center)
                      ],
                      selected: settingsProvider.accidentals ? 1 : 0,
                    ),
                  ),
                  _row(
                    'Akordy',
                    SelectorWidget(
                      onSelected: (index) => settingsProvider.showChords = index == 1,
                      options: [
                        Icon(Icons.visibility_off),
                        Icon(Icons.visibility),
                      ],
                      selected: settingsProvider.showChords ? 1 : 0,
                    ),
                  ),
                  _fontSizeSlider(context),
                  _row(
                    'Zobrazit spodní nabídku',
                    Switch(
                      value: settingsProvider.showBottomOptions,
                      onChanged: settingsProvider.changeShowBottomOptions,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(BuildContext context, String title, List<Widget> children) => Container(
        padding: EdgeInsets.only(bottom: kDefaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTheme.of(context).subTitleTextStyle.copyWith(fontSize: 18)),
            Container(child: Column(children: children)),
          ],
        ),
      );

  Widget _row(String name, Widget widget) => Container(
        padding: EdgeInsets.symmetric(vertical: kDefaultPadding / 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(name), widget],
        ),
      );

  Widget _fontSizeSlider(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(vertical: kDefaultPadding / 2),
        child: Consumer<SettingsProvider>(
          builder: (context, settingsProvider, _) => Row(
            children: [
              RichText(
                text: TextSpan(text: 'A', style: AppTheme.of(context).bodyTextStyle),
                textScaleFactor: kMinimumFontSizeScale,
              ),
              Flexible(
                child: Slider(
                  min: kMinimumFontSizeScale,
                  max: kMaximumFontSizeScale,
                  value: settingsProvider.fontSizeScale,
                  onChanged: settingsProvider.changeFontSizeScale,
                  activeColor: AppTheme.of(context).chordColor,
                  inactiveColor: AppTheme.of(context).disabledColor,
                ),
              ),
              RichText(
                text: TextSpan(text: 'A', style: AppTheme.of(context).bodyTextStyle),
                textScaleFactor: kMaximumFontSizeScale,
              ),
            ],
          ),
        ),
      );
}
