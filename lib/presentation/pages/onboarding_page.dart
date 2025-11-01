import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:jewelx/core/i18n/app_localizations.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  static const routeName = '/onboarding';

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late final PageController _controller;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final slides = _slides(t);
    final theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            onPageChanged: (value) => setState(() => _index = value),
            itemCount: slides.length,
            itemBuilder: (context, index) {
              final slide = slides[index];
              return Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(slide.image),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.35),
                      BlendMode.darken,
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 48),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              slide.title,
                              textAlign: TextAlign.start,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              slide.subtitle,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white70,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              );
            },
          ),
          Positioned(
            right: 24,
            top: MediaQuery.of(context).padding.top + 16,
            child: TextButton(
              onPressed: () => Navigator.of(context).pushReplacementNamed('/home'),
              child: Text(t.translate('skip')),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    slides.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      width: _index == index ? 16 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _index == index
                            ? theme.colorScheme.primary
                            : Colors.white54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () {
                    if (_index == slides.length - 1) {
                      Navigator.of(context)
                          .pushReplacementNamed('/auth/signin');
                    } else {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Text(
                    _index == slides.length - 1
                        ? t.translate('getStarted')
                        : t.translate('next'),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => Navigator.of(context)
                      .pushReplacementNamed('/home'),
                  child: Text(t.translate('guest')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<_Slide> _slides(AppLocalizations t) {
    return [
      _Slide(
        title: t.locale.languageCode == 'ar'
            ? 'تسوّق أرقى المجوهرات'
            : 'Shop Fine Jewelry',
        subtitle: t.locale.languageCode == 'ar'
            ? 'جديدة ومستعملة مع ضمان الحالة'
            : 'New & pre-owned with trusted condition',
        image: 'https://picsum.photos/seed/onb1/1200/900',
      ),
      _Slide(
        title: t.locale.languageCode == 'ar'
            ? 'عارض ثلاثي الأبعاد'
            : '3D Viewer',
        subtitle: t.locale.languageCode == 'ar'
            ? 'دوّر الخاتم وتفحّص التفاصيل'
            : 'Spin rings and inspect details',
        image: 'https://picsum.photos/seed/onb2/1200/900',
      ),
      _Slide(
        title: t.locale.languageCode == 'ar'
            ? 'أضف مقتنياتك وابدأ البيع'
            : 'Add your precious items',
        subtitle: t.locale.languageCode == 'ar'
            ? 'اعرض للبيع أو انتظر عروض الشراء'
            : 'List for sale or await offers',
        image: 'https://picsum.photos/seed/onb3/1200/900',
      ),
    ];
  }
}

class _Slide {
  const _Slide({required this.title, required this.subtitle, required this.image});

  final String title;
  final String subtitle;
  final String image;
}
