// lib/screens/main_screen.dart

import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'main_tabs/realm_gate_screen.dart';

import 'main_tabs/glory_board_screen.dart';
import 'main_tabs/power_stats_screen.dart';
import '../utils/sound_manager.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'profile_features/gaming_profile_screen.dart'; // <-- ADD THIS IMPORT

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const HomeScreen(),
    const RealmGateScreen(),
    const GamingProfileScreen(),
    const GloryBoardScreen(),
    const PowerStatsScreen(),
  ];

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      SoundManager.playClickSound();
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Widget _buildIcon(String assetPath, double size) {
    return Image.asset(
      assetPath,
      width: size,
      height: size,
      errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
        print("Error loading asset: $assetPath");
        print(error);
        return Icon(Icons.error_outline, color: Colors.red, size: size);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const double iconSize = 35.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Level Up Life'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFF1F1F1F),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
              ),
              child: const Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.redAccent[100]),
              title: Text(
                'Logout',
                style: TextStyle(color: Colors.redAccent[100], fontSize: 16),
              ),
              onTap: () async {
                Navigator.of(context).pop();
                SoundManager.playClickSound();
                bool? confirmLogout = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext ctx) => AlertDialog(
                    title: const Text('Confirm Logout'),
                    content: const Text('Are you sure you want to log out?'),
                    backgroundColor: const Color(0xFF2a2a2a),
                    titleTextStyle: const TextStyle(color: Colors.white, fontSize: 18),
                    contentTextStyle: const TextStyle(color: Colors.white70),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                        onPressed: () {
                          Navigator.of(ctx).pop(false);
                        },
                      ),
                      TextButton(
                        child: Text('Logout', style: TextStyle(color: Colors.redAccent[100])),
                        onPressed: () {
                          Navigator.of(ctx).pop(true);
                        },
                      ),
                    ],
                  ),
                );

                if (confirmLogout == true) {
                  print("Logging out user...");
                  await Provider.of<AuthProvider>(context, listen: false).signOut();
                  print("Sign out process initiated.");
                } else {
                  print("Logout cancelled by user.");
                }
              },
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: _buildIcon('assets/icons/home.png', iconSize),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon('assets/icons/Realm.png', iconSize),
            label: 'Realm Gate',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon('assets/icons/profile.png', iconSize),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon('assets/icons/achievement.png', iconSize),
            label: 'Glory Board',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon('assets/icons/power.png', iconSize),
            label: 'Power Stats',
          ),
        ],
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey[600],
        selectedFontSize: 12,
        unselectedFontSize: 12,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
      ),
    );
  }
}
