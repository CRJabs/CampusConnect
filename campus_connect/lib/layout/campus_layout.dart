import 'dart:async';
import 'package:flutter/material.dart';
import '../screens/dashboard_screen.dart';
import '../screens/navigation_screen.dart';
import '../screens/faq_screen.dart';

class CampusLayout extends StatefulWidget {
  const CampusLayout({super.key});

  @override
  State<CampusLayout> createState() => _CampusLayoutState();
}

class _CampusLayoutState extends State<CampusLayout> {
  int _currentIndex = 0;

  Timer? _inactivityTimer;
  final int _timeoutSeconds = 60;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const NavigationScreen(),
    const FAQScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _startInactivityTimer();
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    super.dispose();
  }

  void _startInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer =
        Timer(Duration(seconds: _timeoutSeconds), _handleInactivity);
  }

  void _resetInactivityTimer() {
    _startInactivityTimer();
  }

  void _handleInactivity() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }

    if (_currentIndex != 0) {
      setState(() {
        _currentIndex = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isDesktop = screenWidth > 1200;

    double appBarHeight = isDesktop ? 100 : 70;

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _resetInactivityTimer(),
      onPointerMove: (_) => _resetInactivityTimer(),
      onPointerUp: (_) => _resetInactivityTimer(),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(appBarHeight),
          child: _buildTopNav(isDesktop),
        ),
        // --- FIX: Moved from bottomNavigationBar into a Column body ---
        // This stops the Scaffold from cutting off the overflowing images!
        body: Column(
          children: [
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: _screens,
              ),
            ),
            _buildFooter(isDesktop),
          ],
        ),
      ),
    );
  }

  Widget _buildTopNav(bool isDesktop) {
    Widget logoWidget = Image.asset(
      'assets/logo.png',
      height: 50,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 50,
          width: 250,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade400),
          ),
          alignment: Alignment.center,
          child: const Text('Add assets/logo.png',
              style:
                  TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        );
      },
    );

    Widget buttonsWidget = Container(
      padding:
          EdgeInsets.symmetric(horizontal: isDesktop ? 10 : 5, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2F5),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _navButton(0, 'Dashboard', Icons.dashboard, isDesktop),
          _navButton(1, 'Navigation', Icons.near_me, isDesktop),
          _navButton(2, 'FAQ', Icons.help_outline, isDesktop),
        ],
      ),
    );

    return Container(
      color: const Color(0xFF002147),
      padding: EdgeInsets.symmetric(
          vertical: isDesktop ? 20 : 10, horizontal: isDesktop ? 40 : 10),
      child: isDesktop
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [logoWidget, buttonsWidget],
            )
          : Center(child: buttonsWidget),
    );
  }

  Widget _navButton(int index, String title, IconData icon, bool isDesktop) {
    final isActive = _currentIndex == index;
    return InkWell(
      onTap: () {
        _resetInactivityTimer();
        setState(() => _currentIndex = index);
      },
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 20 : 12, vertical: isDesktop ? 10 : 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF002147) : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: isDesktop ? 18 : 16,
                color: isActive ? Colors.white : Colors.black87),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.black87,
                fontSize: isDesktop ? 14 : 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(bool isDesktop) {
    // --- FIX: Stack is now the root widget and allows overflow ---
    return Stack(
      clipBehavior: Clip.none, // CRITICAL: This allows the image to break out
      alignment: Alignment.bottomCenter, // Anchor everything to the bottom edge
      children: [
        // 1. The Blue Background and Text
        Container(
          width: double.infinity,
          color: const Color(0xFF002147),
          padding: EdgeInsets.symmetric(
              vertical: isDesktop ? 35 : 30, horizontal: isDesktop ? 120 : 60),
        ),

        // 2. Bottom Left Image (Overflowing)
        Positioned(
          left: isDesktop ? 40 : 15,
          bottom: 10, // Anchored to the bottom edge of the blue container
          child: Image.asset(
            'assets/footerLeft.png',
            // Increase this height number to make the image poke out even more!
            height: isDesktop ? 50 : 35,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                const SizedBox.shrink(),
          ),
        ),

        // 3. Bottom Right Image (Overflowing)
        Positioned(
          right: isDesktop ? 0 : 0,
          bottom: 0, // Anchored to the bottom edge of the blue container
          child: Image.asset(
            'assets/footerRight.png',
            // Increase this height number to make the image poke out even more!
            height: isDesktop ? 100 : 70,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}
