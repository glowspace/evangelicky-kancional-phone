import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:zpevnik/firebase_options.dart';
import 'package:zpevnik/models/objectbox.g.dart';
import 'package:zpevnik/providers/app_dependencies.dart';
import 'package:zpevnik/providers/settings.dart';
import 'package:zpevnik/routing/navigator_observer.dart';
import 'package:zpevnik/routing/router.dart';
import 'package:zpevnik/screens/presentation.dart';
import 'package:zpevnik/theme.dart';

const _title = 'Zpěvník';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final appDependencies = AppDependencies(
    sharedPreferences: await SharedPreferences.getInstance(),
    store: await openStore(),
    ftsDatabase: await openDatabase(join(await getDatabasesPath(), 'zpevnik.db')),
    packageInfo: await PackageInfo.fromPlatform(),
  );

  return runApp(ProviderScope(
    observers: [MyProviderObserver()],
    overrides: [appDependenciesProvider.overrideWithValue(appDependencies)],
    child: const MainWidget(),
  ));
}

class MainWidget extends ConsumerWidget {
  const MainWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkModeEnabled = ref.watch(settingsProvider.select((settings) => settings.darkModeEnabled));
    final primaryColor = ref.watch(settingsProvider.select((settings) => Color(settings.primaryColor)));

    ThemeMode? themeMode;

    if (darkModeEnabled != null) {
      if (darkModeEnabled) {
        themeMode = ThemeMode.dark;
      } else {
        themeMode = ThemeMode.light;
      }
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: _title,
      theme: AppTheme.light(primaryColor),
      darkTheme: AppTheme.dark(primaryColor),
      themeMode: themeMode,
      // must be without leading '/', otherwise navigation stack will be `HomeScreen` > `InitialScreen`
      // and when replacing `InitialScreen` it will result to `HomeScreen` > `HomeScreen`
      // this is because of deeplinking, when all screens in path are pushed to stack as well
      initialRoute: 'initial',
      onGenerateRoute: AppRouter.generateRoute,
      navigatorObservers: [ref.read(appNavigatorObserverProvider)],
    );
  }
}

@pragma('vm:entry-point')
void mainPresentation() => runApp(const MainPresentation());

class MainPresentation extends StatelessWidget {
  const MainPresentation({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(debugShowCheckedModeBanner: false, title: _title, home: PresentationScreen());
  }
}

class MyProviderObserver extends ProviderObserver {
  @override
  void didAddProvider(ProviderBase<Object?> provider, Object? value, ProviderContainer container) {
    super.didAddProvider(provider, value, container);

    log('added provider: $provider');
  }

  @override
  void didUpdateProvider(
      ProviderBase<Object?> provider, Object? previousValue, Object? newValue, ProviderContainer container) {
    super.didUpdateProvider(provider, previousValue, newValue, container);

    log('updated provider: $provider');
  }

  @override
  void didDisposeProvider(ProviderBase<Object?> provider, ProviderContainer container) {
    super.didDisposeProvider(provider, container);

    log('disposed provider: $provider');
  }

  @override
  void providerDidFail(
      ProviderBase<Object?> provider, Object error, StackTrace stackTrace, ProviderContainer container) {
    super.providerDidFail(provider, error, stackTrace, container);

    log('provider failed: $provider, $error, $stackTrace');
  }
}
