import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService {
  static AdMobService? _instance;
  static AdMobService get instance => _instance ??= AdMobService._();

  AdMobService._();

  // Test Ad Units (replace with your actual Ad Unit IDs in production)
  static const String _androidBannerId =
      'ca-app-pub-3940256099942544/6300978111'; // Test
  static const String _iosBannerId =
      'ca-app-pub-3940256099942544/2934735716'; // Test
  static const String _androidInterstitialId =
      'ca-app-pub-3940256099942544/1033173712'; // Test
  static const String _iosInterstitialId =
      'ca-app-pub-3940256099942544/4411468910'; // Test
  static const String _androidRewardedId =
      'ca-app-pub-3940256099942544/5224354917'; // Test
  static const String _iosRewardedId =
      'ca-app-pub-3940256099942544/1712485313'; // Test

  // Get Banner Ad Unit ID based on platform
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return _androidBannerId;
    } else if (Platform.isIOS) {
      return _iosBannerId;
    }
    throw UnsupportedError('Unsupported platform');
  }

  // Get Interstitial Ad Unit ID
  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return _androidInterstitialId;
    } else if (Platform.isIOS) {
      return _iosInterstitialId;
    }
    throw UnsupportedError('Unsupported platform');
  }

  // Get Rewarded Ad Unit ID
  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return _androidRewardedId;
    } else if (Platform.isIOS) {
      return _iosRewardedId;
    }
    throw UnsupportedError('Unsupported platform');
  }

  // Initialize AdMob
  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  // Create Banner Ad
  BannerAd createBannerAd({
    AdSize adSize = AdSize.banner,
    Function()? onAdLoaded,
    Function(Ad, LoadAdError)? onAdFailedToLoad,
  }) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          print('Banner ad loaded.');
          onAdLoaded?.call();
        },
        onAdFailedToLoad: (ad, error) {
          print('Banner ad failed to load: $error');
          ad.dispose();
          onAdFailedToLoad?.call(ad, error);
        },
      ),
    );
  }

  // Load Interstitial Ad
  Future<InterstitialAd?> loadInterstitialAd() async {
    InterstitialAd? interstitialAd;

    await InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          print('Interstitial ad loaded.');
          interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          print('Interstitial ad failed to load: $error');
        },
      ),
    );

    return interstitialAd;
  }

  // Load Rewarded Ad
  Future<RewardedAd?> loadRewardedAd() async {
    RewardedAd? rewardedAd;

    await RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          print('Rewarded ad loaded.');
          rewardedAd = ad;
        },
        onAdFailedToLoad: (error) {
          print('Rewarded ad failed to load: $error');
        },
      ),
    );

    return rewardedAd;
  }

  // Show Interstitial Ad
  void showInterstitialAd(InterstitialAd ad, {Function()? onAdDismissed}) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        print('Interstitial ad dismissed.');
        ad.dispose();
        onAdDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('Interstitial ad failed to show: $error');
        ad.dispose();
      },
    );

    ad.show();
  }

  // Show Rewarded Ad
  void showRewardedAd(
    RewardedAd ad, {
    Function(int, String)? onUserEarnedReward,
  }) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        print('Rewarded ad dismissed.');
        ad.dispose();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('Rewarded ad failed to show: $error');
        ad.dispose();
      },
    );

    ad.show(
      onUserEarnedReward: (ad, reward) {
        print('User earned reward: ${reward.amount} ${reward.type}');
        onUserEarnedReward?.call(reward.amount.toInt(), reward.type);
      },
    );
  }
}
