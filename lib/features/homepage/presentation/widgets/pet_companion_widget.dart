// lib/features/homepage/presentation/widgets/pet_companion_widget.dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_it/get_it.dart';

class PetCompanionWidget extends StatefulWidget {
  final String petName;
  final String petImagePath;

  const PetCompanionWidget({
    super.key,
    this.petName = 'Panda',
    this.petImagePath = 'assets/images/panda_sad.json',
  });

  @override
  State<PetCompanionWidget> createState() => _PetCompanionWidgetState();
}

class _PetCompanionWidgetState extends State<PetCompanionWidget> {
  String? backgroundImage = '';
  String beachBackground = 'assets/images/beach.jpg';
  String gymBackground = 'assets/images/gym.jpg';
  String kitchenBackground = 'assets/images/kitchen.jpg';

  @override
  void initState() {
    super.initState();
    loadBackground();
  }

  Future<void> loadBackground() async {
    final prefs = GetIt.instance<SharedPreferences>();
    setState(() {
      backgroundImage = prefs.getString('backgroundImage') ?? gymBackground;
    });
  }

  Future<void> saveBackground(String? path) async {
    final prefs = await SharedPreferences.getInstance();
    if (path != null) {
      await prefs.setString('backgroundImage', path);
    } else {
      await prefs.remove('backgroundImage');
    }
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
