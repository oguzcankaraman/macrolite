import 'package:flutter/material.dart';
import 'package:macrolite/features/profile/presentation/widgets/history_chart.dart';
import 'package:macrolite/features/profile/presentation/widgets/profile_settings_section.dart';
import 'package:macrolite/features/profile/presentation/widgets/bmi_card.dart';
import 'package:macrolite/features/profile/presentation/widgets/macro_distribution_chart.dart';
import 'package:macrolite/features/profile/presentation/widgets/calorie_trend_chart.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: const [
            HistoryChart(),
            BmiCard(),
            MacroDistributionChart(),
            CalorieTrendChart(),
            Divider(),
            ProfileSettingsSection(),
          ],
        ),
      ),
    );
  }
}
