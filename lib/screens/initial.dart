import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:zpevnik/components/highlightable.dart';
import 'package:zpevnik/components/logo.dart';
import 'package:zpevnik/components/section.dart';
import 'package:zpevnik/components/sign_in_button.dart';
import 'package:zpevnik/constants.dart';
import 'package:zpevnik/components/custom/future_builder.dart';
import 'package:zpevnik/providers/update.dart';
import 'package:zpevnik/theme.dart';
import 'package:zpevnik/utils/extensions.dart';

const _welcomeText = '''
Ahoj. Vítej ve Zpěvníku!

Nyní se můžeš přihlásit do${unbreakableSpace}svého uživatelského účtu. To ti zajistí automatickou synchronizaci seznamů písní a${unbreakableSpace}spoustu dalších výhod.''';

const _projectDescription = 'Projekt ProScholy.cz tvoří s${unbreakableSpace}láskou dobrovolníci z komunity Glow Space.';

const _animationDuration = Duration(milliseconds: 800);

const _loggedInKey = 'loggedIn';

class InitialScreen extends ConsumerStatefulWidget {
  const InitialScreen({super.key});

  @override
  ConsumerState<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends ConsumerState<InitialScreen> {
  final bool _showSignInButtons = false;

  @override
  void initState() {
    super.initState();

    _init();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    final height = mediaQuery.size.height - mediaQuery.padding.top;

    return Scaffold(
      backgroundColor: Theme.of(context).brightness.isLight ? lightBackgroundColor : darkBackgroundColor,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            SizedBox(
              height: height,
              child: AnimatedAlign(
                duration: _animationDuration,
                alignment: _showSignInButtons ? Alignment.bottomCenter : Alignment.center,
                child: SingleChildScrollView(
                  child: Column(children: [
                    const SizedBox(height: 2 * kDefaultPadding),
                    const Logo(),
                    AnimatedAlign(
                      duration: _animationDuration,
                      alignment: Alignment.topCenter,
                      heightFactor: _showSignInButtons ? 1 : 0,
                      child: AnimatedOpacity(
                        duration: _animationDuration,
                        opacity: _showSignInButtons ? 1 : 0,
                        child: Column(
                          children: [
                            _buildSignInSection(context),
                            _buildProjectSection(context),
                          ],
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ),
            Visibility(
              visible: !_showSignInButtons,
              child: Container(padding: const EdgeInsets.all(kDefaultPadding), child: const GlowspaceLogo()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignInSection(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Section(
      margin: const EdgeInsets.all(2 * kDefaultPadding).copyWith(bottom: kDefaultPadding),
      padding: const EdgeInsets.all(2 * kDefaultPadding),
      children: [
        Text(_welcomeText, style: textTheme.bodyMedium),
        const SizedBox(height: 2 * kDefaultPadding),
        const SignInButton(type: SignInButtonType.google),
        const SizedBox(height: kDefaultPadding),
        CustomFutureBuilder<bool>(
          future: SignInWithApple.isAvailable(),
          builder: (_, isAvailable) => (isAvailable ?? false)
              ? SignInButton(type: SignInButtonType.apple, onSignIn: () => _signInWithApple(context))
              : Container(),
        ),
        const SizedBox(height: kDefaultPadding),
        SignInButton(type: SignInButtonType.noSignIn, onSignIn: () => _pushHomeScreen(context)),
      ],
    );
  }

  Widget _buildProjectSection(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Section(
      margin: const EdgeInsets.all(2 * kDefaultPadding).copyWith(top: kDefaultPadding),
      padding: const EdgeInsets.all(kDefaultPadding).copyWith(bottom: 0),
      children: [
        const GlowspaceLogo(showDescription: true),
        const SizedBox(height: kDefaultPadding),
        Text(_projectDescription, style: textTheme.bodyMedium),
        Highlightable(
          onTap: () => _learnMore(context),
          foregroundColor: theme.colorScheme.primary,
          child: const Text('Dozvědět se více'),
        ),
      ],
    );
  }

  Future<void> _init() async {
    await loadInitial(ref);

    // _pushHomeScreen(context);

    // setState(() => _showSignInButtons = true);
  }

  void _signInWithApple(BuildContext context) async {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    _pushHomeScreen(context);
  }

  void _pushHomeScreen(BuildContext context) {
    context.replace('/');
  }

  void _learnMore(BuildContext context) {}
}
