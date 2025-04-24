import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pockeat/features/authentication/services/login_service.dart';

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({super.key});

  @override
  State<SplashScreenPage> createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage>
    with SingleTickerProviderStateMixin {
  final Color primaryPink = const Color(0xFFFF6B6B);
  final Color primaryGreen = const Color(0xFF4ECDC4);
  final Color bgColor = const Color(0xFFF9F9F9);

  // Satu AnimationController untuk mengelola semua animasi
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<int> _dotIndicator; 

  @override
  void initState() {
    super.initState();

    // Inisialisasi dan setup AnimationController
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    // Scale animation untuk teks
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Animation untuk dot indicator (0, 1, 2)
    _dotIndicator = IntTween(begin: 0, end: 2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.linear,
      ),
    );

    // Mulai animasi setelah widget dibangun
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.repeat();
      
      // Mulai proses navigasi ke halaman berikutnya
      _checkAuthAndNavigate();
    });
  }

  Future<void> _checkAuthAndNavigate() async {
    final loginService = GetIt.instance<LoginService>();

    try {
      // Mulai cek auth bersamaan dengan animasi berjalan
      final userFuture = loginService.getCurrentUser();
      
      // Beri waktu minimal untuk animasi splash
      await Future.delayed(const Duration(seconds: 2));
      
      // Ambil hasil login
      final user = await userFuture;

      if (!mounted) return;

      if (user != null) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      } else {
        Navigator.of(context).pushNamedAndRemoveUntil('/welcome', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/welcome', (route) => false);
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo animasi
              AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: child,
                  );
                },
                child: Text(
                  'Pockeat',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: primaryPink,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // Subtitle
              Text(
                'Your health companion',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 40),
              
              // Dot indicator animation
              AnimatedBuilder(
                animation: _dotIndicator,
                builder: (context, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildDot(_dotIndicator.value == 0),
                      const SizedBox(width: 8),
                      _buildDot(_dotIndicator.value == 1),
                      const SizedBox(width: 8),
                      _buildDot(_dotIndicator.value == 2),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build a single dot for the loading animation
  Widget _buildDot(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: isActive ? 12 : 8,
      width: isActive ? 12 : 8,
      decoration: BoxDecoration(
        color: isActive ? primaryGreen : primaryPink.withOpacity(0.5),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}