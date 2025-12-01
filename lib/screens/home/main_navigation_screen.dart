import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/user.dart';
import '../../utils/app_colors.dart';
import '../../utils/responsive.dart';
import '../../services/notification_service.dart';
import '../notifications_screen.dart';
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
  Key _profileScreenKey = UniqueKey();
  final NotificationService _notificationService = NotificationService();

  void _changeTab(int index) {
    setState(() {
      // Regenerate home screen key when switching back to home from profile
      if (index == 0 && _currentIndex == 4) {
        _homeScreenKey = UniqueKey();
      }
      // Regenerate profile screen key when switching to profile to reload data
      if (index == 4) {
        _profileScreenKey = UniqueKey();
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
      ProfileScreen(key: _profileScreenKey),
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
              borderRadius: BorderRadius.circular(
                Responsive.responsiveBorderRadius(context),
              ),
            ),
            contentPadding: Responsive.responsiveCardPadding(context),
            title: Row(
              children: [
                Icon(
                  Icons.exit_to_app,
                  color: AppColors.bloodRed,
                  size: Responsive.responsiveIconSize(context) + 4,
                ),
                SizedBox(width: Responsive.responsiveSpacing(context) * 0.5),
                Flexible(
                  child: Text(
                    'অ্যাপ থেকে বের হবেন?',
                    style: TextStyle(
                      fontSize: Responsive.responsiveTextSize(
                        context,
                        mobile: 18.0,
                        tablet: 20.0,
                        desktop: 22.0,
                      ),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            content: Text(
              'আপনি কি নিশ্চিত যে আপনি Blood Donation App থেকে বের হতে চান?',
              style: TextStyle(
                fontSize: Responsive.responsiveTextSize(context),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.responsiveSpacing(context),
                    vertical: Responsive.responsiveSpacing(context) * 0.6,
                  ),
                ),
                child: Text(
                  'না, থাকবো',
                  style: TextStyle(
                    fontSize: Responsive.responsiveTextSize(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.bloodRed,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.responsiveSpacing(context),
                    vertical: Responsive.responsiveSpacing(context) * 0.6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      Responsive.responsiveBorderRadius(context) * 0.5,
                    ),
                  ),
                ),
                child: Text(
                  'হ্যাঁ, বের হব',
                  style: TextStyle(
                    fontSize: Responsive.responsiveTextSize(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );

        if (shouldExit == true && context.mounted) {
          // Exit the app
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _currentIndex == 0
            ? AppBar(
                title: Text(
                  'Blood Donation',
                  style: TextStyle(
                    fontSize: Responsive.responsiveTextSize(
                      context,
                      mobile: 18.0,
                      tablet: 20.0,
                      desktop: 22.0,
                    ),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
                automaticallyImplyLeading: false,
                toolbarHeight: Responsive.responsiveAppBarHeight(context),
                actions: [
                  StreamBuilder<int>(
                    stream: _notificationService.getUnreadNotificationCount(),
                    builder: (context, snapshot) {
                      final unreadCount = snapshot.data ?? 0;
                      return Stack(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.notifications_outlined,
                              size: Responsive.responsiveIconSize(context),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const NotificationsScreen(),
                                ),
                              );
                            },
                            tooltip: 'Notifications',
                          ),
                          if (unreadCount > 0)
                            Positioned(
                              right: Responsive.isMobile(context) ? 8 : 10,
                              top: Responsive.isMobile(context) ? 8 : 10,
                              child: Container(
                                padding: EdgeInsets.all(
                                  Responsive.isMobile(context) ? 4 : 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1,
                                  ),
                                ),
                                constraints: BoxConstraints(
                                  minWidth: Responsive.isMobile(context)
                                      ? 18
                                      : 20,
                                  minHeight: Responsive.isMobile(context)
                                      ? 18
                                      : 20,
                                ),
                                child: Text(
                                  unreadCount > 99
                                      ? '99+'
                                      : unreadCount.toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: Responsive.isMobile(context)
                                        ? 10
                                        : 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  SizedBox(width: Responsive.responsiveSpacing(context) * 0.5),
                ],
              )
            : null,
        body: IndexedStack(index: _currentIndex, children: _getScreens()),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          selectedItemColor: AppColors.bloodRed,
          unselectedItemColor: Colors.grey[600],
          iconSize: Responsive.responsiveIconSize(context),
          selectedFontSize: Responsive.responsiveTextSize(
            context,
            mobile: 12.0,
            tablet: 13.0,
            desktop: 14.0,
          ),
          unselectedFontSize: Responsive.responsiveTextSize(
            context,
            mobile: 10.0,
            tablet: 11.0,
            desktop: 12.0,
          ),
          elevation: Responsive.responsiveElevation(context),
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
                icon: Icon(
                  Icons.bloodtype,
                  size: Responsive.responsiveIconSize(context),
                ),
                label: Text(
                  'Request Blood',
                  style: TextStyle(
                    fontSize: Responsive.responsiveTextSize(
                      context,
                      mobile: 12.0,
                      tablet: 14.0,
                      desktop: 16.0,
                    ),
                  ),
                ),
                backgroundColor: AppColors.bloodRed,
                foregroundColor: Colors.white,
                elevation: Responsive.responsiveElevation(context),
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}
