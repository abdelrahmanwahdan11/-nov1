import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'controllers/auth_controller.dart';
import 'controllers/catalog_controller.dart';
import 'controllers/compare_controller.dart';
import 'controllers/controllers_scope.dart';
import 'controllers/my_items_controller.dart';
import 'controllers/notification_controller.dart';
import 'controllers/theme_controller.dart';
import 'l10n/app_localizations.dart';
import 'pages/auth/forgot_password_page.dart';
import 'pages/auth/sign_in_page.dart';
import 'pages/auth/sign_up_page.dart';
import 'pages/cars_catalog_page.dart';
import 'pages/compare_page.dart';
import 'pages/cart_page.dart';
import 'pages/catalog_page.dart';
import 'pages/details_page.dart';
import 'pages/favorites_page.dart';
import 'pages/home_dashboard_page.dart';
import 'pages/my_items_page.dart';
import 'pages/notifications_page.dart';
import 'pages/profile_page.dart';
import 'pages/root_shell.dart';
import 'pages/search_page.dart';
import 'pages/settings_page.dart';
import 'pages/splash_page.dart';
import 'theme/app_theme.dart';
import 'pages/onboarding_page.dart';

class JewelXApp extends StatefulWidget {
  const JewelXApp({super.key});

  @override
  State<JewelXApp> createState() => _JewelXAppState();
}

class _JewelXAppState extends State<JewelXApp> {
  final ThemeController _themeController = ThemeController();
  final AuthController _authController = AuthController();
  final CatalogController _catalogController = CatalogController();
  final CompareController _compareController = CompareController();
  final MyItemsController _myItemsController = MyItemsController();
  final NotificationController _notificationController = NotificationController();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    _catalogController.bindMyItems(_myItemsController);
    _myItemsController.bindNotificationController(_notificationController);
    await Future.wait([
      _themeController.initialize(),
      _authController.initialize(),
      _catalogController.loadInitial(),
    ]);
    setState(() => _initialized = true);
  }

  @override
  void dispose() {
    _themeController.dispose();
    _authController.dispose();
    _catalogController.dispose();
    _compareController.dispose();
    _myItemsController.dispose();
    _notificationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const MaterialApp(home: SizedBox.shrink());
    }
    return ControllersScope(
      themeController: _themeController,
      authController: _authController,
      catalogController: _catalogController,
      compareController: _compareController,
      myItemsController: _myItemsController,
      notificationController: _notificationController,
      child: AnimatedBuilder(
        animation: _themeController,
        builder: (context, _) {
          final primary = _themeController.primaryColor;
          final locale = _themeController.locale;
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'JewelX',
            locale: locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            theme: AppTheme.light(primary),
            darkTheme: AppTheme.dark(primary),
            themeMode: _themeController.isDark ? ThemeMode.dark : ThemeMode.light,
            initialRoute: SplashPage.routeName,
            routes: {
              SplashPage.routeName: (context) => const SplashPage(),
              OnboardingPage.routeName: (context) => const OnboardingPage(),
              SignInPage.routeName: (context) => const SignInPage(),
              SignUpPage.routeName: (context) => const SignUpPage(),
              ForgotPasswordPage.routeName: (context) => const ForgotPasswordPage(),
              '/home': (context) => const RootShell(),
              '/catalog/jewelry': (context) => const CatalogPage(),
              '/search': (context) => const SearchPage(),
              DetailsPage.routeName: (context) => const DetailsPage(),
              '/compare/jewelry': (context) => const JewelryComparePage(),
              '/compare/cars': (context) => const CarComparePage(),
              '/catalog/cars': (context) => const CarsCatalogPage(),
              '/favorites': (context) => const FavoritesPage(),
              '/cart': (context) => const CartPage(),
              '/notifications': (context) => const NotificationsPage(),
              '/settings': (context) => const SettingsPage(),
              '/my-items': (context) => const MyItemsPage(),
              '/profile': (context) => const ProfilePage(),
            },
            onGenerateRoute: (settings) {
              if (settings.name == DetailsPage.routeName) {
                return MaterialPageRoute(
                  builder: (context) => const DetailsPage(),
                  settings: settings,
                );
              }
              return null;
            },
          );
        },
      ),
    );
  }
}
