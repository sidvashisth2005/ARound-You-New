import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:around_you/theme/theme.dart';
import 'package:around_you/services/firebase_service.dart';
import 'package:around_you/services/auth_service.dart';
import 'package:around_you/extensions/color_extensions.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();
  
  final FirebaseService _firebaseService = FirebaseService();
  final AuthService _authService = AuthService();
  
  bool _isLoginMode = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;
  
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _slideController;
  
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkRememberedUser();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeController.forward();
    _scaleController.forward();
    _slideController.forward();
  }

  Future<void> _checkRememberedUser() async {
    final isLoggedIn = await _authService.isLoggedIn();
    if (isLoggedIn) {
      // Auto-navigate to home if user is remembered
      if (mounted) {
        context.go('/home');
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      if (_isLoginMode) {
        // Login
        final userCredential = await _firebaseService.signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        
        if (userCredential.user != null && _rememberMe) {
          // Save login state for remember me
          await _authService.login(
            userId: userCredential.user!.uid,
            email: userCredential.user!.email ?? '',
            name: userCredential.user!.displayName ?? 'User',
          );
        }
        
        if (mounted) {
          context.go('/home');
        }
      } else {
        // Sign up
        final userCredential = await _firebaseService.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          displayName: _displayNameController.text.trim(),
        );
        
        if (userCredential.user != null && _rememberMe) {
          // Save login state for remember me
          await _authService.login(
            userId: userCredential.user!.uid,
            email: userCredential.user!.email ?? '',
            name: userCredential.user!.displayName ?? _displayNameController.text.trim(),
          );
        }
        
        if (mounted) {
          context.go('/home');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700;
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.elegantGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: 24,
              vertical: isSmallScreen ? 16 : 24,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    // Header Section
                    SizedBox(
                      height: isSmallScreen ? size.height * 0.25 : size.height * 0.3,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Container(
                            padding: EdgeInsets.all(isSmallScreen ? 24 : 32),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // App Logo/Icon
                                Container(
                                  width: isSmallScreen ? 80 : 100,
                                  height: isSmallScreen ? 80 : 100,
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.primaryGradient,
                                    borderRadius: BorderRadius.circular(isSmallScreen ? 40 : 50),
                                    boxShadow: AppTheme.premiumShadows,
                                  ),
                                  child: Icon(
                                    Icons.explore,
                                    size: isSmallScreen ? 40 : 50,
                                    color: Colors.white,
                                  ),
                                ),
                                
                                SizedBox(height: isSmallScreen ? 16 : 24),
                                
                                // App Title
                                Text(
                                  'Around You',
                                  style: GoogleFonts.inter(
                                    fontSize: isSmallScreen ? 28 : 32,
                                    fontWeight: FontWeight.w700,
                                    color: theme.colorScheme.primary,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                
                                SizedBox(height: isSmallScreen ? 6 : 8),
                                
                                // Subtitle
                                Text(
                                  'Discover the world around you',
                                  style: GoogleFonts.inter(
                                    fontSize: isSmallScreen ? 14 : 16,
                                    fontWeight: FontWeight.w500,
                                    color: theme.colorScheme.secondary,
                                    letterSpacing: 0.1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Form Section
                    Expanded(
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Container(
                            padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
                            decoration: AppTheme.elegantCardDecoration,
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Form Title
                                  Text(
                                    _isLoginMode ? 'Welcome Back' : 'Create Account',
                                    style: GoogleFonts.inter(
                                      fontSize: isSmallScreen ? 20 : 24,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  
                                  SizedBox(height: isSmallScreen ? 6 : 8),
                                  
                                  Text(
                                    _isLoginMode 
                                      ? 'Sign in to continue your journey'
                                      : 'Join us and start exploring',
                                    style: GoogleFonts.inter(
                                      fontSize: isSmallScreen ? 12 : 14,
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                    ),
                                  ),
                                  
                                  SizedBox(height: isSmallScreen ? 24 : 32),

                                  // Display Name Field (only for sign up)
                                  if (!_isLoginMode) ...[
                                    TextFormField(
                                      controller: _displayNameController,
                                      decoration: InputDecoration(
                                        labelText: 'Display Name',
                                        hintText: 'Enter your display name',
                                        prefixIcon: const Icon(Icons.person_outline),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return 'Please enter a display name';
                                        }
                                        return null;
                                      },
                                    ),
                                    
                                    SizedBox(height: isSmallScreen ? 16 : 20),
                                  ],

                                  // Email Field
                                  TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      labelText: 'Email',
                                      hintText: 'Enter your email',
                                      prefixIcon: const Icon(Icons.email_outlined),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Please enter your email';
                                      }
                                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                        return 'Please enter a valid email';
                                      }
                                      return null;
                                    },
                                  ),
                                  
                                  SizedBox(height: isSmallScreen ? 16 : 20),

                                  // Password Field
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    decoration: InputDecoration(
                                      labelText: 'Password',
                                      hintText: 'Enter your password',
                                      prefixIcon: const Icon(Icons.lock_outline),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword 
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword = !_obscurePassword;
                                          });
                                        },
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your password';
                                      }
                                      if (value.length < 6) {
                                        return 'Password must be at least 6 characters';
                                      }
                                      return null;
                                    },
                                  ),
                                  
                                  SizedBox(height: isSmallScreen ? 16 : 24),

                                  // Remember Me Checkbox (only for login)
                                  if (_isLoginMode) ...[
                                    Row(
                                      children: [
                                        Checkbox(
                                          value: _rememberMe,
                                          onChanged: (value) {
                                            setState(() {
                                              _rememberMe = value ?? false;
                                            });
                                          },
                                          activeColor: theme.colorScheme.primary,
                                        ),
                                        Expanded(
                                          child: Text(
                                            'Remember me',
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: isSmallScreen ? 16 : 24),
                                  ],

                                  // Submit Button
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null : _submitForm,
                                      style: AppTheme.primaryButtonStyle,
                                      child: _isLoading
                                          ? SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(
                                                  theme.colorScheme.onPrimary,
                                                ),
                                              ),
                                            )
                                          : Text(
                                              _isLoginMode ? 'Sign In' : 'Sign Up',
                                            ),
                                    ),
                                  ),
                                  
                                  SizedBox(height: isSmallScreen ? 20 : 24),

                                  // Toggle Mode
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _isLoginMode 
                                          ? "Don't have an account? "
                                          : 'Already have an account? ',
                                        style: GoogleFonts.inter(
                                          fontSize: isSmallScreen ? 12 : 14,
                                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            _isLoginMode = !_isLoginMode;
                                          });
                                        },
                                        style: TextButton.styleFrom(
                                          foregroundColor: theme.colorScheme.primary,
                                          textStyle: GoogleFonts.inter(
                                            fontWeight: FontWeight.w600,
                                            fontSize: isSmallScreen ? 12 : 14,
                                          ),
                                        ),
                                        child: Text(
                                          _isLoginMode ? 'Sign Up' : 'Sign In',
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  SizedBox(height: isSmallScreen ? 12 : 16),

                                  // Skip to Home (for demo)
                                  Center(
                                    child: TextButton(
                                      onPressed: () => context.go('/home'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: theme.colorScheme.secondary,
                                        textStyle: GoogleFonts.inter(
                                          fontWeight: FontWeight.w500,
                                          fontSize: isSmallScreen ? 12 : 14,
                                        ),
                                      ),
                                      child: const Text('Continue as Guest'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
