import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../providers/user_provider.dart';
import '../../providers/ads_provider.dart';
import '../../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _upiController = TextEditingController();
  final _referralCodeController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _upiController.dispose();
    _referralCodeController.dispose();
    super.dispose();
  }

  Future<void> _updateUpiId() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final upiId = _upiController.text.trim();

    if (upiId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a UPI ID'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!upiId.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid UPI ID'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await userProvider.updateUpiId(upiId);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('UPI ID updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update UPI ID'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _useReferralCode() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final referralCode = _referralCodeController.text.trim().toUpperCase();

    if (referralCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a referral code'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await userProvider.useReferralCode(referralCode);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Referral code applied! ₹2 added to your account'),
          backgroundColor: Colors.green,
        ),
      );
      _referralCodeController.clear();
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid referral code or already used'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sign Out'),
        content: Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _authService.signOut();
      Provider.of<UserProvider>(context, listen: false).clearUser();
    }
  }

  void _showUpiDialog(String currentUpi) {
    _upiController.text = currentUpi;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update UPI ID'),
        content: TextField(
          controller: _upiController,
          decoration: InputDecoration(
            labelText: 'UPI ID',
            hintText: 'example@paytm',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: _updateUpiId,
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showReferralDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enter Referral Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _referralCodeController,
              decoration: InputDecoration(
                labelText: 'Referral Code',
                hintText: 'ABC1234',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            SizedBox(height: 12),
            Text(
              'Get ₹2 for both you and your friend!',
              style: TextStyle(
                fontSize: 12,
                color: Colors.green,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: _useReferralCode,
            child: Text('Apply'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Profile'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final user = userProvider.user;
          
          if (user == null) {
            return Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile Header
                Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade400, Colors.blue.shade600],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 15,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.blue.shade600,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        user.name,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        user.email,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      SizedBox(height: 16),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Balance: ₹${user.earningsInRupees.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),

                // UPI Info Card
                _buildInfoCard(
                  'UPI Information',
                  [
                    ListTile(
                      leading: Icon(Icons.account_balance_wallet, color: Colors.blue),
                      title: Text('UPI ID'),
                      subtitle: Text(
                        user.upiId.isEmpty ? 'Not set' : user.upiId,
                        style: TextStyle(
                          color: user.upiId.isEmpty ? Colors.red : Colors.black87,
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _showUpiDialog(user.upiId),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16),

                // Referral Card
                _buildInfoCard(
                  'Referral System',
                  [
                    ListTile(
                      leading: Icon(Icons.share, color: Colors.green),
                      title: Text('My Referral Code'),
                      subtitle: Text(user.myReferralCode),
                      trailing: IconButton(
                        icon: Icon(Icons.copy),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: user.myReferralCode));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Referral code copied!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                      ),
                    ),
                    if (user.referredBy == null)
                      ListTile(
                        leading: Icon(Icons.redeem, color: Colors.orange),
                        title: Text('Enter Referral Code'),
                        subtitle: Text('Get ₹2 bonus'),
                        trailing: Icon(Icons.arrow_forward_ios),
                        onTap: _showReferralDialog,
                      ),
                    if (user.referredBy != null)
                      ListTile(
                        leading: Icon(Icons.check_circle, color: Colors.green),
                        title: Text('Referral Used'),
                        subtitle: Text('You\'ve already used a referral code'),
                      ),
                  ],
                ),

                SizedBox(height: 16),

                // Stats Card
                _buildInfoCard(
                  'Your Statistics',
                  [
                    ListTile(
                      leading: Icon(Icons.trending_up, color: Colors.blue),
                      title: Text('Total Earnings'),
                      trailing: Text(
                        '₹${user.totalEarnings.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.today, color: Colors.orange),
                      title: Text('Today\'s Earning'),
                      trailing: Text(
                        '₹${user.todayEarning.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.casino, color: Colors.purple),
                      title: Text('Today\'s Spins'),
                      trailing: Text(
                        '${user.spinsToday}/5',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.monetization_on, color: Colors.amber),
                      title: Text('Total Points'),
                      trailing: Text(
                        '${user.points}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade700,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20),

                // Banner Ad
                Consumer<AdsProvider>(
                  builder: (context, adsProvider, child) {
                    if (adsProvider.isBannerAdLoaded && 
                        adsProvider.bannerAd != null) {
                      return Container(
                        alignment: Alignment.center,
                        width: adsProvider.bannerAd!.size.width.toDouble(),
                        height: adsProvider.bannerAd!.size.height.toDouble(),
                        child: AdWidget(ad: adsProvider.bannerAd!),
                      );
                    }
                    return SizedBox.shrink();
                  },
                ),

                SizedBox(height: 20),

                // App Info
                _buildInfoCard(
                  'App Information',
                  [
                    ListTile(
                      leading: Icon(Icons.info, color: Colors.blue),
                      title: Text('Version'),
                      trailing: Text('1.0.0'),
                    ),
                    ListTile(
                      leading: Icon(Icons.privacy_tip, color: Colors.green),
                      title: Text('Privacy Policy'),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // TODO: Open privacy policy
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.description, color: Colors.orange),
                      title: Text('Terms of Service'),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // TODO: Open terms of service
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}
