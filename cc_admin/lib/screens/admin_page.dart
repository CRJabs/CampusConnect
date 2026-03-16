import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';

import 'tabs/accounts_tab.dart';
import 'tabs/directory_tab.dart';
import 'tabs/highlights_tab.dart';
import 'tabs/faq_tab.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F2F5),
        appBar: AppBar(
          toolbarHeight: 100,
          backgroundColor: const Color(0xFF002147),
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              const SizedBox(width: 20),
              Image.asset('../assets/logo.png',
                  height: 40,
                  errorBuilder: (context, error, stackTrace) => const Text(
                      'CampusConnect Admin',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold))),
            ],
          ),
          actions: [
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                margin: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20)),
                child: const Row(children: [
                  Icon(Icons.admin_panel_settings,
                      size: 16, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Super Admin',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold))
                ]),
              ),
            ),
            Center(
              child: Container(
                height: 50,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30)),
                child: TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  padding: EdgeInsets.zero,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                      color: const Color(0xFF002147),
                      borderRadius: BorderRadius.circular(25)),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black87,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 20),
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabs: const [
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
            const SizedBox(width: 30),
            TextButton.icon(
                style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20)),
                onPressed: () => _logout(context),
                icon: const Icon(Icons.logout),
                label: const Text('Logout',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            const SizedBox(width: 20),
          ],
        ),
        body: Center(
          child: Container(
            width: 1600,
            margin: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 10)
                ]),
            child: const TabBarView(
              children: [
                AccountsTab(),
                DirectoryTab(),
                HighlightsTab(),
                FaqTab(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
