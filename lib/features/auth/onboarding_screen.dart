import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class _OnboardingPage {
  final String emoji;
  final String title;
  final String subtitle;
  final Color accent;

  const _OnboardingPage({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.accent,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  final _pages = const [
    _OnboardingPage(
      emoji: '🚛',
      title: 'On-demand\nwaste pickup',
      subtitle: 'Book a collection in 3 taps. A certified hauler comes to your door.',
      accent: Color(0xFF76FF03),
    ),
    _OnboardingPage(
      emoji: '♻️',
      title: 'Sort & track\nyour impact',
      subtitle: 'Separate plastics, paper, glass, and organics. Watch your recycling grow.',
      accent: Color(0xFF40C4FF),
    ),
    _OnboardingPage(
      emoji: '📍',
      title: 'Live hauler\ntracking',
      subtitle: 'See your hauler on a map in real-time. Know exactly when they\'ll arrive.',
      accent: Color(0xFFAB47BC),
    ),
    _OnboardingPage(
      emoji: '📱',
      title: 'Pay with\nmobile money',
      subtitle: 'Seamless MoMo payments. Airtel Money, TNM Mpamba, M-Pesa — all accepted.',
      accent: Color(0xFFFFD740),
    ),
  ];

  void _next() {
    if (_page < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      context.go('/auth/phone');
    }
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_page];
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => context.go('/auth/phone'),
                child: const Text('Skip', style: TextStyle(color: AppColors.textMuted)),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                itemCount: _pages.length,
                itemBuilder: (_, i) {
                  final p = _pages[i];
                  return _PageContent(page: p);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: i == _page ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i == _page ? page.accent : AppColors.card,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    )),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _next,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: page.accent,
                      foregroundColor: Colors.black,
                    ),
                    child: Text(
                      _page == _pages.length - 1 ? 'Get Started' : 'Next',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageContent extends StatelessWidget {
  final _OnboardingPage page;
  const _PageContent({required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: page.accent.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: page.accent.withOpacity(0.3), width: 2),
            ),
            child: Center(
              child: Text(page.emoji, style: const TextStyle(fontSize: 72)),
            ),
          ),
          const SizedBox(height: 48),
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.1,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            page.subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
