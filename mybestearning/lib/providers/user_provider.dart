import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';

class UserProvider with ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize user data
  Future<void> initializeUser() async {
    if (!_authService.isSignedIn) return;

    _setLoading(true);
    try {
      final uid = _authService.userId;
      
      // Check if user exists in Firestore
      UserModel? user = await _firestoreService.getUser(uid);
      
      if (user == null) {
        // Create new user
        user = await _firestoreService.createUser(
          uid: uid,
          name: _authService.userDisplayName,
          email: _authService.userEmail,
        );
      }
      
      _user = user;
      _error = null;
      
      // Handle daily login bonus
      await _handleDailyBonus();
      
    } catch (e) {
      _error = e.toString();
      debugPrint('Error initializing user: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Handle daily login bonus
  Future<void> _handleDailyBonus() async {
    if (_user == null) return;
    
    try {
      final bonusPoints = await _firestoreService.handleDailyLoginBonus(_user!.uid);
      if (bonusPoints > 0) {
        // Refresh user data to get updated points
        await refreshUser();
        
        // You might want to show a bonus notification here
        debugPrint('Daily bonus awarded: $bonusPoints points');
      }
    } catch (e) {
      debugPrint('Error handling daily bonus: $e');
    }
  }

  // Refresh user data
  Future<void> refreshUser() async {
    if (!_authService.isSignedIn || _user == null) return;

    try {
      final updatedUser = await _firestoreService.getUser(_user!.uid);
      if (updatedUser != null) {
        _user = updatedUser;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error refreshing user: $e');
    }
  }

  // Update UPI ID
  Future<bool> updateUpiId(String upiId) async {
    if (_user == null) return false;

    try {
      final updatedUser = _user!.copyWith(upiId: upiId);
      await _firestoreService.updateUser(updatedUser);
      _user = updatedUser;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error updating UPI ID: $e');
      return false;
    }
  }

  // Use referral code
  Future<bool> useReferralCode(String referralCode) async {
    if (_user == null) return false;

    _setLoading(true);
    try {
      final success = await _firestoreService.useReferralCode(_user!.uid, referralCode);
      if (success) {
        await refreshUser();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error using referral code: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Handle spin
  Future<int?> spin() async {
    if (_user == null) return null;

    try {
      final rewardPoints = await _firestoreService.handleSpin(_user!.uid);
      await refreshUser(); // Refresh to get updated data
      return rewardPoints;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error spinning: $e');
      return null;
    }
  }

  // Create withdrawal request
  Future<bool> createWithdrawal(String upiId, double amount) async {
    if (_user == null) return false;

    try {
      await _firestoreService.createWithdrawalRequest(
        uid: _user!.uid,
        upiId: upiId,
        amount: amount,
      );
      
      // Deduct points from user balance
      final pointsToDeduct = (amount * 1000).round();
      final updatedUser = _user!.copyWith(
        points: _user!.points - pointsToDeduct,
      );
      
      await _firestoreService.updateUser(updatedUser);
      _user = updatedUser;
      notifyListeners();
      
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error creating withdrawal: $e');
      return false;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Clear user data (for logout)
  void clearUser() {
    _user = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
