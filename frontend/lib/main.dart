import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dio/dio.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// ─── Design Tokens (Living Canvas) ─────────────────────────────────────────
const kBackground = Color(0xFFF5F7F5);
const kSurface = Color(0xFFFFFFFF);
const kSurfaceContainer = Color(0xFFE6E9E7);
const kOnSurface = Color(0xFF2C2F2E);
const kOnSurfaceVariant = Color(0xFF595C5B);
const kPrimary = Color(0xFF006B1B);
const kPrimaryDim = Color(0xFF005D16);
const kOnPrimary = Color(0xFFD1FFC8);
const kSecondaryContainer = Color(0xFF86FAAC);
const kTertiary = Color(0xFF00656F);

// ─── State Providers ────────────────────────────────────────────────────────
class RecommendationNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void set(String? val) => state = val;
}
final recommendationProvider = NotifierProvider<RecommendationNotifier, String?>(RecommendationNotifier.new);

class IsLoadingNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void set(bool val) => state = val;
}
final isLoadingProvider = NotifierProvider<IsLoadingNotifier, bool>(IsLoadingNotifier.new);

final apiProvider = Provider<Dio>((ref) => Dio(BaseOptions(
      baseUrl: dotenv.env['API_BASE_URL'] ?? 'http://127.0.0.1:8000',
      connectTimeout: const Duration(seconds: 10),
    )));

// ─── Entry Point ─────────────────────────────────────────────────────────────
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Hive.initFlutter();
  await Hive.openBox('settings');
  runApp(const ProviderScope(child: NutriflowApp()));
}


// ─── App Root ────────────────────────────────────────────────────────────────
class NutriflowApp extends StatelessWidget {
  const NutriflowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nutri-Flow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: kPrimary,
          brightness: Brightness.light, // ✅ Fix: lowercase
          surface: kBackground,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(), // ✅ Fix: load Inter via google_fonts
      ),
      home: const DashboardScreen(),
    );
  }
}

// ─── Dashboard Screen ────────────────────────────────────────────────────────
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendation = ref.watch(recommendationProvider);
    final isLoading = ref.watch(isLoadingProvider);

    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── App Bar Row ──────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Nutri-Flow',
                    style: GoogleFonts.manrope(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: kOnSurface,
                    ),
                  ),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: kSurfaceContainer,
                    child: const Icon(Icons.person_outline, color: kOnSurfaceVariant, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 36),

              // ── Section Label ────────────────────────────────────────────
              Text(
                'DAILY FLOW',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: kOnSurfaceVariant,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 12),

              // ── Greeting ─────────────────────────────────────────────────
              Text(
                'Good morning,\nAlex.',
                style: GoogleFonts.manrope(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  height: 1.05,
                  color: kOnSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your metabolism is in peak state today. Let\'s fuel it right.',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  height: 1.6,
                  color: kOnSurfaceVariant,
                ),
              ),
              const SizedBox(height: 40),

              // ── Primary Insight Card ─────────────────────────────────────
              _InsightCard(),
              const SizedBox(height: 40),

              // ── AI Recommendation Result ─────────────────────────────────
              if (isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 32.0),
                    child: CircularProgressIndicator(color: kPrimary),
                  ),
                )
              else if (recommendation != null) ...[
                _AIResultCard(text: recommendation),
                const SizedBox(height: 40),
              ],

              // ── Recent Activity ──────────────────────────────────────────
              Text(
                'Recent Activity',
                style: GoogleFonts.manrope(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: kOnSurface,
                ),
              ),
              const SizedBox(height: 20),
              _ActivityRow(
                title: 'Quinoa Power Bowl',
                subtitle: 'Lunch • 1:20 PM',
                calories: '450 kcal',
                icon: Icons.rice_bowl_outlined,
              ),
              _Divider(),
              _ActivityRow(
                title: 'Green Detox Smoothie',
                subtitle: 'Snack • 10:45 AM',
                calories: '180 kcal',
                icon: Icons.local_drink_outlined,
              ),
              const SizedBox(height: 80), // FAB clearance
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: kPrimary,
        elevation: 0,
        onPressed: () async {
          ref.read(isLoadingProvider.notifier).set(true);
          ref.read(recommendationProvider.notifier).set(null);
          try {
            final dio = ref.read(apiProvider);
            final response = await dio.post('/ask', data: {
              "step_count": 8432,
              "latitude": 37.7749,
              "longitude": -122.4194,
              "user_prompt": "What should I eat for dinner based on my fiber gap?"
            });
            if (response.statusCode == 200) {
              ref.read(recommendationProvider.notifier).set(
                  response.data['data']['recommendation'] as String);
            }
          } catch (e) {
            ref.read(recommendationProvider.notifier).set(
                "Unable to connect to AI Core. Please check your FastAPI backend.");
          } finally {
            ref.read(isLoadingProvider.notifier).set(false);
          }
        },
        icon: const Icon(Icons.auto_awesome_rounded, color: kOnPrimary),
        label: Text(
          'Ask AI',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: kOnPrimary,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

// ─── Sub-Widgets ─────────────────────────────────────────────────────────────

class _InsightCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A2C2F2E), // 4% ambient — no black
            blurRadius: 48,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tag chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: kSurfaceContainer,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Active Clarity',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: kPrimary,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Caloric display
          Text(
            '650 kcal',
            style: GoogleFonts.manrope(
              fontSize: 52,
              fontWeight: FontWeight.w800,
              color: kOnSurface,
              height: 1.0,
              letterSpacing: -1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'remaining for dinner',
            style: GoogleFonts.inter(fontSize: 16, color: kOnSurfaceVariant),
          ),
          const SizedBox(height: 28),

          // Insight divider (tonal, no line)
          Container(height: 1, color: kSurfaceContainer),
          const SizedBox(height: 20),

          // AI Insight
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4F9FF), // tertiary container tint
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.tips_and_updates_outlined, color: kTertiary, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Focus on Fiber',
                      style: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w700, color: kOnSurface),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Your data suggests increasing fiber by 8g during dinner to stabilize your evening glucose levels.',
                      style: GoogleFonts.inter(fontSize: 13, height: 1.6, color: kOnSurfaceVariant),
                    ),
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

class _AIResultCard extends StatelessWidget {
  final String text;
  const _AIResultCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        // ✅ Fix: use Color.fromRGBO instead of deprecated withOpacity
        color: Color.fromRGBO(230, 233, 231, 0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF78EB9E), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, color: kPrimary, size: 18),
              const SizedBox(width: 8),
              Text(
                'AI Recommendation',
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: kPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            text,
            style: GoogleFonts.inter(fontSize: 15, height: 1.7, color: kOnSurface),
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

  const _ActivityRow({
    required this.title,
    required this.subtitle,
    required this.calories,
    required this.icon,
  });

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
            decoration: BoxDecoration(
              color: kSurfaceContainer,
              borderRadius: BorderRadius.circular(16),
            ),
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
          Text(
            calories,
            style: GoogleFonts.manrope(fontWeight: FontWeight.w700, fontSize: 15, color: kOnSurface),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // ✅ "No-Line" rule — use tonal background shift instead of a full divider
    return Container(height: 1, color: kSurfaceContainer);
  }
}
