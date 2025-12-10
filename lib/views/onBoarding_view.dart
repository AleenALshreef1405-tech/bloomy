import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'create_acc_view.dart';

class OnBoardingView extends StatefulWidget {
  const OnBoardingView({super.key});

  @override
  State<OnBoardingView> createState() => _OnBoardingViewState();
}

class _OnBoardingViewState extends State<OnBoardingView> {
  final introKey = GlobalKey<IntroductionScreenState>();

  final Color backgroundColor = const Color(0xFFFFF5F2);
  final Color primaryColor = const Color(0xFF064232); 
  final Color secondaryColor = const Color(0xFFD3CBC5); 

  int currentPageIndex = 0;

  void _onIntroEnd(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const CreateAccView()),
    );
  }

  Widget _buildImage(String assetName, [double width = 250]) {
    return Image.asset('assets/images/$assetName', width: width);
  }

  @override
  Widget build(BuildContext context) {
    const titleStyle = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    );
    const bodyStyle = TextStyle(
      fontSize: 16,
      color: Colors.black87,
    );

    final pageDecoration = PageDecoration(
      titleTextStyle: titleStyle,
      bodyTextStyle: bodyStyle,
      imageAlignment: Alignment.topCenter,
      bodyAlignment: Alignment.center,
      pageColor: backgroundColor,
      contentMargin: const EdgeInsets.symmetric(horizontal: 24),
      imagePadding: const EdgeInsets.only(top: 60),
    );

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          IntroductionScreen(
            key: introKey,
            globalBackgroundColor: backgroundColor,
            showNextButton: false,
            showSkipButton: false,
            showDoneButton: false,
            onChange: (index) {
              setState(() {
                currentPageIndex = index;
              });
            },
            pages: [
              PageViewModel(
                title: "Express Your Daily Feelings",
                body:
                    "Track your emotions easily and understand your mood better each day.",
                image: _buildImage('onboarding1.png'),
                decoration: pageDecoration,
              ),
              PageViewModel(
                title: "Choose Your Flower Every Day",
                body:
                    "Pick a flower that reflects how you feel — each one tells your unique story.",
                image: _buildImage('onboarding2.png'),
                decoration: pageDecoration,
              ),
              PageViewModel(
                title: "Create Your Garden",
                body:
                    "Watch your emotional garden bloom as you grow with every feeling you express.",
                image: _buildImage('onboarding3.png'),
                decoration: pageDecoration,
              ),
            ],

              dotsDecorator: DotsDecorator(
              spacing: const EdgeInsets.symmetric(horizontal: 6),
              size: const Size(10.0, 10.0),

              color: Colors.transparent, 
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.grey.withOpacity(0.5), width: 1.2),
                borderRadius: BorderRadius.circular(50.0),
              ),

              activeSize: const Size(24.0, 10.0),
              activeColor: Color(0xFF064232), 
              activeShape: RoundedRectangleBorder(
                side: BorderSide(color: Color(0xFF064232).withOpacity(0.6), width: 1.5),
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),

            dotsContainerDecorator: const BoxDecoration(
              color: Colors.transparent,
            ),
          ),

          if (currentPageIndex < 2)
            Positioned(
              top: 50,
              right: 20,
              child: TextButton(
                onPressed: () => _onIntroEnd(context),
                child: const Text(
                  "Skip",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),

          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (currentPageIndex > 0)
                  ElevatedButton(
                    onPressed: () => introKey.currentState?.previous(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: secondaryColor,
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 14,
                      ),
                    ),
                    child: const Text("Back"),
                  ),
                if (currentPageIndex > 0) const SizedBox(width: 16),

                ElevatedButton(
                  onPressed: () {
                    if (currentPageIndex == 2) {
                      _onIntroEnd(context);
                    } else {
                      introKey.currentState?.next();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 14,
                    ),
                  ),
                  child: Text(
                    currentPageIndex == 2 ? "Get Started" : "Next",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
