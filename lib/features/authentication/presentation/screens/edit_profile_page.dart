import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pockeat/features/authentication/domain/model/user_model.dart';
import 'package:pockeat/features/authentication/services/profile_service.dart';

/// Halaman edit profil pengguna
///
/// Menampilkan form untuk edit:
/// - Nama pengguna (displayName)
/// - Foto profil (photoURL)

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
  // Colors - sama dengan di profile page untuk konsistensi
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

    // Inisialisasi dengan data dari initialUser jika ada
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

  /// Memuat data user jika initialUser tidak tersedia
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
        _errorMessage = 'Gagal memuat profil: ${e.toString()}';
      });
    }
  }

  /// Fungsi untuk memilih foto dari galeri
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
            content: Text('Gagal memilih gambar: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Fungsi untuk mengambil foto dari kamera
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
            content: Text('Gagal mengambil foto: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Mengupload foto yang dipilih ke Firebase Storage
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
            content: Text('Gagal mengupload foto: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }

      return null;
    }
  }

  /// Tampilkan dialog pilihan sumber foto (kamera/galeri)
  Future<void> _showImageSourceDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Sumber Foto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_library, color: primaryPink),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImageFromGallery();
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt, color: primaryPink),
              title: const Text('Ambil Foto'),
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
            child: const Text('Batal'),
          ),
        ],
      ),
    );
  }

  /// Menyimpan perubahan profil
  Future<void> _saveChanges() async {
    // Validasi input
    final displayName = _displayNameController.text.trim();
    if (displayName.isEmpty) {
      if (widget.useScaffold && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nama tidak boleh kosong'),
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
      // Upload foto jika ada foto yang dipilih
      String? finalPhotoURL = _photoURL;
      if (_selectedImageFile != null) {
        finalPhotoURL = await _uploadSelectedImage();
        if (finalPhotoURL == null && _selectedImageFile != null) {
          setState(() {
            _isSaving = false;
            _errorMessage = 'Gagal mengupload foto profil';
          });
          return;
        }
      }

      // Update profil
      final success = await _profileService.updateUserProfile(
        displayName: displayName,
        photoURL: finalPhotoURL,
      );

      if (success && mounted) {
        if (widget.useScaffold) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Profil berhasil diperbarui'),
              backgroundColor: primaryGreen,
            ),
          );
        }

        // Kembali ke halaman profil
        Navigator.of(context)
            .pop(true); // true untuk memberi tahu perubahan berhasil
      } else if (mounted) {
        setState(() {
          _errorMessage = 'Gagal memperbarui profil';
          _isSaving = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
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
          'Edit Profil',
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

  /// Widget untuk menampilkan pesan error
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
              _errorMessage ?? 'Terjadi kesalahan',
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
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget untuk form edit profil
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
              label: 'Nama',
              icon: Icons.person_outline,
              controller: _displayNameController,
              hintText: 'Masukkan nama Anda',
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

  /// Widget untuk menampilkan dan memilih foto profil
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
            'Foto Profil',
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
              child: const Text('Batalkan foto baru'),
            ),
          ],
        ],
      ),
    );
  }

  /// Mendapatkan gambar profil (image provider) yang sesuai
  ImageProvider? _getProfileImage() {
    if (_selectedImageFile != null) {
      // Gunakan file lokal jika ada foto yang baru dipilih
      return FileImage(_selectedImageFile!);
    } else if (_photoURL != null) {
      // Gunakan URL jika ada foto yang sudah diupload sebelumnya
      return NetworkImage(_photoURL!);
    }
    return null;
  }

  /// Widget untuk kelompok input dengan label dan ikon
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

  /// Widget untuk menampilkan email (tidak dapat diedit)
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
          children: [
            Icon(
              _currentUser?.emailVerified == true
                  ? Icons.verified_user
                  : Icons.warning,
              size: 16,
              color: _currentUser?.emailVerified == true
                  ? primaryGreen
                  : Colors.orange,
            ),
            const SizedBox(width: 6),
            Text(
              _currentUser?.emailVerified == true
                  ? 'Email terverifikasi'
                  : 'Email belum terverifikasi',
              style: TextStyle(
                fontSize: 12,
                color: _currentUser?.emailVerified == true
                    ? primaryGreen
                    : Colors.orange,
              ),
            ),
            if (_currentUser?.emailVerified != true) ...[
              const SizedBox(width: 8),
              TextButton(
                onPressed: _sendVerificationEmail,
                style: TextButton.styleFrom(
                  foregroundColor: primaryPink,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: const Size(0, 0),
                ),
                child: const Text(
                  'Kirim verifikasi',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  /// Widget tombol simpan
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSaving || _isUploadingImage ? null : _saveChanges,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPink,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 1,
        ),
        child: _isSaving
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Simpan Perubahan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  /// Fungsi untuk mengirim email verifikasi
  Future<void> _sendVerificationEmail() async {
    try {
      final success = await _profileService.sendEmailVerification();

      if (success && mounted) {
        if (widget.useScaffold) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Email verifikasi telah dikirim'),
              backgroundColor: primaryGreen,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        // Jika dalam test mode (useScaffold = false), kita lewati tampilan SnackBar
      } else if (mounted) {
        if (widget.useScaffold) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal mengirim email verifikasi'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted && widget.useScaffold) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Helper untuk mendapatkan inisial dari nama pengguna
  String _getInitials() {
    final name = _currentUser?.displayName;
    if (name == null || name.isEmpty) {
      return '?';
    }

    final nameParts = name.split(' ');
    if (nameParts.length == 1) {
      return nameParts[0][0].toUpperCase();
    }

    return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
  }
}
// coverage:ignore-end
