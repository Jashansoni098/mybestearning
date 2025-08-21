import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final int points;
  final double totalEarnings;
  final double todayEarning;
  final String? referredBy;
  final String myReferralCode;
  final String upiId;
  final DateTime? lastLoginDate;
  final int spinsToday;
  final DateTime? lastSpinDate;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.points,
    required this.totalEarnings,
    required this.todayEarning,
    this.referredBy,
    required this.myReferralCode,
    required this.upiId,
    this.lastLoginDate,
    required this.spinsToday,
    this.lastSpinDate,
  });

  // Convert UserModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'points': points,
      'totalEarnings': totalEarnings,
      'todayEarning': todayEarning,
      'referredBy': referredBy,
      'myReferralCode': myReferralCode,
      'upiId': upiId,
      'lastLoginDate': lastLoginDate?.toIso8601String(),
      'spinsToday': spinsToday,
      'lastSpinDate': lastSpinDate?.toIso8601String(),
    };
  }

  // Create UserModel from Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      points: map['points'] ?? 0,
      totalEarnings: (map['totalEarnings'] ?? 0).toDouble(),
      todayEarning: (map['todayEarning'] ?? 0).toDouble(),
      referredBy: map['referredBy'],
      myReferralCode: map['myReferralCode'] ?? '',
      upiId: map['upiId'] ?? '',
      lastLoginDate: map['lastLoginDate'] != null 
          ? DateTime.parse(map['lastLoginDate'])
          : null,
      spinsToday: map['spinsToday'] ?? 0,
      lastSpinDate: map['lastSpinDate'] != null
          ? DateTime.parse(map['lastSpinDate'])
          : null,
    );
  }

  // Create UserModel from Firestore DocumentSnapshot
  factory UserModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return UserModel.fromMap(data);
  }

  // Copy with method for updating user data
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    int? points,
    double? totalEarnings,
    double? todayEarning,
    String? referredBy,
    String? myReferralCode,
    String? upiId,
    DateTime? lastLoginDate,
    int? spinsToday,
    DateTime? lastSpinDate,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      points: points ?? this.points,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      todayEarning: todayEarning ?? this.todayEarning,
      referredBy: referredBy ?? this.referredBy,
      myReferralCode: myReferralCode ?? this.myReferralCode,
      upiId: upiId ?? this.upiId,
      lastLoginDate: lastLoginDate ?? this.lastLoginDate,
      spinsToday: spinsToday ?? this.spinsToday,
      lastSpinDate: lastSpinDate ?? this.lastSpinDate,
    );
  }

  // Get earnings in rupees (1000 points = ₹1)
  double get earningsInRupees => points / 1000.0;
  
  // Check if today's spins are available
  bool get canSpinToday {
    if (lastSpinDate == null) return true;
    
    final today = DateTime.now();
    final lastSpin = lastSpinDate!;
    
    // Reset if it's a new day
    if (today.day != lastSpin.day || 
        today.month != lastSpin.month || 
        today.year != lastSpin.year) {
      return true;
    }
    
    return spinsToday < 5;
  }
  
  // Check if user needs daily bonus
  bool get needsDailyBonus {
    if (lastLoginDate == null) return true;
    
    final today = DateTime.now();
    final lastLogin = lastLoginDate!;
    
    // Give bonus if it's a new day
    return today.day != lastLogin.day || 
           today.month != lastLogin.month || 
           today.year != lastLogin.year;
  }
}
