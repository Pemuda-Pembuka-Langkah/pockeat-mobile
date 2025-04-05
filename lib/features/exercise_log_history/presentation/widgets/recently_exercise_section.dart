import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pockeat/features/exercise_log_history/domain/models/exercise_log_history_item.dart';
import 'package:pockeat/features/exercise_log_history/services/exercise_log_history_service.dart';
import 'package:pockeat/features/exercise_log_history/presentation/widgets/exercise_history_card.dart';

/// A widget that displays a section of recent exercise history items.
///
/// This widget connects to the ExerciseLogHistoryRepository to fetch exercise logs
/// and displays them using the ExerciseHistoryCard widget.
/// It handles its own navigation to exercise history pages.
class RecentlyExerciseSection extends StatefulWidget {
  final ExerciseLogHistoryService repository;
  final int limit;
  final FirebaseAuth? auth; // Add auth parameter for testing

  const RecentlyExerciseSection({
    super.key,
    required this.repository,
    this.limit = 5,
    this.auth,
  });

  @override
  State<RecentlyExerciseSection> createState() =>
      _RecentlyExerciseSectionState();
}

class _RecentlyExerciseSectionState extends State<RecentlyExerciseSection>
    with WidgetsBindingObserver {
  late Future<List<ExerciseLogHistoryItem>> _exercisesFuture;
  late final FirebaseAuth _auth;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _auth = widget.auth ?? FirebaseAuth.instance;
    _loadExercises();

    // Register as an observer to detect app lifecycle changes
    WidgetsBinding.instance.addObserver(this);

    // Listen to focus changes to detect when we return to this widget
    _focusNode.addListener(_onFocusChange);

    // Request focus to ensure we get focus events
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    // Clean up resources
    WidgetsBinding.instance.removeObserver(this);
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh data when app is resumed
    if (state == AppLifecycleState.resumed) {
      _loadExercises();
    }
  }

  void _onFocusChange() {
    // Refresh data when this widget gains focus
    if (_focusNode.hasFocus) {
      _loadExercises();
    }
  }

  @override
  void didUpdateWidget(RecentlyExerciseSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.repository != widget.repository ||
        oldWidget.limit != widget.limit) {
      _loadExercises();
    }
  }

  void _loadExercises() {
    final user = _auth.currentUser;
    final userId = user?.uid ?? '';

    setState(() {
      _exercisesFuture =
          widget.repository.getAllExerciseLogs(userId, limit: widget.limit);
    });
  }

  void _navigateToAllExercises() {
    Navigator.of(context).pushNamed('/exercise-history').then((_) {
// coverage:ignore-start

      // Refresh data when returning from exercise history page
      _loadExercises();
    });
  }

  void _navigateToExerciseDetail(ExerciseLogHistoryItem exercise) {
    Navigator.of(context).pushNamed(
      '/exercise-detail',
      arguments: {
        'exerciseId': exercise.sourceId ??
            exercise.id, // Gunakan sourceId jika ada, atau fallback ke id
        'activityType': exercise.activityType,
      },
    ).then((_) {
      // Refresh data when returning from detail page
      _loadExercises();
    });
  }
// coverage:ignore-end

  @override
  Widget build(BuildContext context) {
    final Color primaryPink = const Color(0xFFFF6B6B);

    return Focus(
      focusNode: _focusNode,
      child: SingleChildScrollView(
        padding:
            const EdgeInsets.only(bottom: 16), // Add consistent bottom padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  16, 16, 16, 16), // Added bottom padding
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Exercises',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  GestureDetector(
                    onTap: _navigateToAllExercises,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6), // Fixed padding
                      decoration: BoxDecoration(
                        color: primaryPink.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Show All',
                        style: TextStyle(
                          color: primaryPink,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            FutureBuilder<List<ExerciseLogHistoryItem>>(
              future: _exercisesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: 16), // Consistent vertical padding
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16), // Consistent with other paddings
                    child: Center(
                      child: Text(
                        'Error loading exercises: ${snapshot.error}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16), // Consistent with other paddings
                    child: Center(
                      child: Text(
                        'No exercise history yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  );
                } else {
                  final exercises = snapshot.data!;
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16), // Consistent horizontal padding
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding:
                          EdgeInsets.zero, // No additional padding in ListView
                      itemCount: exercises.length,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(
                            bottom: 8), // Consistent spacing between cards
                        child: ExerciseHistoryCard(
                          exercise: exercises[index],
                          // coverage:ignore-start
                          onTap: () =>
                              _navigateToExerciseDetail(exercises[index]),
                          // coverage:ignore-end

                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
