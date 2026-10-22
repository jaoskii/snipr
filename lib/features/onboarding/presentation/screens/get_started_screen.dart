import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../home/presentation/screens/home_screen.dart';

class _OnboardPage {
  final String imageAsset;
  final String line1;
  final String line2;
  final double imageSize;

  const _OnboardPage({
    required this.imageAsset,
    required this.line1,
    required this.line2,
    this.imageSize = 220,
  });
}

class GetStartedScreen extends StatefulWidget {
  const GetStartedScreen({super.key});

  @override
  State<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen> {
  final _controller = PageController();
  int _index = 0;

  static const _pages = [
    _OnboardPage(
      imageAsset: 'assets/brand/snipr-logo-on-dark.png',
      line1: 'Clip it.',
      line2: 'Ship it.',
      imageSize: 96,
    ),
    _OnboardPage(
      imageAsset: 'assets/brand/snipr-logo-on-dark.png',
      line1: 'Trim.',
      line2: 'Compress.',
      imageSize: 200,
    ),
    _OnboardPage(
      imageAsset: 'assets/brand/snipr-panda-on-dark.png',
      line1: 'Every play',
      line2: 'deserves a replay.',
      imageSize: 220,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _finish() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _next() {
    if (_index >= _pages.length - 1) {
      _finish();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _index == _pages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Keep a single snipR logo on the first screen (hero only).
            if (_index != 0)
              Image.asset(
                'assets/brand/snipr-wordmark-on-dark.png',
                height: 28,
                semanticLabel: 'Snipr',
              ).animate().fadeIn(duration: 400.ms)
            else
              const SizedBox(height: 28),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  final page = _pages[i];
                  final isFirst = i == 0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      children: [
                        const Spacer(flex: 2),
                        SizedBox(
                          height: isFirst ? 96 : page.imageSize,
                          width: isFirst ? 96 : double.infinity,
                          child: Image.asset(
                            page.imageAsset,
                            fit: BoxFit.contain,
                            alignment: Alignment.center,
                            semanticLabel: 'Snipr onboarding visual',
                          ),
                        )
                            .animate(key: ValueKey('hero-$i'))
                            .fadeIn(duration: 450.ms)
                            .slideY(begin: 0.08, curve: Curves.easeOut),
                        const Spacer(flex: 2),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                page.line1,
                                style: AppTheme.body(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                page.line2,
                                style: AppTheme.display(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w800,
                                  height: 1.15,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 36),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
              child: Row(
                children: [
                  _Stepper(count: _pages.length, index: _index),
                  const Spacer(),
                  TextButton(
                    onPressed: isLast ? _finish : _next,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: Text(
                      isLast ? 'Get started' : 'Next',
                      style: AppTheme.body(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (isLast)
                    IconButton(
                      onPressed: _finish,
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.hotPink,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.arrow_forward_rounded),
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

class _Stepper extends StatelessWidget {
  final int count;
  final int index;

  const _Stepper({required this.count, required this.index});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          margin: EdgeInsets.only(right: i == count - 1 ? 0 : 8),
          width: active ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? AppColors.textPrimary : AppColors.textPrimary.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(8),
          ),
        );
      }),
    );
  }
}
