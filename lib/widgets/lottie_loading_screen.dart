import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:around_you/theme/theme.dart';

class LottieLoadingScreen extends StatefulWidget {
  final String? message;
  final String? lottieAsset;
  final bool showProgress;
  final double progress;

  const LottieLoadingScreen({
    super.key,
    this.message,
    this.lottieAsset,
    this.showProgress = false,
    this.progress = 0.0,
  });

  @override
  State<LottieLoadingScreen> createState() => _LottieLoadingScreenState();
}

class _LottieLoadingScreenState extends State<LottieLoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _fadeController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo/Icon with pulse animation
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppTheme.pureWhite.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: AppTheme.accentGold.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.view_in_ar,
                          color: AppTheme.accentGold,
                          size: 60,
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 40),
                
                // Lottie Animation
                if (widget.lottieAsset != null)
                  Container(
                    width: 200,
                    height: 200,
                    child: Lottie.asset(
                      widget.lottieAsset!,
                      fit: BoxFit.contain,
                      repeat: true,
                    ),
                  ),
                
                const SizedBox(height: 40),
                
                // Loading Message
                if (widget.message != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      widget.message!,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppTheme.pureWhite,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                
                const SizedBox(height: 20),
                
                // Progress Bar
                if (widget.showProgress)
                  Container(
                    width: 200,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.pureWhite.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: widget.progress.clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.accentGold, AppTheme.premiumBlue],
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                
                const SizedBox(height: 20),
                
                // Loading Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    return AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        final delay = index * 0.2;
                        final animationValue = (_pulseController.value + delay) % 1.0;
                        final scale = 0.5 + (0.5 * animationValue);
                        
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppTheme.accentGold,
                            shape: BoxShape.circle,
                          ),
                          child: Transform.scale(scale: scale),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Specific loading screens for different purposes
class AppLaunchLoadingScreen extends StatelessWidget {
  const AppLaunchLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LottieLoadingScreen(
      message: 'Welcome to Around You',
      lottieAsset: 'Animation while launching.json',
      showProgress: false,
    );
  }
}

class MemoryCreationLoadingScreen extends StatelessWidget {
  final double progress;
  
  const MemoryCreationLoadingScreen({
    super.key,
    this.progress = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return LottieLoadingScreen(
      message: 'Creating Your Memory',
      lottieAsset: 'Animation after creating memory.json',
      showProgress: true,
      progress: progress,
    );
  }
}

class IntermediateLoadingScreen extends StatelessWidget {
  final String message;
  
  const IntermediateLoadingScreen({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return LottieLoadingScreen(
      message: message,
      lottieAsset: 'Intermidiate Loading.json',
      showProgress: false,
    );
  }
}