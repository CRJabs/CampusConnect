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
    bool isDesktop = screenWidth > 800;

    // --- FIX: Reduced app bar height on mobile to remove dead space ---
    double appBarHeight = isDesktop ? 100 : 130;

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
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar:
            _buildFooter(isDesktop), // Pass responsiveness check
      ),
    );
  }

  Widget _buildTopNav(bool isDesktop) {
    Widget logoWidget = Image.asset(
      'assets/logo.png',
      height: isDesktop
          ? 50
          : 40, // --- FIX: Scale down logo slightly on phones ---
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: isDesktop ? 50 : 40,
          width: isDesktop ? 250 : 200,
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
          vertical: isDesktop ? 20 : 15,
          // --- FIX: Drastically reduced horizontal padding on mobile to stop layout breaking ---
          horizontal: isDesktop ? 40 : 10),
      child: isDesktop
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                logoWidget,
                buttonsWidget,
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(child: logoWidget),
                const SizedBox(height: 12), // Tighter spacing
                Center(child: buttonsWidget),
              ],
            ),
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
        // --- FIX: Shrunk the massive 20px padding to 12px on mobile to squeeze buttons together cleanly ---
        padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 20 : 12, vertical: isDesktop ? 10 : 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF002147) : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: isDesktop ? 18 : 16, // Shrink icon on mobile
                color: isActive ? Colors.white : Colors.black87),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.black87,
                fontSize: isDesktop ? 14 : 12, // Shrink text on mobile
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(bool isDesktop) {
    return Container(
      color: const Color(0xFF002147),
      // --- FIX: Thinner footer on mobile ---
      padding: EdgeInsets.symmetric(
          vertical: isDesktop ? 20 : 12, horizontal: isDesktop ? 40 : 10),
      child: Text(
        '© 2026 University of Bohol • CampusConnect\nSCHOLARSHIP • CHARACTER • SERVICE',
        textAlign: TextAlign.center,
        style: TextStyle(
            color: Colors.white70,
            fontSize:
                isDesktop ? 12 : 10 // Shrink text on mobile to prevent wrapping
            ),
      ),
    );
  }
}
