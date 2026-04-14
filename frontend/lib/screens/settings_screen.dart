import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 12),
        Text('Preferences', style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.bold, color: kOnSurface)),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(20)),
          child: Column(
            children: [
              ListTile(
                title: Text("Diet Preference", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                trailing: DropdownButton<String>(
                  value: settings['diet'],
                  underline: const SizedBox(),
                  items: ["Standard", "Vegan", "Keto", "Paleo"].map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                  onChanged: (val) => ref.read(settingsProvider.notifier).updatePreferences(val, null),
                ),
              ),
              const Divider(),
              SwitchListTile(
                title: Text("Smart Notifications", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                activeColor: kPrimary,
                value: settings['notifications'] ?? true,
                onChanged: (val) => ref.read(settingsProvider.notifier).updatePreferences(null, val),
              ),
            ],
          ),
        )
      ],
    );
  }
}
