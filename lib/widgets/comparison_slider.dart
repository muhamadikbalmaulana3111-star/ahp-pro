import 'package:flutter/material.dart';
import '../models/ahp_model.dart';

class ComparisonSlider extends StatelessWidget {
  final PairwiseComparison comparison;
  final ValueChanged<double> onChanged;

  const ComparisonSlider({
    super.key,
    required this.comparison,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Current value indicator
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Text(
                comparison.direction == 'Sama'
                    ? 'Kedua item sama penting'
                    : '${comparison.direction} lebih penting',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                comparison.label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Slider
        Row(
          children: [
            // Left label
            Expanded(
              child: Text(
                comparison.item2,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: comparison.value < 1 ? FontWeight.bold : FontWeight.normal,
                  color: comparison.value < 1
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                ),
                textAlign: TextAlign.left,
              ),
            ),
            const SizedBox(width: 8),
            // Right label
            Expanded(
              child: Text(
                comparison.item1,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: comparison.value > 1 ? FontWeight.bold : FontWeight.normal,
                  color: comparison.value > 1
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Slider with scale markers
        Stack(
          alignment: Alignment.center,
          children: [
            // Scale markers
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (int i = 9; i >= 1; i--)
                  Container(
                    width: 2,
                    height: (i == 1 || i == 9) ? 20 : (i % 2 == 1 ? 15 : 10),
                    color: Colors.grey[300],
                  ),
                for (int i = 2; i <= 9; i++)
                  Container(
                    width: 2,
                    height: (i == 1 || i == 9) ? 20 : (i % 2 == 1 ? 15 : 10),
                    color: Colors.grey[300],
                  ),
              ],
            ),
            
            // Actual slider
            Slider(
              value: _scaleToSliderValue(comparison.value),
              min: -9,
              max: 9,
              divisions: 16, // 9 left + 1 center + 9 right = 17 positions, but -9 to 9 = 18
              label: _getSliderLabel(comparison.value),
              onChanged: (sliderValue) {
                onChanged(_sliderValueToScale(sliderValue));
              },
              activeColor: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),

        // Scale labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '9',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            Text(
              '1',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            Text(
              '9',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Convert AHP scale (1/9 to 9) to slider value (-9 to 9)
  double _scaleToSliderValue(double scale) {
    if (scale >= 1) {
      return scale; // 1 to 9
    } else {
      return -1 / scale; // 1/9 to 1/2 becomes -9 to -2
    }
  }

  /// Convert slider value (-9 to 9) to AHP scale (1/9 to 9)
  double _sliderValueToScale(double sliderValue) {
    if (sliderValue >= 1) {
      return sliderValue; // 1 to 9
    } else if (sliderValue <= -1) {
      return 1 / (-sliderValue); // -9 to -2 becomes 1/9 to 1/2
    } else {
      return 1.0; // Center position
    }
  }

  String _getSliderLabel(double scale) {
    if (scale == 1) return '1 (Sama)';
    if (scale > 1) {
      return scale.toStringAsFixed(0);
    } else {
      return '1/${(1 / scale).toStringAsFixed(0)}';
    }
  }
}
