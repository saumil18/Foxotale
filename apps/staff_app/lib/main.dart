import 'package:flutter/material.dart';

import 'package:foxotale_domain/foxotale_domain.dart';
import 'app/scope.dart';
import 'app/shell.dart';
import 'data/repository.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/splash_screen.dart';
import 'features/setup/setup_wizard.dart';
import 'package:foxotale_ui/foxotale_ui.dart';

void main() => runApp(const FoxOtaleApp());

enum _Stage { splash, login, setup, app }

class FoxOtaleApp extends StatefulWidget {
  const FoxOtaleApp({super.key});

  @override
  State<FoxOtaleApp> createState() => _FoxOtaleAppState();
}

class _FoxOtaleAppState extends State<FoxOtaleApp> {
  final _repo = FoxRepository();
  ThemeMode _mode = ThemeMode.light;
  _Stage _stage = _Stage.splash;

  void _toggleTheme() => setState(
        () => _mode = _mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light,
      );

  void _signIn(FoxRole role) {
    _repo.role = role;
    // A role that can configure the property lands in setup while it is
    // unpublished; everyone else goes straight to work.
    final setsUp = Permissions.canEdit(role, Capability.propertySetup);
    setState(() =>
        _stage = setsUp && !_repo.draft.published ? _Stage.setup : _Stage.app);
  }

  @override
  void dispose() {
    _repo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FoxScope(
      repo: _repo,
      child: MaterialApp(
        title: 'FoxOtale Staff',
        debugShowCheckedModeBanner: false,
        theme: FoxTheme.light(),
        darkTheme: FoxTheme.dark(),
        themeMode: _mode,
        home: switch (_stage) {
          _Stage.splash =>
            SplashScreen(onDone: () => setState(() => _stage = _Stage.login)),
          _Stage.login => LoginScreen(onSignedIn: _signIn),
          _Stage.setup => SetupWizard(
              onFinished: () => setState(() => _stage = _Stage.app),
            ),
          _Stage.app => AppShell(
              onSignOut: () => setState(() => _stage = _Stage.login),
              onToggleTheme: _toggleTheme,
              onOpenSetup: () => setState(() => _stage = _Stage.setup),
            ),
        },
      ),
    );
  }
}
