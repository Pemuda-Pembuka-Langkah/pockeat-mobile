/// Enum untuk tipe deep link
enum DeepLinkType {
  emailVerification,
  changePassword,
  unknown,
}

/// Model untuk hasil deep link
class DeepLinkResult {
  /// Tipe deep link
  final DeepLinkType type;

  /// Apakah deep link berhasil diproses
  final bool success;

  /// Data dari deep link (opsional)
  final Map<String, dynamic>? data;

  /// Pesan error jika gagal (opsional)
  final String? error;

  /// URI asli dari deep link
  final Uri? originalUri;

  /// Constructor
  DeepLinkResult({
    required this.type,
    required this.success,
    this.data,
    this.error,
    this.originalUri,
  });

  /// Factory constructor untuk email verification
  factory DeepLinkResult.emailVerification({
    required bool success,
    Map<String, dynamic>? data,
    String? error,
    Uri? originalUri,
  }) {
    return DeepLinkResult(
      type: DeepLinkType.emailVerification,
      success: success,
      data: data,
      error: error,
      originalUri: originalUri,
    );
  }

  /// Factory constructor untuk change password
  factory DeepLinkResult.changePassword({
    required bool success,
    Map<String, dynamic>? data,
    String? error,
    Uri? originalUri,
  }) {
    return DeepLinkResult(
      type: DeepLinkType.changePassword,
      success: success,
      data: data,
      error: error,
      originalUri: originalUri,
    );
  }

  /// Factory constructor untuk unknown
  factory DeepLinkResult.unknown({
    Uri? originalUri,
    String? error,
  }) {
    return DeepLinkResult(
      type: DeepLinkType.unknown,
      success: false,
      error: error ?? 'Unknown deep link type',
      originalUri: originalUri,
    );
  }
}
