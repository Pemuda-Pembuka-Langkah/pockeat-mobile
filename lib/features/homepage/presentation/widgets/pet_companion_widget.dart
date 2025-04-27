// lib/features/homepage/presentation/widgets/pet_companion_widget.dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_it/get_it.dart';
import 'dart:math';
import 'pet_chat_bubble.dart';
import 'dart:async';

// coverage-ignore:start
class PetCompanionWidget extends StatefulWidget {
  final String petName;
  final String petImagePath;
  final double calorieProgress;

  const PetCompanionWidget({
    super.key,
    this.petName = 'Panda',
    this.petImagePath = 'assets/images/panda_sad.json',
    this.calorieProgress = 0.0,
  });

  @override
  State<PetCompanionWidget> createState() => _PetCompanionWidgetState();
}

class _PetCompanionWidgetState extends State<PetCompanionWidget> {
  String? backgroundImage = '';
  String beachBackground = 'assets/images/beach.jpg';
  String gymBackground = 'assets/images/gym.jpg';
  String kitchenBackground = 'assets/images/kitchen.jpg';
  Timer? _mealTimer;

  // Chat bubble state
  bool _showChatBubble = false;
  ChatBubbleType _currentBubbleType = ChatBubbleType.reminder;
  String _currentMessage = "";

  // Track if we've already shown each type of message today
  final Map<ChatBubbleType, bool> _shownToday = {
    ChatBubbleType.reminder: false,
    ChatBubbleType.almostFinished: false,
    ChatBubbleType.completed: false,
  };

  // Messages for each type
  final Map<ChatBubbleType, List<String>> _messages = {
    ChatBubbleType.reminder: [
      "Did you log your calories today? I'm here to help keep track!",
      "Hey there! Don't forget to log your meals today. It helps us both stay on track!",
      "Remember to track what you eat today. Small habits lead to big results!",
    ],
    ChatBubbleType.almostFinished: [
      "You're almost there. Just a few more bites left to reach your daily goal!",
      "So close to your goal! Keep pushing, you're doing amazing today!",
      "Nearly there! You've made such great progress today, just a little more to go!",
    ],
    ChatBubbleType.completed: [
      "You crushed your daily goal, great job! Let's celebrate with some well-deserved rest.",
      "Goal achieved! You're absolutely crushing it today! So proud of you!",
      "Mission accomplished! Your consistent effort is really paying off!",
    ],
  };

  @override
  void initState() {
    super.initState();
    loadBackground();

    // Check progress and decide which message to show based on current progress
    Future.microtask(() {
      _determineChatBubble();
    });

    _mealTimer = Timer(const Duration(seconds: 2), () {
      if (!_showChatBubble && widget.calorieProgress < 0.75) {
        _checkMealTimeReminder();
      }
    });
  }

  @override
  void dispose() {
    _mealTimer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(PetCompanionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If progress changed, check if we need to show a new bubble
    if (oldWidget.calorieProgress != widget.calorieProgress) {
      _determineChatBubble();
    }
  }

  Future<void> loadBackground() async {
    final prefs = GetIt.instance<SharedPreferences>();
    setState(() {
      backgroundImage = prefs.getString('backgroundImage') ?? gymBackground;
    });
  }

  Future<void> saveBackground(String? path) async {
    final prefs = GetIt.instance<SharedPreferences>();
    if (path != null) {
      await prefs.setString('backgroundImage', path);
    } else {
      await prefs.remove('backgroundImage');
    }
  }

  // Determine which bubble to show based on calorie progress
  void _determineChatBubble() {
    // For goal completion (100%)
    if (widget.calorieProgress >= 1.0 &&
        !_shownToday[ChatBubbleType.completed]!) {
      _showCelebrationBubble();
      _shownToday[ChatBubbleType.completed] = true;
      return; // Stop here if we're showing completion
    }

    // For almost there (75-90%)
    if (widget.calorieProgress >= 0.75 &&
        widget.calorieProgress < 1.0 &&
        !_shownToday[ChatBubbleType.almostFinished]!) {
      _showAlmostFinishedBubble();
      _shownToday[ChatBubbleType.almostFinished] = true;
      return; // Stop here if we're showing almost finished
    }

    // Don't add any more conditions here so we don't override priority messages
  }

  // Check if we need to show a meal time reminder
  void _checkMealTimeReminder() {
    // Only show reminder if no other messages are being shown
    // and we haven't shown a reminder today
    if (!_showChatBubble && !_shownToday[ChatBubbleType.reminder]!) {
      _showReminderBubble();
    }
  }

  // Get a random message for the specified type
  String _getRandomMessage(ChatBubbleType type) {
    final messages = _messages[type]!;
    final random = Random();
    return messages[random.nextInt(messages.length)];
  }

  // Show reminder bubble
  void _showReminderBubble() {
    setState(() {
      _showChatBubble = true;
      _currentBubbleType = ChatBubbleType.reminder;
      _currentMessage = _getRandomMessage(ChatBubbleType.reminder);
    });
  }

  // Show almost finished bubble
  void _showAlmostFinishedBubble() {
    setState(() {
      _showChatBubble = true;
      _currentBubbleType = ChatBubbleType.almostFinished;
      _currentMessage = _getRandomMessage(ChatBubbleType.almostFinished);
    });
  }

  // Show completion bubble with celebration
  void _showCelebrationBubble() {
    setState(() {
      _showChatBubble = true;
      _currentBubbleType = ChatBubbleType.completed;
      _currentMessage = _getRandomMessage(ChatBubbleType.completed);
    });
  }

  // Dismiss the current bubble
  void _dismissBubble() {
    setState(() {
      _showChatBubble = false;
    });
  }

  void showSliderPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Change Background',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20, width: double.infinity),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  GestureDetector(
                    key: const Key('bg-gym'),
                    onTap: () async {
                      setState(() {
                        backgroundImage = gymBackground;
                      });
                      await saveBackground(gymBackground);
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        gymBackground,
                        height: 90,
                        width: 90,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  GestureDetector(
                    key: const Key('bg-beach'),
                    onTap: () async {
                      setState(() {
                        backgroundImage = beachBackground;
                      });
                      await saveBackground(beachBackground);
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        beachBackground,
                        height: 90,
                        width: 90,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  GestureDetector(
                    key: const Key('bg-kitchen'),
                    onTap: () async {
                      setState(() {
                        backgroundImage = kitchenBackground;
                      });
                      await saveBackground(kitchenBackground);
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        kitchenBackground,
                        height: 90,
                        width: 90,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Pet and background section with integrated chat bubble
        Container(
          height: 350,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(90),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (backgroundImage != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(45),
                  child: Image.asset(
                    backgroundImage!,
                    height: 350,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

              // Chat bubble positioned at the top of the container
              if (_showChatBubble)
                Positioned(
                  top: 20,
                  left: 20,
                  right: 20,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: PetChatBubble(
                      message: _currentMessage,
                      type: _currentBubbleType,
                      showDismiss: true,
                      onDismiss: _dismissBubble,
                      autoDismissAfter: const Duration(seconds: 5),
                    ),
                  ),
                ),

              // Pet animation
              Positioned(
                bottom: 15,
                left: 0,
                right: 0,
                child: Lottie.asset(
                  widget.petImagePath,
                  height: 250,
                  width: 250,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 180,
                      width: 180,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(90),
                      ),
                      child: const Icon(
                        Icons.pets,
                        size: 80,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),

              // Background selector button
              Positioned(
                bottom: 16,
                right: 16,
                child: ElevatedButton(
                  key: const Key('open-modal-btn'),
                  onPressed: () {
                    showSliderPopup(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(45),
                    ),
                    backgroundColor: const Color(0xFFFF6B6B),
                  ),
                  child: const Icon(
                    Icons.collections,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFE893),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.petName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
// coverage-ignore:end