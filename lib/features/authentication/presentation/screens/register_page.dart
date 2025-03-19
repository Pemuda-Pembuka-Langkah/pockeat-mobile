import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:intl/intl.dart';
import 'package:get_it/get_it.dart';
import 'package:pockeat/features/authentication/services/register_service.dart';

/// Halaman untuk registrasi pengguna baru
///
/// Halaman ini berisi form untuk mengisi data registrasi seperti
/// email, password, nama, tanggal lahir, dan jenis kelamin.
/// Pengguna juga harus menyetujui syarat dan ketentuan.
class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedGender;
  bool _termsAccepted = false;
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String? _errorMessage;

  // State untuk alur registrasi
  bool _isRegistrationSuccess = false;
  bool _isRegistrationPending = false;

  // Colors dari ExerciseHistoryPage
  final Color primaryPink = const Color(0xFFFF6B6B);
  final Color primaryGreen = const Color(0xFF4ECDC4);
  final Color bgColor = const Color(0xFFF9F9F9);

  late RegisterService _registerService;

  // List gender options
  final List<String> _genderOptions = ['Pria', 'Wanita', 'Lainnya'];

  @override
  void initState() {
    super.initState();
    _registerService = GetIt.instance<RegisterService>();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // Fungsi untuk menangani register
  Future<void> _register() async {
    // Tutup keyboard
    FocusScope.of(context).unfocus();

    // Validasi form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validasi terms and conditions
    if (!_termsAccepted) {
      setState(() {
        _errorMessage = 'Anda harus menyetujui syarat dan ketentuan';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _registerService.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
        termsAccepted: _termsAccepted,
        displayName: _nameController.text.trim(),
        birthDate: _selectedDate,
        gender: _selectedGender,
      );

      setState(() {
        _isLoading = false;
      });

      if (result == RegisterResult.success) {
        setState(() {
          _isRegistrationSuccess = true;
          _isRegistrationPending = true;
        });

        // Cek apakah sudah terverifikasi
        final isVerified = await _registerService.isEmailVerified();

        if (mounted) {
          if (isVerified) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Registrasi berhasil! Email Anda telah terverifikasi.'),
                backgroundColor: primaryGreen,
              ),
            );

            // Navigasi ke homepage
            Navigator.pushReplacementNamed(context, '/');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text('Registrasi berhasil! Silakan verifikasi email Anda.'),
                backgroundColor: primaryGreen,
              ),
            );
          }
        }
      } else {
        // Tampilkan pesan error
        setState(() {
          _errorMessage = _getErrorMessage(result);
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
      });
    }
  }

  // Mendapatkan pesan error berdasarkan hasil register
  String _getErrorMessage(RegisterResult result) {
    switch (result) {
      case RegisterResult.emailAlreadyInUse:
        return 'Email sudah digunakan. Silakan gunakan email lain.';
      case RegisterResult.invalidEmail:
        return 'Format email tidak valid.';
      case RegisterResult.weakPassword:
        return 'Password terlalu lemah. Gunakan minimal 8 karakter dengan huruf besar, huruf kecil, dan angka.';
      case RegisterResult.operationNotAllowed:
        return 'Operasi tidak diizinkan.';
      case RegisterResult.unknown:
        return 'Terjadi kesalahan. Silakan coba lagi.';
      default:
        return 'Terjadi kesalahan. Silakan coba lagi.';
    }
  }

  // Fungsi untuk memilih tanggal lahir
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ??
          DateTime.now()
              .subtract(const Duration(days: 365 * 18)), // Default 18 tahun
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryPink,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Mengirim ulang email verifikasi
  Future<void> _resendVerificationEmail() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _registerService.resendEmailVerification();

      setState(() {
        _isLoading = false;
      });

      if (result && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email verifikasi telah dikirim ulang.'),
            backgroundColor: primaryGreen,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Gagal mengirim email verifikasi. Silakan coba lagi.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan. Silakan coba lagi.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Cek status verifikasi email
  Future<void> _checkVerificationStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final isVerified = await _registerService.isEmailVerified();

      setState(() {
        _isLoading = false;
      });

      if (isVerified && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email telah terverifikasi!'),
            backgroundColor: primaryGreen,
          ),
        );

        // Navigasi ke homepage
        Navigator.pushReplacementNamed(context, '/');
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email belum terverifikasi. Silakan cek inbox Anda.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan. Silakan coba lagi.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: _isRegistrationSuccess
                ? _buildVerificationUI()
                : _buildRegistrationForm(),
          ),
        ),
      ),
    );
  }

  // Form registrasi
  Widget _buildRegistrationForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Logo atau Icon
          Icon(
            Icons.fitness_center,
            size: 80,
            color: primaryPink,
          ),

          const SizedBox(height: 20),

          // Judul
          Text(
            'Buat Akun Baru',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: primaryPink,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Subtitle
          Text(
            'Daftar untuk mulai perjalanan kesehatan Anda',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 30),

          // Error message
          if (_errorMessage != null)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),

          if (_errorMessage != null) const SizedBox(height: 20),

          // Nama lengkap
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Nama Lengkap',
              hintText: 'Masukkan nama lengkap Anda',
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: primaryPink),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Nama tidak boleh kosong';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Email
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'Masukkan email Anda',
              prefixIcon: const Icon(Icons.email),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: primaryPink),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Email tidak boleh kosong';
              }
              // Validasi format email
              final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!emailRegExp.hasMatch(value)) {
                return 'Format email tidak valid';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Password
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Minimal 8 karakter',
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: primaryPink),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password tidak boleh kosong';
              }
              if (value.length < 8) {
                return 'Password minimal 8 karakter';
              }
              // Validasi password kuat
              final passwordRegExp =
                  RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}$');
              if (!passwordRegExp.hasMatch(value)) {
                return 'Password harus mengandung huruf besar, huruf kecil, dan angka';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Konfirmasi Password
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: !_isConfirmPasswordVisible,
            decoration: InputDecoration(
              labelText: 'Konfirmasi Password',
              hintText: 'Masukkan password yang sama',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _isConfirmPasswordVisible
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: primaryPink),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Konfirmasi password tidak boleh kosong';
              }
              if (value != _passwordController.text) {
                return 'Password tidak cocok';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Tanggal Lahir
          GestureDetector(
            onTap: () => _selectDate(context),
            child: AbsorbPointer(
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Tanggal Lahir (Opsional)',
                  hintText: 'Pilih tanggal lahir',
                  prefixIcon: const Icon(Icons.calendar_today),
                  suffixIcon: Icon(Icons.arrow_drop_down, color: primaryPink),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: primaryPink),
                  ),
                ),
                controller: TextEditingController(
                  text: _selectedDate != null
                      ? DateFormat('dd MMMM yyyy').format(_selectedDate!)
                      : '',
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Jenis Kelamin
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Jenis Kelamin (Opsional)',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: primaryPink),
              ),
            ),
            value: _selectedGender,
            items: _genderOptions
                .map((gender) => DropdownMenuItem(
                      value: gender,
                      child: Text(gender),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedGender = value;
              });
            },
            hint: const Text('Pilih jenis kelamin'),
          ),

          const SizedBox(height: 20),

          // Checkbox Syarat dan Ketentuan
          Row(
            children: [
              SizedBox(
                height: 24,
                width: 24,
                child: Checkbox(
                  activeColor: primaryPink,
                  value: _termsAccepted,
                  onChanged: (value) {
                    setState(() {
                      _termsAccepted = value ?? false;
                      if (_termsAccepted) {
                        _errorMessage = null;
                      }
                    });
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    text: 'Saya menyetujui ',
                    style: TextStyle(color: Colors.grey[700]),
                    children: [
                      TextSpan(
                        text: 'Syarat dan Ketentuan',
                        style: TextStyle(
                          color: primaryPink,
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // Navigasi ke halaman Terms and Conditions
                            print('Buka Terms and Conditions');
                          },
                      ),
                      TextSpan(
                        text: ' PockEat',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          // Tombol Register
          SizedBox(
            height: 55,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _register,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryPink,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                disabledBackgroundColor: primaryPink.withOpacity(0.5),
              ),
              child: _isLoading
                  ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : const Text(
                      'DAFTAR',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 20),

          // Link ke halaman login
          Center(
            child: RichText(
              text: TextSpan(
                text: 'Sudah punya akun? ',
                style: TextStyle(color: Colors.grey[700]),
                children: [
                  TextSpan(
                    text: 'Masuk',
                    style: TextStyle(
                      color: primaryPink,
                      fontWeight: FontWeight.bold,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        // Navigasi ke halaman login
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // UI verifikasi email
  Widget _buildVerificationUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Icon
        Icon(
          Icons.mark_email_read,
          size: 100,
          color: primaryGreen,
        ),

        const SizedBox(height: 30),

        // Judul
        Text(
          'Verifikasi Email Anda',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: primaryPink,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 20),

        // Deskripsi
        Text(
          'Kami telah mengirimkan email verifikasi ke ${_emailController.text}. Silakan cek inbox atau folder spam Anda untuk verifikasi.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 40),

        // Tombol cek status verifikasi
        SizedBox(
          height: 55,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _checkVerificationStatus,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              disabledBackgroundColor: primaryGreen.withOpacity(0.5),
            ),
            child: _isLoading
                ? CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                : const Text(
                    'SUDAH VERIFIKASI',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
          ),
        ),

        const SizedBox(height: 16),

        // Tombol kirim ulang email verifikasi
        SizedBox(
          height: 55,
          child: OutlinedButton(
            onPressed: _isLoading ? null : _resendVerificationEmail,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: primaryPink),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'KIRIM ULANG EMAIL',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                color: primaryPink,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Tombol kembali ke halaman login
        TextButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/login');
          },
          child: Text(
            'Kembali ke Login',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Tombol lanjut ke beranda
        TextButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/');
          },
          child: Text(
            'Lanjut ke Beranda',
            style: TextStyle(
              fontSize: 16,
              color: primaryGreen,
            ),
          ),
        ),
      ],
    );
  }
}
