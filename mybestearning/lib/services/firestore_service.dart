import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../models/user_model.dart';
import '../models/withdrawal_request.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collections
  static const String _usersCollection = 'users';
  static const String _withdrawalRequestsCollection = 'withdrawalRequests';
  static const String _referralCodesCollection = 'referralCodes';

  // Generate random referral code
  String _generateReferralCode(String uid) {
    final random = Random();
    final prefix = uid.substring(0, min(3, uid.length)).toUpperCase();
    final suffix = (random.nextInt(9000) + 1000).toString();
    return '$prefix$suffix';
  }

  // Create new user document
  Future<UserModel> createUser({
    required String uid,
    required String name,
    required String email,
  }) async {
    try {
      final referralCode = _generateReferralCode(uid);
      
      final userModel = UserModel(
        uid: uid,
        name: name,
        email: email,
        points: 0,
        totalEarnings: 0.0,
        todayEarning: 0.0,
        myReferralCode: referralCode,
        upiId: '',
        spinsToday: 0,
      );

      // Save user to Firestore
      await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .set(userModel.toMap());

      // Save referral code to referralCodes collection
      await _firestore
          .collection(_referralCodesCollection)
          .doc(referralCode)
          .set({'uid': uid});

      return userModel;
    } catch (e) {
      debugPrint('Error creating user: $e');
      rethrow;
    }
  }

  // Get user by UID
  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .get();

      if (doc.exists) {
        return UserModel.fromSnapshot(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user: $e');
      return null;
    }
  }

  // Update user data
  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(user.uid)
          .update(user.toMap());
    } catch (e) {
      debugPrint('Error updating user: $e');
      rethrow;
    }
  }

  // Handle daily login bonus
  Future<int> handleDailyLoginBonus(String uid) async {
    try {
      final userDoc = await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .get();

      if (!userDoc.exists) return 0;

      final user = UserModel.fromSnapshot(userDoc);
      
      if (!user.needsDailyBonus) return 0;

      // Generate random bonus between ₹1-₹3 (1000-3000 points)
      final random = Random();
      final bonusPoints = (random.nextInt(3) + 1) * 1000; // 1000, 2000, or 3000

      // Update user with bonus and new login date
      final updatedUser = user.copyWith(
        points: user.points + bonusPoints,
        totalEarnings: user.totalEarnings + (bonusPoints / 1000.0),
        todayEarning: bonusPoints / 1000.0,
        lastLoginDate: DateTime.now(),
      );

      await updateUser(updatedUser);
      return bonusPoints;
    } catch (e) {
      debugPrint('Error handling daily bonus: $e');
      return 0;
    }
  }

  // Handle spin and reward
  Future<int> handleSpin(String uid) async {
    try {
      final userDoc = await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .get();

      if (!userDoc.exists) throw Exception('User not found');

      final user = UserModel.fromSnapshot(userDoc);
      
      if (!user.canSpinToday) throw Exception('Daily spin limit reached');

      // Generate random reward (10, 25, 50, 100 points)
      final rewards = [10, 25, 50, 100];
      final random = Random();
      final rewardPoints = rewards[random.nextInt(rewards.length)];

      final today = DateTime.now();
      final isNewDay = user.lastSpinDate == null ||
          today.day != user.lastSpinDate!.day ||
          today.month != user.lastSpinDate!.month ||
          today.year != user.lastSpinDate!.year;

      // Update user with reward and spin count
      final updatedUser = user.copyWith(
        points: user.points + rewardPoints,
        totalEarnings: user.totalEarnings + (rewardPoints / 1000.0),
        todayEarning: user.todayEarning + (rewardPoints / 1000.0),
        spinsToday: isNewDay ? 1 : user.spinsToday + 1,
        lastSpinDate: DateTime.now(),
      );

      await updateUser(updatedUser);
      return rewardPoints;
    } catch (e) {
      debugPrint('Error handling spin: $e');
      rethrow;
    }
  }

  // Handle referral code usage
  Future<bool> useReferralCode(String uid, String referralCode) async {
    try {
      // Check if referral code exists
      final referralDoc = await _firestore
          .collection(_referralCodesCollection)
          .doc(referralCode)
          .get();

      if (!referralDoc.exists) return false;

      final referrerUid = referralDoc.data()!['uid'] as String;
      
      // Can't refer yourself
      if (referrerUid == uid) return false;

      // Get current user
      final userDoc = await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .get();

      if (!userDoc.exists) return false;

      final user = UserModel.fromSnapshot(userDoc);
      
      // User already used a referral code
      if (user.referredBy != null) return false;

      // Get referrer
      final referrerDoc = await _firestore
          .collection(_usersCollection)
          .doc(referrerUid)
          .get();

      if (!referrerDoc.exists) return false;

      final referrer = UserModel.fromSnapshot(referrerDoc);

      // Update both users with ₹2 bonus (2000 points each)
      await _firestore.runTransaction((transaction) async {
        // Update user who used the code
        final updatedUser = user.copyWith(
          referredBy: referrerUid,
          points: user.points + 2000,
          totalEarnings: user.totalEarnings + 2.0,
          todayEarning: user.todayEarning + 2.0,
        );

        // Update referrer
        final updatedReferrer = referrer.copyWith(
          points: referrer.points + 2000,
          totalEarnings: referrer.totalEarnings + 2.0,
          todayEarning: referrer.todayEarning + 2.0,
        );

        transaction.update(
          _firestore.collection(_usersCollection).doc(uid),
          updatedUser.toMap(),
        );

        transaction.update(
          _firestore.collection(_usersCollection).doc(referrerUid),
          updatedReferrer.toMap(),
        );
      });

      return true;
    } catch (e) {
      debugPrint('Error using referral code: $e');
      return false;
    }
  }

  // Create withdrawal request
  Future<String> createWithdrawalRequest({
    required String uid,
    required String upiId,
    required double amount,
  }) async {
    try {
      final request = WithdrawalRequest(
        id: '',
        uid: uid,
        upiId: upiId,
        amount: amount,
        status: 'pending',
        requestDate: DateTime.now(),
      );

      final docRef = await _firestore
          .collection(_withdrawalRequestsCollection)
          .add(request.toMap());

      return docRef.id;
    } catch (e) {
      debugPrint('Error creating withdrawal request: $e');
      rethrow;
    }
  }

  // Get user's withdrawal requests
  Future<List<WithdrawalRequest>> getUserWithdrawals(String uid) async {
    try {
      final querySnapshot = await _firestore
          .collection(_withdrawalRequestsCollection)
          .where('uid', isEqualTo: uid)
          .orderBy('requestDate', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => WithdrawalRequest.fromSnapshot(doc))
          .toList();
    } catch (e) {
      debugPrint('Error getting withdrawals: $e');
      return [];
    }
  }

  // Stream user data
  Stream<UserModel?> userStream(String uid) {
    return _firestore
        .collection(_usersCollection)
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromSnapshot(doc) : null);
  }
}
