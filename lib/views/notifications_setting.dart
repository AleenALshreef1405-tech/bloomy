import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationsSetting extends StatefulWidget {
  const NotificationsSetting({super.key});

  @override
  State<NotificationsSetting> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsSetting> {
  final supabase = Supabase.instance.client;
  final user = Supabase.instance.client.auth.currentUser;

  final List<String> settingKeys = [
    'Special Offers',
    'Sound',
    'Vibrate',
    'General Notification',
    'Promo & Discount',
    'Payment Options',
    'App Update',
    'New Service Available',
    'New Tips Available',
  ];

  Map<String, bool> _switchValues = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    if (user == null) {
      debugPrint('User not logged in.');
      return;
    }

    try {
      final response = await supabase
          .from('notification_settings')
          .select('setting_name, is_enabled')
          .eq('user_id', user!.id);

      final List data = response as List;

      Map<String, bool> loaded = {
        for (var key in settingKeys) key: true,
      };

      for (var item in data) {
        loaded[item['setting_name']] = item['is_enabled'] as bool;
      }

      setState(() {
        _switchValues = loaded;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _updateSetting(String key, bool value) async {
    setState(() {
      _switchValues[key] = value;
    });

    try {
      await supabase.from('notification_settings').upsert({
        'user_id': user!.id,
        'setting_name': key,
        'is_enabled': value,
      }, onConflict: 'user_id,setting_name');
    } catch (e) {
      debugPrint('Error updating setting: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    const backgroundcolor = Color(0xFFFFF5F2);
    const greenColor = Color(0xFF064232);

    return Scaffold(
      backgroundColor: backgroundcolor,
      appBar: AppBar(
        backgroundColor: backgroundcolor,
        elevation: 0,
        leading: const BackButton(color: greenColor),
        title: const Text(
          'Notifications',
          style: TextStyle(color: greenColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(24),
              children: _switchValues.entries.map((entry) {
                return SwitchListTile(
                  title: Text(
                    entry.key,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                    value: entry.value,
                    onChanged: (val) => _updateSetting(entry.key, val),
                    activeColor: greenColor,
                );
              }).toList(),
            ),
    );
  }
}
