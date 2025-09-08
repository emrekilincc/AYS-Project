import 'package:flutter/material.dart';
import 'package:animations/animations.dart'; // animasyon için
import 'dashboard_home.dart';
import 'atik_list_page.dart';
import 'rapor_page.dart';
import 'profile_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardHome(), // Ana ekran (istatistikler, chartlar)
    const AtikListPage(),
    RaporPage(),   // ✅ const kaldırıldı
    ProfilPage(),  // ✅ const kaldırıldı
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageTransitionSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (child, animation, secondaryAnimation) =>
            FadeThroughTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              child: child,
            ),
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF2E7D32),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Atıklar"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Raporlar"),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: "Profil"),
        ],
      ),
    );
  }
}
