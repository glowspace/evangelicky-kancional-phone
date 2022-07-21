import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zpevnik/components/highlightable.dart';
import 'package:zpevnik/components/section.dart';
import 'package:zpevnik/components/songbook/songbooks_list_view.dart';
import 'package:zpevnik/providers/data.dart';
import 'package:zpevnik/providers/navigation.dart';
import 'package:zpevnik/theme.dart';
import 'package:zpevnik/utils/extensions.dart';

const double _navigateNextIconSize = 20;

const _maxShowingSongbooksPhone = 3;
const _maxShowingSongbooksTablet = 4;

class SongbooksSection extends StatelessWidget {
  const SongbooksSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dataProvider = context.watch<DataProvider>();

    final showingSongbooks = dataProvider.songbooks
        .sublist(0, MediaQuery.of(context).isTablet ? _maxShowingSongbooksTablet : _maxShowingSongbooksPhone);

    return Section(
      title: Text('Zpěvníky', style: Theme.of(context).textTheme.titleLarge),
      child: SongbooksListView(
        songbooks: showingSongbooks,
        shrinkWrap: true,
        isCrossAxisCountMultipleOfTwo: true,
      ),
      action: Highlightable(
        onTap: () => NavigationProvider.of(context).pushNamed('/songbooks'),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Všechny zpěvníky',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).brightness.isLight ? lightTextColor : darkTextColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Icon(Icons.navigate_next, size: _navigateNextIconSize),
          ],
        ),
      ),
    );
  }
}
