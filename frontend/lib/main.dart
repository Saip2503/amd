import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dio/dio.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'theme.dart';
import 'screens/dashboard_screen.dart';
import 'screens/meal_planner_screen.dart';
import 'screens/assistant_screen.dart';
import 'screens/library_screen.dart';
import 'screens/settings_screen.dart';

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

class NavigationIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void set(int val) => state = val;
}
final navigationIndexProvider = NotifierProvider<NavigationIndexNotifier, int>(NavigationIndexNotifier.new);

final apiProvider = Provider<Dio>((ref) {
  // Use compilation environment variable if provided, otherwise fallback to dotenv or localhost
  final compileTimeUrl = const String.fromEnvironment('API_URL');
  final String liveUrl = compileTimeUrl.isNotEmpty ? compileTimeUrl : (dotenv.env['API_BASE_URL'] ?? 'http://127.0.0.1:8000');
  
  return Dio(BaseOptions(
    baseUrl: liveUrl,
    connectTimeout: const Duration(seconds: 10),
  ));
});

// ─── Entry Point ─────────────────────────────────────────────────────────────
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/config.env");
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
          brightness: Brightness.light,
          surface: kBackground,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(),
      ),
      home: const MainScaffold(),
    );
  }
}

// ─── Main Scaffold (Navigation Shell) ────────────────────────────────────────
class MainScaffold extends ConsumerWidget {
  const MainScaffold({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationIndexProvider);

    final screens = [
      const DashboardScreen(),
      const MealPlannerScreen(),
      const AssistantScreen(),
      const LibraryScreen(),
      const SettingsScreen(),
    ];

    // Responsive layout: Bottom Nav for mobile, Rail for tablet/web
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: kBackground,
      body: Row(
        children: [
          if (isWide)
            NavigationRail(
              backgroundColor: kSurface,
              selectedIndex: currentIndex,
              onDestinationSelected: (idx) => ref.read(navigationIndexProvider.notifier).set(idx),
              destinations: const [
                NavigationRailDestination(icon: Icon(Icons.grid_view), label: Text('Home')),
                NavigationRailDestination(icon: Icon(Icons.restaurant_menu), label: Text('Planner')),
                NavigationRailDestination(icon: Icon(Icons.chat_bubble_outline), label: Text('Assistant')),
                NavigationRailDestination(icon: Icon(Icons.book_outlined), label: Text('Library')),
                NavigationRailDestination(icon: Icon(Icons.settings_outlined), label: Text('Settings')),
              ],
            ),
          if (isWide) const VerticalDivider(thickness: 1, width: 1, color: kSurfaceContainer),
          Expanded(child: screens[currentIndex]),
        ],
      ),
      bottomNavigationBar: isWide
          ? null
          : NavigationBar(
              backgroundColor: kSurface,
              indicatorColor: kSecondaryContainer,
              selectedIndex: currentIndex,
              onDestinationSelected: (idx) => ref.read(navigationIndexProvider.notifier).set(idx),
              destinations: const [
                NavigationDestination(icon: Icon(Icons.grid_view), label: 'Home'),
                NavigationDestination(icon: Icon(Icons.restaurant_menu), label: 'Planner'),
                NavigationDestination(icon: Icon(Icons.chat_bubble_outline), label: 'Assistant'),
                NavigationDestination(icon: Icon(Icons.book_outlined), label: 'Library'),
                NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Settings'),
              ],
            ),
       floatingActionButton: currentIndex != 2 ? FloatingActionButton.extended(
        backgroundColor: kPrimary,
        elevation: 0,
        onPressed: () {
            ref.read(navigationIndexProvider.notifier).set(2); // Jump to assistant
        },
        icon: const Icon(Icons.auto_awesome_rounded, color: kOnPrimary),
        label: Text(
          "I'm Hungry",
          style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: kOnPrimary, letterSpacing: 0.5),
        ),
      ) : null,
    );
  }
}
