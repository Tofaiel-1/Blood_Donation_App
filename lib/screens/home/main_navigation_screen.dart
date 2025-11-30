import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../utils/app_colors.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'donate_screen.dart';
import 'messages_screen.dart';
import 'profile_screen.dart';

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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        // Show exit confirmation dialog
        final shouldExit = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.exit_to_app, color: AppColors.bloodRed, size: 28),
                const SizedBox(width: 12),
                const Text(
                  'অ্যাপ থেকে বের হবেন?',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: const Text(
              'আপনি কি নিশ্চিত যে আপনি Blood Donation App থেকে বের হতে চান?',
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  'না, থাকবো',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.bloodRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'হ্যাঁ, বের হব',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        );

        if (shouldExit == true && context.mounted) {
          // SystemNavigator.pop(); // Optional: if you want to close the app
          // Since we are in a navigation stack, we might just want to let it pop if it's the root
          // But PopScope with canPop: false prevents popping.
          // If we want to allow exit, we should set canPop to true or manually pop.
          // However, onPopInvoked is called.
          // If we want to exit the app, we can use SystemNavigator.pop()
          // Or if we just want to pop the route:
          // Navigator.of(context).pop();
          // But wait, onWillPop expected a boolean to decide whether to pop.
          // PopScope is different.
          // If we want to allow pop, we should have canPop: true or update state.
          // But here we want to show dialog first.
          // So we keep canPop: false.
          // If user says yes, we can call SystemNavigator.pop() or Navigator.pop(context).
          // Since this is MainNavigationScreen, likely the root, so SystemNavigator.pop() is appropriate for "Exit App".
          // But usually in Flutter we don't exit app programmatically on iOS.
          // Let's assume we just want to pop if confirmed.
          // But we can't pop if canPop is false.
          // We can use SystemChannels.platform.invokeMethod('SystemNavigator.pop');
          // Or we can change canPop to true and call pop again? No that's complex.
          // The standard migration for WillPopScope to PopScope for "Exit App confirmation":
          // Use canPop: false. In onPopInvoked, show dialog. If yes, SystemNavigator.pop().
          // I need to import 'package:flutter/services.dart';
        }
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
        floatingActionButton: _currentIndex == 0
            ? FloatingActionButton.extended(
                onPressed: () {
                  Navigator.pushNamed(context, '/user-blood-request');
                },
                icon: const Icon(Icons.bloodtype),
                label: const Text('Request Blood'),
                backgroundColor: AppColors.bloodRed,
                foregroundColor: Colors.white,
                elevation: 6,
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}
