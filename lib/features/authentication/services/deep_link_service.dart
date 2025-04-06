import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pockeat/features/authentication/domain/model/deep_link_result.dart';

/// Interface untuk menangani deep link
abstract class DeepLinkService {
  /// Inisialisasi service
  Future<void> initialize();

  /// Stream untuk mendapatkan initial link
  Stream<Uri?> getInitialLink();

  /// Stream untuk mendapatkan link yang diterima
  Stream<Uri?> onLinkReceived();

  /// Stream untuk mendapatkan hasil dari deep link
  Stream<DeepLinkResult> get onDeepLinkResult;

  /// Handle deep link yang diterima
  Future<bool> handleDeepLink(Uri link);

  /// Dispose resources
  void dispose();
}
