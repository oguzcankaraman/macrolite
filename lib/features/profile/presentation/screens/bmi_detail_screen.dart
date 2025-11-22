import 'package:flutter/material.dart';
import 'package:macrolite/core/domain/user_profile.dart';

class BmiDetailScreen extends StatelessWidget {
  const BmiDetailScreen({super.key, required this.profile});

  final UserProfile profile;

  Color _getBmiColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  String _getBmiInterpretation(double bmi) {
    if (bmi < 18.5) {
      return 'You may need to gain some weight. Consider consulting with a healthcare provider.';
    } else if (bmi < 25) {
      return 'Great! You\'re in the healthy weight range. Keep up your current lifestyle.';
    } else if (bmi < 30) {
      return 'Consider adopting healthier habits to reach a healthier weight range.';
    } else {
      return 'It\'s recommended to consult with a healthcare provider for personalized advice.';
    }
  }

  (double min, double max) _getHealthyWeightRange(double heightInCm) {
    final heightInM = heightInCm / 100;
    final minWeight = 18.5 * (heightInM * heightInM);
    final maxWeight = 24.9 * (heightInM * heightInM);
    return (minWeight, maxWeight);
  }

  @override
  Widget build(BuildContext context) {
    final bmi = profile.bmi;
    final category = profile.bmiCategory;
    final color = _getBmiColor(bmi);
    final interpretation = _getBmiInterpretation(bmi);
    final (minWeight, maxWeight) = _getHealthyWeightRange(profile.height);

    return Scaffold(
      appBar: AppBar(title: const Text('BMI Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Hero(
          tag: 'bmi_card',
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Body Mass Index',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            category,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: color,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Center(
                      child: Column(
                        children: [
                          Text(
                            bmi.toStringAsFixed(1),
                            style: Theme.of(context).textTheme.displayLarge
                                ?.copyWith(
                                  fontSize: 72,
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'kg/m²',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      'Healthy Weight Range',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${minWeight.toStringAsFixed(1)} - ${maxWeight.toStringAsFixed(1)} kg',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontSize: 20,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Interpretation',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      interpretation,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildRangeIndicator(
                      context,
                      'Underweight',
                      bmi < 18.5,
                      Colors.blue,
                    ),
                    _buildRangeIndicator(
                      context,
                      'Normal',
                      bmi >= 18.5 && bmi < 25,
                      Colors.green,
                    ),
                    _buildRangeIndicator(
                      context,
                      'Overweight',
                      bmi >= 25 && bmi < 30,
                      Colors.orange,
                    ),
                    _buildRangeIndicator(
                      context,
                      'Obese',
                      bmi >= 30,
                      Colors.red,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRangeIndicator(
    BuildContext context,
    String label,
    bool isActive,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: isActive ? color : Colors.grey[300],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 16,
              color: isActive ? color : Colors.grey,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (isActive) ...[const Spacer(), Icon(Icons.check, color: color)],
        ],
      ),
    );
  }
}
