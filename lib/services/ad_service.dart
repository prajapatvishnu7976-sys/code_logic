import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';

class AdService {
  // 🔥 PREMIUM TOGGLE
  // Jab user purchase kar lega, isse true kar dena (Firebase ya local storage se)
  static bool isPremiumUser = false;

  // 🔥 REAL AD UNITS
  static String get rewardedAdUnitId =>
      'ca-app-pub-9513338936916425/2153171333';
  static String get interstitialAdUnitId =>
      'ca-app-pub-9513338936916425/3466253003';

  static RewardedAd? _rewardedAd;
  static InterstitialAd? _interstitialAd;

  // Load Rewarded Ad
  static void loadRewardedAd() {
    // 💎 Block loading for premium users
    if (isPremiumUser) return;

    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => _rewardedAd = ad,
        onAdFailedToLoad: (error) => _rewardedAd = null,
      ),
    );
  }

  // Show Rewarded Ad
  static void showRewardedAd(VoidCallback onRewardEarned) {
    // 💎 Direct reward without ad for premium users
    if (isPremiumUser) {
      onRewardEarned();
      return;
    }

    if (_rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          loadRewardedAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          loadRewardedAd();
        },
      );
      _rewardedAd!.show(onUserEarnedReward: (ad, reward) => onRewardEarned());
      _rewardedAd = null;
    } else {
      loadRewardedAd();
      onRewardEarned(); // Backup agar ad load na ho
    }
  }

  // Load Interstitial
  static void loadInterstitialAd() {
    // 💎 Block loading for premium users
    if (isPremiumUser) return;

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (error) => _interstitialAd = null,
      ),
    );
  }

  // Show Interstitial Ad
  static void showInterstitialAd() {
    // 💎 Don't show anything for premium users
    if (isPremiumUser) return;

    if (_interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd = null;
      loadInterstitialAd();
    }
  }
}
