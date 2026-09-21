import 'package:flutter/material.dart';
import 'package:rent_car/core/app_color.dart';
import 'package:rent_car/main.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  bool _startAnimation = false;

  @override
  void initState() {
    super.initState();
    // App khulne ke 50ms baad animations trigger ho jayengi
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) {
          setState(() {
            _startAnimation = true;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size(:height, :width) = MediaQuery.sizeOf(context);

    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/car_bg.jpg'),
            fit: BoxFit.fill,
          ),
        ),
        child: Stack(
          children: [
            // 1. Logo: Upar se Niche aayega (Duration barha di ha)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 1400),
              curve: Curves
                  .easeInOutCubic, // Shuru aur aakhir mein zyada smooth lagay ga
              top: _startAnimation ? height * 0.05 : -100,
              left: (width - 80) / 2,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 1100),
                opacity: _startAnimation ? 1.0 : 0.0,
                child: Image.asset(
                  'assets/images/flogo.png',
                  height: 80,
                  width: 80,
                ),
              ),
            ),

            // 1.5 Car Image: Image size scaled up and positioned for a larger half-cut look
            AnimatedPositioned(
              duration: const Duration(milliseconds: 1600),
              curve: Curves.easeOutCubic,
              top:
                  height *
                  0.15, // Thoda sa upar adjust kiya taake bari image perfect fit ho
              // Animation end par width * 0.150 tak aayegi taake bari gari ka half screen se bahar rahe
              left: _startAnimation ? width * 0.15 : width,
              width:
                  width *
                  1.5, // Image ka size width * 0.9 se barha kar 1.5 kar diya ha
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 1200),
                opacity: _startAnimation ? 1.0 : 0.0,
                child: Image.asset(
                  'assets/images/ffcar.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // 2. Main Title Text: Right se Left aayega
            AnimatedPositioned(
              duration: const Duration(milliseconds: 1400),
              curve: Curves.easeInOutCubic,
              top: height * 0.8,
              left: _startAnimation ? width * 0.05 : width,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 1100),
                opacity: _startAnimation ? 1.0 : 0.0,
                child: RichText(
                  text: const TextSpan(
                    text: 'Rent A',
                    style: TextStyle(
                      color: AppColor.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 33,
                      wordSpacing: 5,
                    ),
                    children: [
                      TextSpan(
                        text: ' Ferrari\n',
                        style: TextStyle(
                          color: AppColor.yellow,
                          fontWeight: FontWeight.bold,
                          fontSize: 33,
                        ),
                      ),
                      TextSpan(
                        text: 'Luxury Car',
                        style: TextStyle(
                          color: AppColor.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 32,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 3. Bottom Row (Description + Arrow Button): Left se Right aayega
            AnimatedPositioned(
              duration: const Duration(milliseconds: 1400),
              curve: Curves.easeInOutCubic,
              top: height * 0.91,
              left: _startAnimation ? 0 : -width,
              width: width,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 1100),
                opacity: _startAnimation ? 1.0 : 0.0,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Find And Experience The Emotion Of Our \nLuxury Cars At A Low Price.',
                        style: TextStyle(color: AppColor.white, fontSize: 12),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const MainWrapper(),
                            ),
                          );
                        },
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: const BoxDecoration(
                            color: AppColor.yellow,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            color: AppColor.black,
                            size: 25,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
