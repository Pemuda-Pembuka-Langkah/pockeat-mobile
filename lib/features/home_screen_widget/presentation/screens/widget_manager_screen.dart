// lib/features/home_screen_widget/presentation/screens/widget_manager_screen.dart

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:pockeat/features/home_screen_widget/controllers/widget_installation_controller.dart';
import 'package:pockeat/features/home_screen_widget/domain/models/widget_installation_status.dart';
import 'package:pockeat/features/home_screen_widget/presentation/widgets/widget_preview_card_factory.dart';

/// Screen to manage home screen widgets
class WidgetManagerScreen extends StatefulWidget {
  /// Creates a widget manager screen
  const WidgetManagerScreen({super.key});

  @override
  State<WidgetManagerScreen> createState() => _WidgetManagerScreenState();
}

class _WidgetManagerScreenState extends State<WidgetManagerScreen> {
  late final WidgetInstallationController _controller;
  WidgetInstallationStatus _status = const WidgetInstallationStatus(
    isSimpleWidgetInstalled: false,
    isDetailedWidgetInstalled: false,
  );
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = GetIt.instance<WidgetInstallationController>();
    _loadWidgetStatus();

    // Listen to widget status changes
    _controller.widgetStatusStream.listen((status) {
      if (mounted) {
        setState(() {
          _status = status;
        });
      }
    });
  }

  /// Load initial widget status
  Future<void> _loadWidgetStatus() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final status = await _controller.getWidgetStatus();
      
      if (mounted) {
        setState(() {
          _status = status;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load widget status: $e';
          _isLoading = false;
        });
      }
    }
  }

  /// Install widget of specified type
  Future<bool> _installWidget(WidgetType type) async {
    try {
      return await _controller.installWidget(type);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error installing widget: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Widget Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadWidgetStatus,
            tooltip: 'Refresh widget status',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  /// Build the main body based on loading state
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadWidgetStatus,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadWidgetStatus,
      child: _buildWidgetList(),
    );
  }

  /// Build the list of widget cards
  Widget _buildWidgetList() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(),
          const SizedBox(height: 16),
          ..._buildWidgetCards(),
        ],
      ),
    );
  }

  /// Build the section header with explanation
  Widget _buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Available Widgets',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Add these widgets to your home screen for quick access to your nutrition tracking data.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  /// Build widget cards using factory
  List<Widget> _buildWidgetCards() {
    return WidgetPreviewCardFactory.createAllWidgetCards(
      _status.isSimpleWidgetInstalled,
      _status.isDetailedWidgetInstalled,
      _installWidget,
    );
  }

  @override
  void dispose() {
    // No need to dispose of controller as it's managed by GetIt
    super.dispose();
  }
}
