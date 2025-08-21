import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsProvider with ChangeNotifier {
  // Test Ad Unit IDs (replace with real ones in production)
  static const String _bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _rewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';
  static const String _interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';

  BannerAd? _bannerAd;
  RewardedAd? _rewardedAd;
  InterstitialAd? _interstitialAd;

  bool _isBannerAdLoaded = false;
  bool _isRewardedAdLoaded = false;
  bool _isInterstitialAdLoaded = false;

  BannerAd? get bannerAd => _bannerAd;
  RewardedAd? get rewardedAd => _rewardedAd;
  InterstitialAd? get interstitialAd => _interstitialAd;

  bool get isBannerAdLoaded => _isBannerAdLoaded;
  bool get isRewardedAdLoaded => _isRewardedAdLoaded;
  bool get isInterstitialAdLoaded => _isInterstitialAdLoaded;

  // Load banner ad
  void loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('Banner ad loaded');
          _isBannerAdLoaded = true;
          notifyListeners();
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner ad failed to load: $error');
          _isBannerAdLoaded = false;
          ad.dispose();
          _bannerAd = null;
          notifyListeners();
        },
      ),
    );
    _bannerAd!.load();
  }

  // Load rewarded ad
  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('Rewarded ad loaded');
          _rewardedAd = ad;
          _isRewardedAdLoaded = true;
          notifyListeners();

          // Set the full screen content callback
          _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreen: (ad) {
              debugPrint('Rewarded ad dismissed');
              ad.dispose();
              _rewardedAd = null;
              _isRewardedAdLoaded = false;
              notifyListeners();
              // Load a new ad for next time
              loadRewardedAd();
            },
            onAdFailedToShowFullScreen: (ad, error) {
              debugPrint('Rewarded ad failed to show: $error');
              ad.dispose();
              _rewardedAd = null;
              _isRewardedAdLoaded = false;
              notifyListeners();
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('Rewarded ad failed to load: $error');
          _isRewardedAdLoaded = false;
          notifyListeners();
        },
      ),
    );
  }

  // Load interstitial ad
  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('Interstitial ad loaded');
          _interstitialAd = ad;
          _isInterstitialAdLoaded = true;
          notifyListeners();

          // Set the full screen content callback
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreen: (ad) {
              debugPrint('Interstitial ad dismissed');
              ad.dispose();
              _interstitialAd = null;
              _isInterstitialAdLoaded = false;
              notifyListeners();
              // Load a new ad for next time
              loadInterstitialAd();
            },
            onAdFailedToShowFullScreen: (ad, error) {
              debugPrint('Interstitial ad failed to show: $error');
              ad.dispose();
              _interstitialAd = null;
              _isInterstitialAdLoaded = false;
              notifyListeners();
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial ad failed to load: $error');
          _isInterstitialAdLoaded = false;
          notifyListeners();
        },
      ),
    );
  }

  // Show rewarded ad
  Future<bool> showRewardedAd() async {
    if (!_isRewardedAdLoaded || _rewardedAd == null) {
      debugPrint('Rewarded ad is not ready');
      return false;
    }

    bool rewardEarned = false;

    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        debugPrint('User earned reward: ${reward.amount} ${reward.type}');
        rewardEarned = true;
      },
    );

    return rewardEarned;
  }

  // Show interstitial ad
  void showInterstitialAd() {
    if (!_isInterstitialAdLoaded || _interstitialAd == null) {
      debugPrint('Interstitial ad is not ready');
      return;
    }

    _interstitialAd!.show();
  }

  // Dispose banner ad
  void disposeBannerAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isBannerAdLoaded = false;
    notifyListeners();
  }

  // Initialize all ads
  void initializeAds() {
    loadBannerAd();
    loadRewardedAd();
    loadInterstitialAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _rewardedAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }
}
