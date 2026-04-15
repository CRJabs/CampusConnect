import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import '../utils/activity_logger.dart';

import 'tabs/home_tab.dart'; // --- NEW IMPORT ---
import 'tabs/accounts_tab.dart';
import 'tabs/directory_tab.dart';
import 'tabs/highlights_tab.dart';
import 'tabs/faq_tab.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (mounted) setState(() {});
  }

  void _logout(BuildContext context) async {
    await ActivityLogger.log('Admin logged out', source: 'Authentication');
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final bool isHome = _tabController.index == 0;

    return Scaffold(
      backgroundColor: const Color(0xFF002147),
      appBar: AppBar(
        toolbarHeight: 90,
        backgroundColor: const Color(0xFF002147),
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 20),
            SizedBox(
              width: 220,
              child: isHome
                  ? const SizedBox.shrink()
                  : Align(
                      alignment: Alignment.centerLeft,
                      child: Image.asset(
                        'assets/logo.png',
                        height: 38,
                        errorBuilder: (context, error, stackTrace) =>
                            const Text('CampusConnect Admin',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                      ),
                    ),
            ),
            Expanded(
              child: Center(
                child: IntrinsicWidth(
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      tabAlignment: TabAlignment.center,
                      padding: EdgeInsets.zero,
                      dividerColor: Colors.transparent,
                      indicator: BoxDecoration(
                          color: const Color(0xFF002147),
                          borderRadius: BorderRadius.circular(25)),
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.black87,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 18),
                      indicatorSize: TabBarIndicatorSize.tab,
                      tabs: const [
                        Tab(
                            child: Row(children: [
                          Icon(Icons.home, size: 16),
                          SizedBox(width: 8),
                          Text('Home',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.bold))
                        ])),
                        Tab(
                            child: Row(children: [
                          Icon(Icons.people_alt, size: 16),
                          SizedBox(width: 8),
                          Text('Accounts',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.bold))
                        ])),
                        Tab(
                            child: Row(children: [
                          Icon(Icons.account_balance, size: 16),
                          SizedBox(width: 8),
                          Text('Directory',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.bold))
                        ])),
                        Tab(
                            child: Row(children: [
                          Icon(Icons.star, size: 16),
                          SizedBox(width: 8),
                          Text('Highlights',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.bold))
                        ])),
                        Tab(
                            child: Row(children: [
                          Icon(Icons.help_outline, size: 16),
                          SizedBox(width: 8),
                          Text('FAQ',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.bold))
                        ])),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 220,
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                    style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20)),
                    onPressed: () => _logout(context),
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout',
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ),
            ),
            const SizedBox(width: 20),
          ],
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/bgImage.jpg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: const Color(0xFF0A2D57),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF00234B).withOpacity(0.85),
                  Color(0xD90D7EFF),
                ],
              ),
            ),
          ),
          if (isHome)
            TabBarView(
              controller: _tabController,
              children: const [
                HomeTab(),
                AccountsTab(),
                DirectoryTab(),
                HighlightsTab(),
                FaqTab(),
              ],
            )
          else
            Center(
              child: Container(
                width: 1600,
                margin:
                    const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 10),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: TabBarView(
                  controller: _tabController,
                  children: const [
                    HomeTab(),
                    AccountsTab(),
                    DirectoryTab(),
                    HighlightsTab(),
                    FaqTab(),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
