import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme.dart';
import '../core/widgets/glass_widgets.dart';
import '../core/widgets/neon_button.dart';
import '../providers/task_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _soundEffects = true;
  double _glassOpacity = 0.05;
  double _backdropBlur = 16.0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _pushNotifications = prefs.getBool('setting_push') ?? true;
      _soundEffects = prefs.getBool('setting_sound') ?? true;
      _glassOpacity = prefs.getDouble('setting_opacity') ?? 0.05;
      _backdropBlur = prefs.getDouble('setting_blur') ?? 16.0;
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context);
    final email = provider.currentUser?.email ?? 'guest@nova.com';
    final displayName = provider.displayName;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: NovaTheme.timeAmbientGradient,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Customize your focus space',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 100),
                      child: Column(
                        children: [
                          // Profile section Card
                          GlassPanel(
                            radius: 16,
                            padding: const EdgeInsets.all(18),
                            child: Row(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: NovaTheme.primary,
                                      width: 2.0,
                                    ),
                                  ),
                                  child: ClipOval(
                                    child: Container(
                                      color: NovaTheme.primary.withValues(alpha: 0.2),
                                      child: Center(
                                        child: Text(
                                          displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: NovaTheme.primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        displayName,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        email,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white.withValues(alpha: 0.4),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: NovaTheme.primary.withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: const Text(
                                              'Level 8',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: NovaTheme.primary,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Focus Master',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.white.withValues(alpha: 0.5),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Customization Header
                          _buildSectionHeader('Appearance'),
                          const SizedBox(height: 12),

                          // Glass opacity slider
                          GlassPanel(
                            radius: 16,
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Glass Opacity',
                                      style: TextStyle(fontSize: 14, color: Colors.white),
                                    ),
                                    Text(
                                      '${(_glassOpacity * 100).toInt()}%',
                                      style: const TextStyle(fontSize: 13, color: NovaTheme.primary, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Slider(
                                  value: _glassOpacity,
                                  min: 0.01,
                                  max: 0.2,
                                  activeColor: NovaTheme.primary,
                                  inactiveColor: Colors.white12,
                                  onChanged: (val) {
                                    setState(() {
                                      _glassOpacity = val;
                                    });
                                    _saveSetting('setting_opacity', val);
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Backdrop blur slider
                          GlassPanel(
                            radius: 16,
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Backdrop Blur',
                                      style: TextStyle(fontSize: 14, color: Colors.white),
                                    ),
                                    Text(
                                      '${_backdropBlur.toInt()}px',
                                      style: const TextStyle(fontSize: 13, color: NovaTheme.secondary, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Slider(
                                  value: _backdropBlur,
                                  min: 4.0,
                                  max: 40.0,
                                  activeColor: NovaTheme.secondary,
                                  inactiveColor: Colors.white12,
                                  onChanged: (val) {
                                    setState(() {
                                      _backdropBlur = val;
                                    });
                                    _saveSetting('setting_blur', val);
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Preferences Header
                          _buildSectionHeader('Preferences'),
                          const SizedBox(height: 12),

                          // Toggle cards
                          GlassPanel(
                            radius: 16,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Column(
                              children: [
                                SwitchListTile(
                                  title: const Text('Push Notifications', style: TextStyle(fontSize: 14, color: Colors.white)),
                                  value: _pushNotifications,
                                  activeColor: NovaTheme.primary,
                                  contentPadding: EdgeInsets.zero,
                                  onChanged: (val) {
                                    setState(() {
                                      _pushNotifications = val;
                                    });
                                    _saveSetting('setting_push', val);
                                  },
                                ),
                                const Divider(color: Colors.white10, height: 1),
                                SwitchListTile(
                                  title: const Text('Timer Sound Effects', style: TextStyle(fontSize: 14, color: Colors.white)),
                                  value: _soundEffects,
                                  activeColor: NovaTheme.primary,
                                  contentPadding: EdgeInsets.zero,
                                  onChanged: (val) {
                                    setState(() {
                                      _soundEffects = val;
                                    });
                                    _saveSetting('setting_sound', val);
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildSectionHeader('Account'),
                          const SizedBox(height: 12),
                          GlassPanel(
                            radius: 16,
                            padding: EdgeInsets.zero,
                            child: Column(
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.edit_rounded, color: NovaTheme.primary),
                                  title: const Text(
                                    'Edit Username',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white24),
                                  onTap: () {
                                    _showEditNameDialog(context, provider);
                                  },
                                ),
                                const Divider(color: Colors.white10, height: 1),
                                ListTile(
                                  leading: const Icon(Icons.logout_rounded, color: NovaTheme.error),
                                  title: const Text(
                                    'Sign Out',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: NovaTheme.error,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white24),
                                  onTap: () {
                                    provider.signOut();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white.withValues(alpha: 0.4),
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  void _showEditNameDialog(BuildContext context, TaskProvider provider) {
    final controller = TextEditingController(text: provider.displayName);
    bool isFocused = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: GlassPanel(
                radius: 20,
                blur: 32.0,
                opacity: 0.15,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Edit Username',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Focus(
                      onFocusChange: (focused) {
                        setDialogState(() {
                          isFocused = focused;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: NovaTheme.surfaceLowest,
                          borderRadius: BorderRadius.circular(12),
                          border: Border(
                            bottom: BorderSide(
                              color: isFocused ? NovaTheme.primary : Colors.white10,
                              width: isFocused ? 2.0 : 1.0,
                            ),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: TextField(
                          controller: controller,
                          autofocus: true,
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Enter username',
                            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        NeonButton(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          buttonColor: NovaTheme.surfaceHigh,
                          glowColor: Colors.transparent,
                          radius: 12,
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        ),
                        const SizedBox(width: 12),
                        NeonButton(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          buttonColor: NovaTheme.primary,
                          glowColor: NovaTheme.primary,
                          radius: 12,
                          onPressed: () async {
                            final name = controller.text.trim();
                            if (name.isNotEmpty) {
                              await provider.updateDisplayName(name);
                              if (context.mounted) Navigator.of(context).pop();
                            }
                          },
                          child: const Text(
                            'Save',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
