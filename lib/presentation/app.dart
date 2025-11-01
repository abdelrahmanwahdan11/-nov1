import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'controllers/app_controller.dart';
import 'controllers/auth_controller.dart';
import 'controllers/catalog_controller.dart';
import 'controllers/cart_controller.dart';
import 'controllers/checkout_controller.dart';
import 'controllers/saved_searches_controller.dart';
import 'controllers/compare_controller.dart';
import 'controllers/controllers_scope.dart';
import 'controllers/messages_controller.dart';
import 'controllers/my_items_controller.dart';
import 'controllers/notification_controller.dart';
import 'controllers/scroll_memory.dart';
import 'package:jewelx/core/i18n/app_localizations.dart';
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
import 'pages/messages_page.dart';
import 'pages/saved_searches_page.dart';
import 'pages/my_items_page.dart';
import 'pages/notifications_page.dart';
import 'pages/profile_page.dart';
import 'pages/order_success_page.dart';
import 'pages/root_shell.dart';
import 'pages/search_page.dart';
import 'pages/settings_page.dart';
import 'pages/splash_page.dart';
import 'package:jewelx/core/theme/app_theme.dart';
import 'pages/onboarding_page.dart';
import 'pages/checkout_page.dart';
import 'pages/state_screen.dart';
import 'widgets/jewel_loader.dart';

class JewelXApp extends StatefulWidget {
  const JewelXApp({super.key});

  @override
  State<JewelXApp> createState() => _JewelXAppState();
}

class _JewelXAppState extends State<JewelXApp> {
  final AppController _appController = AppController();
  final AuthController _authController = AuthController();
  final CatalogController _catalogController = CatalogController();
  final CompareController _compareController = CompareController();
  final MyItemsController _myItemsController = MyItemsController();
  final CartController _cartController = CartController();
  final CheckoutController _checkoutController = CheckoutController();
  final MessagesController _messagesController = MessagesController();
  final NotificationController _notificationController = NotificationController();
  final SavedSearchesController _savedSearchesController = SavedSearchesController();
  final ScrollMemory _scrollMemory = ScrollMemory();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    _catalogController.bindMyItems(_myItemsController);
    _myItemsController.bindNotificationController(_notificationController);
    _savedSearchesController
      ..bindCatalog(_catalogController)
      ..bindNotifications(_notificationController);
    await Future.wait([
      _appController.initialize(),
      _authController.initialize(),
      _catalogController.initialize(),
      _messagesController.loadFromPrefs(),
      _savedSearchesController.initialize(),
      _scrollMemory.initialize(),
    ]);
    setState(() => _initialized = true);
  }

  @override
  void dispose() {
    _appController.dispose();
    _authController.dispose();
    _catalogController.dispose();
    _compareController.dispose();
    _myItemsController.dispose();
    _cartController.dispose();
    _checkoutController.dispose();
    _messagesController.dispose();
    _notificationController.dispose();
    _savedSearchesController.dispose();
    _scrollMemory.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.transparent,
          body: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFE1EA), Color(0xFFFFC7D1)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Center(child: JewelLoader()),
          ),
        ),
      );
    }
    return ControllersScope(
      appController: _appController,
      authController: _authController,
      catalogController: _catalogController,
      compareController: _compareController,
      myItemsController: _myItemsController,
      cartController: _cartController,
      checkoutController: _checkoutController,
      messagesController: _messagesController,
      notificationController: _notificationController,
      savedSearchesController: _savedSearchesController,
      scrollMemory: _scrollMemory,
      child: AnimatedBuilder(
        animation: _appController,
        builder: (context, _) {
          final seed = _appController.seedColor;
          final alpha = _appController.alpha;
          final locale = _appController.locale;
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
            theme: AppTheme.light(seed, alpha),
            darkTheme: AppTheme.dark(seed, alpha),
            themeMode: _appController.isDark ? ThemeMode.dark : ThemeMode.light,
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
              '/checkout': (context) => const CheckoutPage(),
              '/messages': (context) => const MessagesPage(),
              '/notifications': (context) => const NotificationsPage(),
              '/settings': (context) => const SettingsPage(),
              SavedSearchesPage.routeName: (context) => const SavedSearchesPage(),
              '/my-items': (context) => const MyItemsPage(),
              '/profile': (context) => const ProfilePage(),
              OrderSuccessPage.routeName: (context) => const OrderSuccessPage(),
              '/state/empty': (context) => const JewelStateScreen(variant: JewelStateVariant.empty),
              '/state/error': (context) => const JewelStateScreen(variant: JewelStateVariant.error),
              '/state/offline': (context) => const JewelStateScreen(variant: JewelStateVariant.offline),
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
            builder: (context, child) {
              final theme = Theme.of(context);
              final tokens = theme.extension<JewelThemeTokens>();
              final gradient =
                  theme.brightness == Brightness.dark ? tokens?.darkGradient : tokens?.lightGradient;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                decoration: BoxDecoration(
                  gradient: gradient ??
                      LinearGradient(
                        colors: const [Color(0xFFFFE1EA), Color(0xFFFFC7D1)]
                            .map((c) => Color.lerp(c, seed, 0.12)?.withOpacity(alpha) ??
                                c.withOpacity(alpha))
                            .toList(),
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                ),
                child: child ?? const SizedBox.shrink(),
              );
            },
          );
        },
      ),
    );
  }
}
