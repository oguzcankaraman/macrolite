import 'package:flutter/material.dart';
import 'package:macrolite/features/profile/presentation/widgets/history_chart.dart';
import 'package:macrolite/features/profile/presentation/widgets/profile_settings_section.dart';
import 'package:macrolite/features/profile/presentation/widgets/bmi_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        children:
            [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Last 7 Days',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              HistoryChart(),
              BmiCard(),
              Divider(),
            ] +
            [const ProfileSettingsSection()],
      ),
    );
  }
}
