import 'package:flutter/material.dart';
import 'package:flutter_reorderable_list/flutter_reorderable_list.dart';
import 'package:zpevnik/constants.dart';
import 'package:zpevnik/components/highlightable.dart';
import 'package:zpevnik/theme.dart';

class ReorderableRow extends StatelessWidget {
  final Widget child;
  final Function() onTap;
  final Function()? onLongPress;

  const ReorderableRow({
    required Key key,
    required this.child,
    required this.onTap,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ReorderableItem(key: key!, childBuilder: _childBuilder);
  }

  Widget _childBuilder(BuildContext context, ReorderableItemState state) {
    return Opacity(
      opacity: state == ReorderableItemState.placeholder ? 0 : (state == ReorderableItemState.dragProxy ? 0.75 : 1),
      child: _buildRow(context),
    );
  }

  Widget _buildRow(BuildContext context) {
    final iconColor = AppTheme.of(context).iconColor;

    return Highlightable(
      child: Row(
        children: [
          ReorderableListener(child: Icon(Icons.drag_handle, color: iconColor)),
          const SizedBox(width: kDefaultPadding),
          Expanded(child: child),
        ],
      ),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
}
