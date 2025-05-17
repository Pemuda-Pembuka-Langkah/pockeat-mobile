import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PricingOption extends StatelessWidget {
  final String title;
  final int price;
  final String? discount;
  final bool isSelected;
  final Color primaryGreen;
  final Color textDarkColor;
  final Color textLightColor;

  const PricingOption({
    super.key,
    required this.title,
    required this.price,
    this.discount,
    required this.isSelected,
    required this.primaryGreen,
    required this.textDarkColor,
    required this.textLightColor,
  });

  @override
  Widget build(BuildContext context) {
    // Format price with thousand separator
    final formatter = NumberFormat('#,###', 'id_ID');
    final formattedPrice = formatter.format(price);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? primaryGreen.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? primaryGreen : Colors.grey.shade200,
          width: 2,
        ),
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: primaryGreen.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 3),
            )
          else
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Container(
        // Fixed height to ensure consistent sizing
        height: 120,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Always reserve space for the POPULAR label
            Container(
              height: 26, // Fixed height for the label area
              child: isSelected
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: primaryGreen,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'POPULAR',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  )
                : Container(), // Empty container to reserve space
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textDarkColor,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Rp ',
                  style: TextStyle(
                    fontSize: 14,
                    color: textLightColor,
                  ),
                ),
                Text(
                  formattedPrice,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? primaryGreen : textDarkColor,
                  ),
                ),
              ],
            ),
            // Always reserve space for the discount tag
            Container(
              height: 24, // Fixed height for the discount area
              child: discount != null
                ? Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: primaryGreen.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Save $discount',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: primaryGreen,
                        ),
                      ),
                    ),
                  )
                : Container(), // Empty container to reserve space
            ),
          ],
        ),
      ),
    );
  }
}
