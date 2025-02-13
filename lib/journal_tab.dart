import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class JournalTab extends StatelessWidget {
  final Color primaryYellow = const Color(0xFFFFE893);
  final Color primaryPink = const Color(0xFFFF6B6B);
  final Color primaryGreen = const Color(0xFF4ECDC4);

  const JournalTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDailySummary(),
            const SizedBox(height: 24),
            
            _buildSectionTitle(
              'Today\'s Progress',
              action: TextButton.icon(
                onPressed: () {},
                icon: Icon(Icons.add, size: 20, color: primaryPink),
                label: Text(
                  'Add Note',
                  style: TextStyle(color: primaryPink),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildTodayStatusCard(),

            const SizedBox(height: 24),
            _buildSectionTitle('Recent Progress Notes'),
            const SizedBox(height: 12),
            _buildProgressNotesCard(),

            const SizedBox(height: 24),
            _buildSectionTitle('Monthly Review'),
            const SizedBox(height: 12),
            _buildMonthlyReviewCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildDailySummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryPink, primaryPink.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryPink.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Today\'s Summary',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Jan 28, 2025',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  label: 'Calories',
                  value: '1,850',
                  subtext: 'of 2,150',
                ),
              ),
              Container(height: 40, width: 1, color: Colors.white24),
              Expanded(
                child: _buildSummaryItem(
                  label: 'Exercise',
                  value: '45 min',
                  subtext: 'Morning Run',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, {Widget? action}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        if (action != null) action,
      ],
    );
  }

  Widget _buildSummaryItem({
    required String label,
    required String value,
    required String subtext,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          subtext,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTodayStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildStatusItem(
            icon: CupertinoIcons.check_mark_circled_solid,
            color: primaryGreen,
            title: 'Calorie Goal',
            subtitle: '1,850 / 2,150 kcal',
            isAchieved: true,
          ),
          const SizedBox(height: 12),
          _buildStatusItem(
            icon: CupertinoIcons.check_mark_circled_solid,
            color: primaryGreen,
            title: 'Protein Goal',
            subtitle: '125g / 120g',
            isAchieved: true,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryYellow.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(CupertinoIcons.doc_text,
                    color: Color(0xFFFFB946), size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Feeling energetic today! Morning run completed and eating well.',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressNotesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildProgressNoteItem(
            date: 'Today',
            note: 'Morning run felt great! Energy levels are improving.',
            tags: ['Exercise', 'Energy'],
            color: primaryGreen,
          ),
          const SizedBox(height: 16),
          _buildProgressNoteItem(
            date: 'Yesterday',
            note: 'Hit all macro goals. Protein intake is consistent.',
            tags: ['Nutrition', 'Goals'],
            color: primaryPink,
          ),
          const SizedBox(height: 16),
          _buildProgressNoteItem(
            date: '2 days ago',
            note: 'Rest day. Focused on stretching and recovery.',
            tags: ['Recovery', 'Wellness'],
            color: const Color(0xFFFFB946),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressNoteItem({
    required String date,
    required String note,
    required List<String> tags,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                date,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Spacer(),
            ...tags.map((tag) => Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 11,
                  ),
                ),
              ),
            )),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          note,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyReviewCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'January 2025',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'On Track',
                  style: TextStyle(
                    color: primaryGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildReviewItem(
            icon: Icons.trending_down,
            color: primaryGreen,
            title: 'Weight Progress',
            value: '-1.5 kg',
            subtitle: 'Consistent weekly loss',
          ),
          const SizedBox(height: 12),
          _buildReviewItem(
            icon: Icons.local_fire_department,
            color: primaryPink,
            title: 'Avg. Daily Calories',
            value: '2,150',
            subtitle: 'Within target range',
          ),
          const SizedBox(height: 12),
          _buildReviewItem(
            icon: Icons.fitness_center,
            color: const Color(0xFFFFB946),
            title: 'Exercise Sessions',
            value: '18/20',
            subtitle: 'Target sessions completed',
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required bool isAchieved,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isAchieved ? primaryGreen.withOpacity(0.1) : const Color(0xFFFFB946).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            isAchieved ? 'Achieved' : 'In Progress',
            style: TextStyle(
              color: isAchieved ? primaryGreen : const Color(0xFFFFB946),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewItem({
   required IconData icon,
   required Color color,
   required String title,
   required String value,
   required String subtitle,
 }) {
   return Row(
     children: [
       Container(
         padding: const EdgeInsets.all(8),
         decoration: BoxDecoration(
           color: color.withOpacity(0.1),
           borderRadius: BorderRadius.circular(8),
         ),
         child: Icon(
           icon,
           color: color,
           size: 16,
         ),
       ),
       const SizedBox(width: 12),
       Expanded(
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Text(
               title,
               style: const TextStyle(
                 fontSize: 14,
                 fontWeight: FontWeight.w500,
                 color: Colors.black87,
               ),
             ),
             Text(
               subtitle,
               style: const TextStyle(
                 color: Colors.black54,
                 fontSize: 12,
               ),
             ),
           ],
         ),
       ),
       Text(
         value,
         style: TextStyle(
           fontSize: 14,
           fontWeight: FontWeight.w600,
           color: color,
         ),
       ),
     ],
   );
 }
}