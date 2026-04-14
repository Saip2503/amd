import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Nutri-Flow', style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w800, color: kOnSurface)),
                CircleAvatar(backgroundColor: kSurfaceContainer, radius: 20, child: const Icon(Icons.person_outline, color: kOnSurfaceVariant, size: 20)),
              ],
            ),
            const SizedBox(height: 36),
            Text('DAILY FLOW', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: kOnSurfaceVariant, letterSpacing: 2.0)),
            const SizedBox(height: 12),
            Text('Good morning,\nAlex.', style: GoogleFonts.manrope(fontSize: 40, fontWeight: FontWeight.w800, height: 1.05, color: kOnSurface)),
            const SizedBox(height: 12),
            Text('Your metabolism is in peak state today. Let\'s fuel it right.', style: GoogleFonts.inter(fontSize: 16, height: 1.6, color: kOnSurfaceVariant)),
            const SizedBox(height: 40),
            const _InsightCard(),
            const SizedBox(height: 40),
            Text('Recent Activity', style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w800, color: kOnSurface)),
            const SizedBox(height: 20),
            const _ActivityRow(title: 'Quinoa Power Bowl', subtitle: 'Lunch • 1:20 PM', calories: '450 kcal', icon: Icons.rice_bowl_outlined),
            Container(height: 1, color: kSurfaceContainer),
            const _ActivityRow(title: 'Green Detox Smoothie', subtitle: 'Snack • 10:45 AM', calories: '180 kcal', icon: Icons.local_drink_outlined),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [BoxShadow(color: Color(0x0A2C2F2E), blurRadius: 48, offset: Offset(0, 16))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: kSurfaceContainer, borderRadius: BorderRadius.circular(999)),
            child: Text('Active Clarity', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: kPrimary, letterSpacing: 0.5)),
          ),
          const SizedBox(height: 20),
          Text('650 kcal', style: GoogleFonts.manrope(fontSize: 52, fontWeight: FontWeight.w800, color: kOnSurface, height: 1.0, letterSpacing: -1.5)),
          const SizedBox(height: 4),
          Text('remaining for dinner', style: GoogleFonts.inter(fontSize: 16, color: kOnSurfaceVariant)),
          const SizedBox(height: 28),
          Container(height: 1, color: kSurfaceContainer),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFFD4F9FF), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.tips_and_updates_outlined, color: kTertiary, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Focus on Fiber', style: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w700, color: kOnSurface)),
                    const SizedBox(height: 4),
                    Text('Your data suggests increasing fiber by 8g during dinner to stabilize your evening glucose levels.', style: GoogleFonts.inter(fontSize: 13, height: 1.6, color: kOnSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final String calories;
  final IconData icon;

  const _ActivityRow({required this.title, required this.subtitle, required this.calories, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(color: kSurfaceContainer, borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: kOnSurfaceVariant, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15, color: kOnSurface)),
                const SizedBox(height: 2),
                Text(subtitle, style: GoogleFonts.inter(fontSize: 13, color: kOnSurfaceVariant)),
              ],
            ),
          ),
          Text(calories, style: GoogleFonts.manrope(fontWeight: FontWeight.w700, fontSize: 15, color: kOnSurface)),
        ],
      ),
    );
  }
}
