// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:pockeat/component/navigation.dart';
import 'package:pockeat/features/authentication/domain/model/user_model.dart';
import 'package:pockeat/features/authentication/services/bug_report_service.dart';
import 'package:pockeat/features/authentication/services/login_service.dart';
import 'package:pockeat/features/authentication/services/logout_service.dart';
import 'package:pockeat/features/home_screen_widget/presentation/screens/widget_manager_screen.dart';

/// User profile page
///
/// Displays user profile information and options for:
/// - Edit profile
/// - Change password
/// - Report bug (instabug)
/// - Logout
class ProfilePage extends StatefulWidget {
  final FirebaseAuth? firebaseAuth;

  const ProfilePage({super.key, this.firebaseAuth});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Colors - same as login page for consistency
  final Color primaryPink = const Color(0xFFFF6B6B);
  final Color primaryGreen = const Color(0xFF4ECDC4);
  final Color bgColor = const Color(0xFFF9F9F9);

  late final LoginService _loginService;
  late final LogoutService _logoutService;
  late final BugReportService _bugReportService;
  UserModel? _currentUser;
  bool _isLoading = true;
  String? _errorMessage;

  // Getter for FirebaseAuth access
  FirebaseAuth get _auth => widget.firebaseAuth ?? FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loginService = GetIt.instance<LoginService>();
    _logoutService = GetIt.instance<LogoutService>();
    _bugReportService = GetIt.instance<BugReportService>();
    _loadUserData();
  }

  /// Load user data
  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await _loginService.getCurrentUser();
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load profile: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  /// Function to logout
  Future<void> _logout() async {
    try {
      // Confirm logout
      final shouldLogout = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out of your account?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[700]),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Logout',
                style: TextStyle(color: primaryPink),
              ),
            ),
          ],
        ),
      );

      if (shouldLogout == true) {
        // Clear user data from bug reporting system before logout
        await _bugReportService.clearUserData();

        // Implement logout according to logout service
        await _logoutService.logout();

        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to logout: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Set index on navigation provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NavigationProvider>(context, listen: false).setIndex(4);
    });

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          title: const Text(
            'Profile',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadUserData,
              tooltip: 'Refresh',
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? _buildErrorView()
                : _buildProfileView(),
        bottomNavigationBar: const CustomBottomNavBar(),
      ),
    );
  }

  /// Widget to display error view
  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: primaryPink,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Failed to load profile',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadUserData,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryPink,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget to display profile view
  Widget _buildProfileView() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 16),
          _buildProfileStats(),
          const SizedBox(height: 16),
          _buildProfileActions(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// Widget to display profile header
  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 30, bottom: 20),
      margin: const EdgeInsets.only(left: 16, right: 16, top: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile picture
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: primaryPink.withOpacity(0.1),
                  backgroundImage: _currentUser?.photoURL != null
                      ? NetworkImage(_currentUser!.photoURL!)
                      : null,
                  child: _currentUser?.photoURL == null
                      ? Text(
                          _getInitials(),
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: primaryPink,
                          ),
                        )
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // User name
          Text(
            _currentUser?.displayName ?? 'Pockeat User',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // User email
          Text(
            _currentUser?.email ?? '',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),

          // Login provider badge
          const SizedBox(height: 8),
          _buildLoginProviderBadge(),

          // Email verification status
          const SizedBox(height: 12),
          _buildVerificationStatus(),
        ],
      ),
    );
  }

  /// Widget to display login provider badge
  Widget _buildLoginProviderBadge() {
    final user = _auth.currentUser;

    // Check provider data to determine login method
    final providerData = user?.providerData;
    bool isGoogleLogin = false;

    if (providerData != null && providerData.isNotEmpty) {
      // Check for google.com provider ID
      isGoogleLogin =
          providerData.any((element) => element.providerId == 'google.com');
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: isGoogleLogin
            ? const Color(0xFFE8F0FE)
            : primaryPink.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isGoogleLogin
              ? const Color(0xFF4285F4)
              : primaryPink.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isGoogleLogin)
            SizedBox(
              height: 14,
              width: 14,
              child: Image.asset(
                'assets/images/google.png',
                height: 14,
                width: 14,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback to a letter G if image asset not found
                  return Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF4285F4),
                    ),
                    child: const Center(
                      child: Text(
                        'G',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          else
            Icon(
              Icons.email_outlined,
              size: 14,
              color: primaryPink,
            ),
          const SizedBox(width: 6),
          Text(
            isGoogleLogin ? 'Google Login' : 'Email Login',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isGoogleLogin ? const Color(0xFF4285F4) : primaryPink,
            ),
          ),
        ],
      ),
    );
  }

  /// Widget to display email verification status
  Widget _buildVerificationStatus() {
    final isVerified = _currentUser?.emailVerified == true;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isVerified
                ? primaryGreen.withOpacity(0.1)
                : Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isVerified ? Icons.verified_user : Icons.warning,
                size: 16,
                color: isVerified ? primaryGreen : Colors.orange,
              ),
              const SizedBox(width: 6),
              Text(
                isVerified
                    ? 'Email verified'
                    : 'Email not verified',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isVerified ? primaryGreen : Colors.orange,
                ),
              ),
            ],
          ),
        ),

        // Resend verification email button
        if (!isVerified)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: TextButton(
              onPressed: _sendVerificationEmail,
              style: TextButton.styleFrom(
                foregroundColor: primaryPink,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                backgroundColor: primaryPink.withOpacity(0.05),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: primaryPink.withOpacity(0.2)),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.send, size: 16),
                  SizedBox(width: 8),
                  Text('Send Verification Email',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  /// Function to send verification email
  Future<void> _sendVerificationEmail() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.sendEmailVerification();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Verification email has been sent. Please check your inbox.'),
              backgroundColor: Color(0xFF4ECDC4),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send verification email: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Widget for profile statistics
  Widget _buildProfileStats() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(
            icon: Icons.calendar_today_outlined,
            label: 'Joined',
            value: _currentUser?.createdAt != null
                ? '${_currentUser!.createdAt.day}/${_currentUser!.createdAt.month}/${_currentUser!.createdAt.year}'
                : 'N/A',
            color: primaryGreen,
          ),
          _buildVerticalDivider(),
          _buildStatItem(
            icon: Icons.person_outline_rounded,
            label: 'Status',
            value: _currentUser?.emailVerified == true
                ? 'Verified'
                : 'Not Verified',
            color: primaryPink,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 22,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey.withOpacity(0.2),
    );
  }

  /// Widget for profile action menu
  Widget _buildProfileActions() {
    // Check if user logged in using Google
    final user = _auth.currentUser;
    final providerData = user?.providerData;
    bool isGoogleLogin = false;

    if (providerData != null && providerData.isNotEmpty) {
      // Check for google.com provider ID
      isGoogleLogin =
          providerData.any((element) => element.providerId == 'google.com');
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 16, bottom: 8),
            child: Text(
              'Account Settings',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ),
          _buildActionTile(
            title: 'Edit Profile',
            subtitle: 'Update your profile information',
            icon: Icons.edit,
            onTap: () async {
              // Navigate to edit profile page
              final result = await Navigator.of(context).pushNamed(
                '/edit-profile',
                arguments: _currentUser,
              );

              // Reload user data if there are changes
              if (result == true) {
                // coverage:ignore-line
                _loadUserData();
              }
            },
          ),
          if (!isGoogleLogin) ...[
            _buildDivider(),
            _buildActionTile(
              title: 'Change Password',
              subtitle: 'Update your account password',
              icon: Icons.lock_outline,
              onTap: () {
                // Navigate to change password page
                // coverage:ignore-line
                Navigator.of(context).pushNamed('/change-password');
              },
            ),
          ],
          _buildDivider(),
          _buildActionTile(
            title: 'Notification Settings',
            subtitle: 'Manage app notification settings',
            icon: Icons.notifications_outlined,
            onTap: () {
              Navigator.of(context).pushNamed('/notification-settings');
            },
          ),
          _buildDivider(),
          _buildActionTile(
            title: 'Widget Settings',
            subtitle: 'Manage app widgets on home screen',
            icon: Icons.widgets_outlined,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const WidgetManagerScreen(),
                ),
              );
            },
          ),
          _buildDivider(),
          _buildActionTile(
            title: 'Report Bug',
            subtitle: 'Help us improve the app',
            icon: Icons.bug_report_outlined,
            onTap: () async {
              // Ensure user data is set correctly before showing bug reporting UI
              if (_currentUser != null) {
                // Set current user data for context in the bug report
                await _bugReportService.setUserData(_currentUser!);

                // Show the bug reporting UI
                final result = await _bugReportService.show();

                if (!result && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to open bug reporting'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } else {
                // Handle case when user data is not available
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'User data not available for bug reporting'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              }
            },
          ),
          _buildDivider(),
          _buildActionTile(
            title: 'Logout',
            subtitle: 'Sign out from your account',
            icon: Icons.logout,
            iconColor: primaryPink,
            textColor: primaryPink,
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  /// Helper to build divider
  Widget _buildDivider() {
    return Divider(
      color: Colors.grey.withOpacity(0.2),
      thickness: 1,
      height: 1,
      indent: 16,
      endIndent: 16,
    );
  }

  /// Helper to build action tile
  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (iconColor ?? primaryGreen).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor ?? primaryGreen,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: textColor ?? Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  /// Helper untuk mendapatkan inisial dari nama pengguna
  String _getInitials() {
    final name = _currentUser?.displayName;
    if (name == null || name.isEmpty) {
      return 'P'; // Default for Pockeat User
    }

    final nameParts = name.trim().split(' ');
    if (nameParts.length >= 2) {
      // Get initials from first and last name
      return '${nameParts[0][0]}${nameParts[1][0]}';
    } else if (nameParts.isNotEmpty) {
      // If only one word, use the first letter
      return nameParts[0][0];
    } else {
      return 'P';
    }
  }
}
