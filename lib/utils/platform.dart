import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:zpevnik/theme.dart';

mixin PlatformWidgetMixin on StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;

    if (platform == TargetPlatform.iOS)
      return iOSWidget(context);
    else if (platform == TargetPlatform.android) return androidWidget(context);

    return Container();
  }

  Widget iOSWidget(BuildContext context);

  Widget androidWidget(BuildContext context);
}

mixin PlatformStateMixin<T extends StatefulWidget> on State<T> {
  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;

    if (platform == TargetPlatform.iOS)
      return iOSWidget(context);
    else if (platform == TargetPlatform.android) return androidWidget(context);

    return Container();
  }

  Widget iOSWidget(BuildContext context);

  Widget androidWidget(BuildContext context);
}

void showPlatformBottomSheet({BuildContext context, Widget child, double height}) {
  final content = SizedBox(
    height: height,
    child: child,
  );

  if (AppThemeNew.of(context).platform == TargetPlatform.iOS)
    showCupertinoModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
      builder: (context, scrollController) => Container(
        child: content,
        color: AppThemeNew.of(context).fillColor,
      ),
      useRootNavigator: true,
    );
  else
    showMaterialModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
      builder: (context, scrollController) => content,
      useRootNavigator: true,
    );
}
