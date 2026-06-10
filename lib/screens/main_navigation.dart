import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/widgets/glass_widgets.dart';
import '../providers/task_provider.dart';
import 'dashboard_screen.dart';
import 'calendar_screen.dart';
import 'focus_mode_screen.dart';
import 'analytics_screen.dart';
import 'settings_screen.dart';
import 'auth_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const CalendarScreen(),
    const FocusModeScreen(),
    const AnalyticsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context);

    if (!provider.isAuthenticated) {
      return const AuthScreen();
    }

    if (provider.isLoading && provider.tasks.isEmpty && provider.agendaEvents.isEmpty) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: NovaTheme.primary,
          ),
        ),
      );
    }

    return Scaffold(
      extendBody: true, // Allow screens to scroll behind the translucent navigation bar
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 24,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: GlassPanel(
          radius: 16,
          blur: 24.0,
          opacity: 0.1,
          padding: EdgeInsets.zero,
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 72,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(Icons.home_rounded, 0),
                  _buildNavItem(Icons.calendar_month_rounded, 1),
                  _buildNavItem(Icons.timer_rounded, 2),
                  _buildNavItem(Icons.analytics_rounded, 3),
                  _buildNavItem(Icons.settings_rounded, 4),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final isActive = _currentIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 60,
        height: 60,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? NovaTheme.primary : NovaTheme.onSurfaceVariant.withValues(alpha: 0.6),
              size: 26,
            ),
            const SizedBox(height: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isActive ? 4 : 0,
              height: isActive ? 4 : 0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: NovaTheme.primary,
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: NovaTheme.primary.withValues(alpha: 0.8),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
