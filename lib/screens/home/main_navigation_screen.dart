import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../utils/app_colors.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'donate_screen.dart';
import 'messages_screen.dart';
import 'profile_screen.dart';
import '../chatbot/chatbot_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  User? currentUser;
  Key _homeScreenKey = UniqueKey();

  void _changeTab(int index) {
    setState(() {
      // Regenerate home screen key when switching back to home from profile
      if (index == 0 && _currentIndex == 4) {
        _homeScreenKey = UniqueKey();
      }
      _currentIndex = index;
    });
  }

  List<Widget> _getScreens() {
    // Rebuild screens each time to get fresh data
    return [
      HomeScreen(
        key: _homeScreenKey,
        user: currentUser,
        onNavigateToTab: _changeTab,
      ),
      SearchScreen(),
      DonateScreen(),
      MessagesScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get the user passed from login/signup only once
    if (currentUser == null) {
      final arguments = ModalRoute.of(context)?.settings.arguments;
      if (arguments is User) {
        currentUser = arguments;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Check if there are any routes to pop in the navigator
        // If yes, allow normal back navigation
        // If no, show exit confirmation
        if (Navigator.of(context).canPop()) {
          return true; // Allow normal back navigation
        }

        // Show exit confirmation dialog only when on main screen
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit App'),
            content: const Text(
              'Are you sure you want to exit the Blood Donation App?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.bloodRed,
                ),
                child: const Text('Exit'),
              ),
            ],
          ),
        );

        return shouldExit ?? false;
      },
      child: Scaffold(
        body: IndexedStack(index: _currentIndex, children: _getScreens()),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          selectedItemColor: AppColors.bloodRed,
          unselectedItemColor: Colors.grey[600],
          onTap: (index) {
            setState(() {
              // Regenerate home screen key when switching back to home from profile
              if (index == 0 && _currentIndex == 4) {
                _homeScreenKey = UniqueKey();
              }
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle),
              label: 'Donate',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.message),
              label: 'Messages',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChatbotScreen()),
            );
          },
          icon: const Icon(Icons.smart_toy),
          label: const Text('AI Assistant'),
          backgroundColor: AppColors.bloodRed,
          foregroundColor: Colors.white,
          elevation: 6,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}
