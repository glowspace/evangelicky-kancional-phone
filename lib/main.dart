import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zpevnik/constants.dart';
import 'package:zpevnik/providers/data.dart';
import 'package:zpevnik/route_generator.dart';

const _title = 'Zpěvník';

void main() {
  runApp(const MainWidget());
}

class MainWidget extends StatelessWidget {
  const MainWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final lightTheme = ThemeData.light().copyWith(
      scaffoldBackgroundColor: CupertinoColors.lightBackgroundGray,
      backgroundColor: Colors.white,
      colorScheme: ColorScheme.fromSeed(seedColor: blue),
      useMaterial3: true,
    );

    final darkTheme = ThemeData.dark().copyWith(
      scaffoldBackgroundColor: CupertinoColors.darkBackgroundGray,
      backgroundColor: Colors.black,
      colorScheme: ColorScheme.fromSeed(seedColor: blue, brightness: Brightness.dark),
      useMaterial3: true,
    );

    return ChangeNotifierProvider(
      create: (_) => DataProvider(),
      builder: (_, __) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: _title,
        theme: lightTheme,
        darkTheme: darkTheme,
        onGenerateRoute: RouteGenerator.generateRoute,
      ),
    );
  }
}
