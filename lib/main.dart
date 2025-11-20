import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'config/routes.dart';
import 'firebase_options.dart';
import 'utils/theme_manager.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load environment variables (non-fatal if file missing).
  try {
    await dotenv.load(fileName: ".env");
  } catch (_) {}
  // Attempt to initialize Firebase. Provide clearer logging and a flag
  // so the app can behave differently when Firebase is not configured.
  var firebaseConfigured = false;
  // Primary initialization attempt.
  try {
    if (kIsWeb) {
      if (!DefaultFirebaseOptions.isPlaceholder) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        firebaseConfigured = true;
        debugPrint('Firebase initialized (web) with generated options.');
      } else {
        debugPrint('Skipping web options: firebase_options.dart placeholder.');
      }
    } else {
      await Firebase.initializeApp();
      firebaseConfigured = true;
      debugPrint('Firebase initialized using platform config files.');
    }
  } catch (e) {
    firebaseConfigured = false;
    debugPrint('Initial Firebase init error: $e');
  }

  // Secondary fallback: try generated options only if not a placeholder and previous failed.
  if (!firebaseConfigured && !DefaultFirebaseOptions.isPlaceholder) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      firebaseConfigured = true;
      debugPrint('Firebase initialized using generated options (fallback).');
    } catch (e) {
      debugPrint('Fallback Firebase init failed: $e');
    }
  }

  // Allow running the app in offline/demo mode when Firebase isn't configured.
  // If you want to require Firebase, set `allowOfflineMode` to false.
  const allowOfflineMode = true;
  if (!firebaseConfigured && allowOfflineMode) {
    firebaseConfigured = true; // treat as available for UI flow (offline mode)
    debugPrint('Firebase not configured — running in offline/demo mode.');
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeManager(),
      child: BloodDonationApp(firebaseConfigured: firebaseConfigured),
    ),
  );
}

class BloodDonationApp extends StatelessWidget {
  final bool firebaseConfigured;

  const BloodDonationApp({super.key, this.firebaseConfigured = false});

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Blood Donation',
      theme: themeManager.lightTheme,
      darkTheme: themeManager.darkTheme,
      themeMode: themeManager.themeMode,
      initialRoute: '/',
      routes: appRoutes,
      builder: (context, child) {
        // Show a small non-intrusive banner when Firebase is not configured.
        if (!firebaseConfigured) {
          return Column(
            children: [
              Container(
                width: double.infinity,
                color: Colors.orange[700],
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: SafeArea(
                  bottom: false,
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Firebase not configured — some features (auth, messaging, firestore) will be disabled. See README_FIREBASE.md',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(child: child ?? const SizedBox()),
            ],
          );
        }
        return child ?? const SizedBox();
      },
    );
  }
}
