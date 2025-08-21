import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../../providers/user_provider.dart';
import '../../providers/ads_provider.dart';
import '../../widgets/spinning_wheel.dart';

class SpinScreen extends StatefulWidget {
  @override
  _SpinScreenState createState() => _SpinScreenState();
}

class _SpinScreenState extends State<SpinScreen>
    with TickerProviderStateMixin {
  late AnimationController _spinController;
  late Animation<double> _spinAnimation;
  bool _isSpinning = false;
  bool _showingReward = false;
  int? _rewardWon;

  final List<int> _rewards = [10, 25, 50, 100];
  final List<Color> _wheelColors = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
    Colors.pink,
  ];

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );
    
    _spinAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _spinController,
      curve: Curves.decelerate,
    ));

    _spinController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isSpinning = false;
        });
        _showRewardDialog();
      }
    });
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  Future<void> _spin() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final adsProvider = Provider.of<AdsProvider>(context, listen: false);

    if (userProvider.user == null) return;

    if (!userProvider.user!.canSpinToday) {
      _showLimitReachedDialog();
      return;
    }

    if (_isSpinning) return;

    setState(() {
      _isSpinning = true;
    });

    // Show rewarded ad first
    if (adsProvider.isRewardedAdLoaded) {
      final adWatched = await adsProvider.showRewardedAd();
      if (!adWatched) {
        setState(() {
          _isSpinning = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please watch the ad to continue spinning'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }

    // Perform the spin
    final reward = await userProvider.spin();
    if (reward != null) {
      _rewardWon = reward;
      
      // Calculate final rotation to land on the reward
      final rewardIndex = _rewards.indexOf(reward);
      final finalRotation = (rewardIndex / _rewards.length) + 
          (Random().nextInt(5) + 5); // Add multiple full rotations
      
      _spinAnimation = Tween<double>(
        begin: 0.0,
        end: finalRotation,
      ).animate(CurvedAnimation(
        parent: _spinController,
        curve: Curves.decelerate,
      ));

      _spinController.reset();
      _spinController.forward();
    } else {
      setState(() {
        _isSpinning = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Spin failed. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showRewardDialog() {
    if (_rewardWon == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.emoji_events,
                size: 50,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Congratulations!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'You won $_rewardWon points!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '₹${(_rewardWon! / 1000.0).toStringAsFixed(3)}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _rewardWon = null;
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Awesome!',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLimitReachedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Daily Limit Reached'),
        content: Text('You have used all your spins for today. Come back tomorrow for more spins!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Spin & Win'),
        centerTitle: true,
        elevation: 0,
        actions: [
          Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              final user = userProvider.user;
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                margin: EdgeInsets.only(right: 16, top: 8, bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.monetization_on, 
                         color: Colors.amber, size: 20),
                    SizedBox(width: 4),
                    Text(
                      '${user?.points ?? 0}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final user = userProvider.user;
          
          return Column(
            children: [
              // Header Stats
              Container(
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.blue.shade600],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard(
                      'Today\'s Spins',
                      '${user?.spinsToday ?? 0}/5',
                      Icons.refresh,
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    _buildStatCard(
                      'Today\'s Earning',
                      '₹${user?.todayEarning.toStringAsFixed(2) ?? "0.00"}',
                      Icons.trending_up,
                    ),
                  ],
                ),
              ),

              // Spinning Wheel
              Expanded(
                flex: 3,
                child: Center(
                  child: Container(
                    width: 280,
                    height: 280,
                    child: AnimatedBuilder(
                      animation: _spinAnimation,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _spinAnimation.value * 2 * pi,
                          child: SpinningWheel(
                            rewards: _rewards,
                            colors: _wheelColors,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // Spin Button
              Expanded(
                flex: 1,
                child: Center(
                  child: Container(
                    width: 200,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _isSpinning || user == null 
                          ? null 
                          : (user.canSpinToday ? _spin : null),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: user?.canSpinToday == true 
                            ? Colors.green 
                            : Colors.grey,
                        disabledBackgroundColor: Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 8,
                      ),
                      child: _isSpinning
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text('Spinning...'),
                              ],
                            )
                          : Text(
                              user?.canSpinToday == true 
                                  ? 'SPIN NOW!' 
                                  : 'NO SPINS LEFT',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
              ),

              // Reward Info
              Container(
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Possible Rewards',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: _rewards.map((reward) => Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$reward pts',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      )).toList(),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
