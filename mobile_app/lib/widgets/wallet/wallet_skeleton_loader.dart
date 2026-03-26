// lib/widgets/wallet/wallet_skeleton_loader.dart
// Pure Dart shimmer — no external packages
import 'package:flutter/material.dart';
import '../../config/app_constants.dart';

class WalletSkeletonLoader extends StatefulWidget {
  const WalletSkeletonLoader({super.key});

  @override
  State<WalletSkeletonLoader> createState() => _WalletSkeletonLoaderState();
}

class _WalletSkeletonLoaderState extends State<WalletSkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        title: const Text('My Digital Wallet',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: const BackButton(color: Colors.white),
      ),
      body: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                _shimmerBox(width: double.infinity, height: 200, radius: 20),
                const SizedBox(height: AppSpacing.md),
                _shimmerRow(),
                const SizedBox(height: AppSpacing.md),
                _shimmerBox(width: double.infinity, height: 260, radius: 16),
                const SizedBox(height: AppSpacing.md),
                _shimmerBox(width: double.infinity, height: 180, radius: 16),
                const SizedBox(height: AppSpacing.md),
                _shimmerBox(width: double.infinity, height: 150, radius: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _shimmerBox({required double width, required double height, double radius = 8}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: width,
        height: height,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (_, __) => Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(_animation.value - 1, 0),
                end: Alignment(_animation.value, 0),
                colors: const [
                  Color(0xFFE0E0E0),
                  Color(0xFFF5F5F5),
                  Color(0xFFE0E0E0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _shimmerRow() {
    return Row(
      children: [
        _shimmerBox(width: 100, height: 80, radius: 12),
        const SizedBox(width: 8),
        _shimmerBox(width: 100, height: 80, radius: 12),
        const SizedBox(width: 8),
        _shimmerBox(width: 100, height: 80, radius: 12),
      ],
    );
  }
}
