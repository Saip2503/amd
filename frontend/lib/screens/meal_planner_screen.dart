import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../providers.dart';

class MealPlannerScreen extends ConsumerWidget {
  const MealPlannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plannerState = ref.watch(plannerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
          child: Text('Weekly Planner', style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.bold, color: kOnSurface)),
        ),
        Expanded(
          child: plannerState.when(
            data: (plan) => ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: plan.length,
              itemBuilder: (context, index) {
                final dayPlan = plan[index];
                return _DayCard(dayPlan: dayPlan);
              },
            ),
            loading: () => const Center(child: CircularProgressIndicator(color: kPrimary)),
            error: (err, stack) => Center(child: Text("Failed to generate plan: Wait for FastAPI backend to connect.", style: GoogleFonts.inter(color: Colors.red))),
          )
        )
      ],
    );
  }
}

class _DayCard extends StatelessWidget {
  final Map<String, dynamic> dayPlan;
  const _DayCard({required this.dayPlan});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(dayPlan['day'] ?? 'Unknown Day', style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 18, color: kPrimary)),
          const SizedBox(height: 16),
          _MealRow("Breakfast", dayPlan['breakfast'] ?? "-"),
          const SizedBox(height: 12),
          _MealRow("Lunch", dayPlan['lunch'] ?? "-"),
          const SizedBox(height: 12),
          _MealRow("Dinner", dayPlan['dinner'] ?? "-"),
        ],
      )
    );
  }
}

class _MealRow extends StatelessWidget {
  final String title;
  final String meal;
  const _MealRow(this.title, this.meal);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 85, child: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: kOnSurfaceVariant, fontSize: 13))),
        Expanded(child: Text(meal, style: GoogleFonts.inter(color: kOnSurface, fontSize: 14, height: 1.4))),
      ],
    );
  }
}
