// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';

// Project imports:
import 'package:pockeat/features/authentication/domain/model/user_model.dart';
import 'package:pockeat/features/authentication/services/profile_service.dart';

/// User profile edit page
///
/// Displays form to edit:
/// - User name (displayName)
/// - Profile photo (photoURL)

// coverage:ignore-start
class EditProfilePage extends StatefulWidget {
  final UserModel? initialUser;
  final bool useScaffold;

  const EditProfilePage({
    super.key,
    this.initialUser,
    this.useScaffold = true,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // Colors - same as in profile page for consistency
  final Color primaryPink = const Color(0xFFFF6B6B);
  final Color primaryGreen = const Color(0xFF4ECDC4);
  final Color bgColor = const Color(0xFFF9F9F9);

  late final ProfileService _profileService;
  late final TextEditingController _displayNameController;
  final ImagePicker _imagePicker = ImagePicker();

  UserModel? _currentUser;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUploadingImage = false;
  String? _errorMessage;
  String? _photoURL;
  File? _selectedImageFile;

  @override
  void initState() {
    super.initState();
    _profileService = GetIt.instance<ProfileService>();

    // Initialize with data from initialUser if available
    _currentUser = widget.initialUser;
    _displayNameController = TextEditingController(
      text: _currentUser?.displayName ?? '',
    );
    _photoURL = _currentUser?.photoURL;

    if (_currentUser == null) {
      _loadUserData();
    } else {
      _isLoading = false;
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  /// Load user data if initialUser is not available
  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await _profileService.getCurrentUser();
      setState(() {
        _currentUser = user;
        _displayNameController.text = user?.displayName ?? '';
        _photoURL = user?.photoURL;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load profile: ${e.toString()}';
      });
    }
  }

  /// Function to pick photo from gallery
  Future<void> _pickImageFromGallery() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (widget.useScaffold && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to select image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Function to take photo from camera
  Future<void> _takePhoto() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (widget.useScaffold && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to take photo: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Upload selected photo to Firebase Storage
  Future<String?> _uploadSelectedImage() async {
    if (_selectedImageFile == null) return _photoURL;

    setState(() {
      _isUploadingImage = true;
    });

    try {
      final uploadedPhotoURL =
          await _profileService.uploadProfileImage(_selectedImageFile!);

      setState(() {
        _isUploadingImage = false;
        if (uploadedPhotoURL != null) {
          _photoURL = uploadedPhotoURL;
        }
      });

      return uploadedPhotoURL;
    } catch (e) {
      setState(() {
        _isUploadingImage = false;
      });

      if (widget.useScaffold && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload photo: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }

      return null;
    }
  }

  /// Show image source selection dialog (camera/gallery)
  Future<void> _showImageSourceDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Photo Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_library, color: primaryPink),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImageFromGallery();
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt, color: primaryPink),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.of(context).pop();
                _takePhoto();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  /// Save profile changes
  Future<void> _saveChanges() async {
    // Validate input
    final displayName = _displayNameController.text.trim();
    if (displayName.isEmpty) {
      if (widget.useScaffold && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Name cannot be empty'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      // Upload photo if a new one is selected
      String? finalPhotoURL = _photoURL;
      if (_selectedImageFile != null) {
        finalPhotoURL = await _uploadSelectedImage();
        if (finalPhotoURL == null && _selectedImageFile != null) {
          setState(() {
            _isSaving = false;
            _errorMessage = 'Failed to upload profile photo';
          });
          return;
        }
      }

      // Update profile
      final success = await _profileService.updateUserProfile(
        displayName: displayName,
        photoURL: finalPhotoURL,
      );

      if (success && mounted) {
        if (widget.useScaffold) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Profile successfully updated'),
              backgroundColor: primaryGreen,
            ),
          );
        }

        // Return to profile page
        Navigator.of(context)
            .pop(true); // true to indicate successful update
      } else if (mounted) {
        setState(() {
          _errorMessage = 'Failed to update profile';
          _isSaving = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'An error occurred: ${e.toString()}';
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _errorMessage != null
            ? _buildErrorView()
            : _buildProfileForm();

    if (!widget.useScaffold) {
      return content;
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: content,
    );
  }

  /// Widget to display error message
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
              _errorMessage ?? 'An error occurred',
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget for profile edit form
  Widget _buildProfileForm() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfilePicture(),
            const SizedBox(height: 24),
            _buildInputGroup(
              label: 'Name',
              icon: Icons.person_outline,
              controller: _displayNameController,
              hintText: 'Enter your name',
            ),
            const SizedBox(height: 24),
            _buildEmailField(),
            const SizedBox(height: 40),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  /// Widget to display and select profile photo
  Widget _buildProfilePicture() {
    return Center(
      child: Column(
        children: [
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
                child: _isUploadingImage
                    ? const CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey,
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : CircleAvatar(
                        radius: 60,
                        backgroundColor: primaryPink.withOpacity(0.1),
                        backgroundImage: _getProfileImage(),
                        child: _selectedImageFile == null && _photoURL == null
                            ? Text(
                                _getInitials(),
                                style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: primaryPink,
                                ),
                              )
                            : null,
                      ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: primaryPink,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: IconButton(
                  icon: const Icon(Icons.camera_alt,
                      color: Colors.white, size: 20),
                  onPressed: _showImageSourceDialog,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Profile Photo',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          if (_selectedImageFile != null) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedImageFile = null;
                });
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: const Size(0, 0),
              ),
              child: const Text('Cancel new photo'),
            ),
          ],
        ],
      ),
    );
  }

  /// Get appropriate profile image provider
  ImageProvider? _getProfileImage() {
    if (_selectedImageFile != null) {
      // Use local file if a new photo is selected
      return FileImage(_selectedImageFile!);
    } else if (_photoURL != null) {
      // Use URL if a photo has been previously uploaded
      return NetworkImage(_photoURL!);
    }
    return null;
  }

  /// Widget for input group with label and icon
  Widget _buildInputGroup({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required String hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: primaryPink),
              hintText: hintText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: primaryPink),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  /// Widget to display email (non-editable)
  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            readOnly: true,
            enabled: false,
            controller: TextEditingController(text: _currentUser?.email ?? ''),
            decoration: InputDecoration(
              prefixIcon:
                  Icon(Icons.email_outlined, color: Colors.grey.shade500),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              filled: true,
              fillColor: Colors.grey.shade100,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Show verification status
            if (_currentUser != null && !_currentUser!.emailVerified)
              Row(
                children: [
                  const Icon(Icons.info_outline,
                      size: 16, color: Colors.orange),
                  const SizedBox(width: 4),
                  const Text(
                    'Email not verified',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: _isSaving ? null : _sendVerificationEmail,
                    style: TextButton.styleFrom(
                      foregroundColor: primaryPink,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 0),
                      minimumSize: const Size(0, 0),
                    ),
                    child: const Text('Send verification email',
                        style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }

  /// Save button widget
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveChanges,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPink,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: _isSaving
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : const Text(
                'Save Changes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  /// Function to send verification email
  Future<void> _sendVerificationEmail() async {
    if (_currentUser == null) {
      if (widget.useScaffold && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email not found'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      final sent = await _profileService.sendEmailVerification();

      if (sent && mounted && widget.useScaffold) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Verification email sent to ${_currentUser!.email}. Please check your inbox.'),
            backgroundColor: primaryGreen,
          ),
        );
      } else if (mounted && widget.useScaffold) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send verification email'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted && widget.useScaffold) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Helper to get initials from username
  String _getInitials() {
    final name = _displayNameController.text.trim();
    if (name.isEmpty) return '?';

    final nameParts = name.split(' ');
    if (nameParts.length > 1) {
      // Get initials for the first and last name
      return '${nameParts.first[0]}${nameParts.last[0]}'.toUpperCase();
    } else {
      // Get the first character of the name
      return name[0].toUpperCase();
    }
  }
}
// coverage:ignore-end