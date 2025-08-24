import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'icon': CupertinoIcons.cube_box_fill,
      'title': 'Welcome to AssetWorks',
      'description': 'Create beautiful iOS 18 widgets',
    },
    {
      'icon': CupertinoIcons.sparkles,
      'title': 'AI-Powered',
      'description': 'Generate widgets with AI assistance',
    },
    {
      'icon': CupertinoIcons.person_3_fill,
      'title': 'Share & Discover',
      'description': 'Join our creative community',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          page['icon'],
                          size: 100,
                          color: CupertinoColors.systemIndigo,
                        ),
                        const SizedBox(height: 40),
                        Text(
                          page['title'],
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page['description'],
                          style: TextStyle(
                            fontSize: 17,
                            color: CupertinoColors.systemGrey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // Page indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? CupertinoColors.systemIndigo
                        : CupertinoColors.systemGrey3,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Action buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  if (_currentPage == _pages.length - 1) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: CupertinoButton.filled(
                        onPressed: () => Get.offNamed('/login'),
                        child: const Text('Get Started'),
                      ),
                    ),
                  ] else ...[
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: CupertinoButton.filled(
                        onPressed: () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: const Text('Next'),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  CupertinoButton(
                    onPressed: () => Get.offNamed('/login'),
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}