import 'package:flutter/material.dart';
import '../screens/dashboard_screen.dart';
import '../screens/navigation_screen.dart';
import '../screens/faq_screen.dart';
import '../screens/login_screen.dart';

class CampusLayout extends StatefulWidget {
  const CampusLayout({super.key});

  @override
  State<CampusLayout> createState() => _CampusLayoutState();
}

class _CampusLayoutState extends State<CampusLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const NavigationScreen(),
    const FAQScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: _buildTopNav(),
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: _buildFooter(),
    );
  }

  Widget _buildTopNav() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Replace the old Row with this:
          Image.asset(
            'assets/logo.png', // You will put your actual PNG here later
            height: 50,
            errorBuilder: (context, error, stackTrace) {
              // This grey box will show up until you add the actual 'logo.png' to your assets folder
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
                    style: TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.bold)),
              );
            },
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F2F5),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                _navButton(0, 'Dashboard', Icons.dashboard),
                _navButton(1, 'Navigation', Icons.near_me),
                _navButton(2, 'FAQ', Icons.help_outline),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _navButton(int index, String title, IconData icon) {
    final isActive = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF002147) : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 18, color: isActive ? Colors.white : Colors.black87),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.black87,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      color: const Color(0xFF002147),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
      child: GestureDetector(
        // SECRET ADMIN ENTRY: Double tap the footer text to open login
        onDoubleTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const LoginScreen()));
        },
        child: const Text(
          '© 2026 University of Bohol • CampusConnect\nSCHOLARSHIP • CHARACTER • SERVICE',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ),
    );
  }
}
