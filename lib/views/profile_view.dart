import 'package:bloomy/views/edit_profile_view.dart';
import 'package:bloomy/views/notifications_setting.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileView extends StatelessWidget {
  final VoidCallback onLogout;

  const ProfileView({
    super.key,
    required this.onLogout,
  });

  Future<Map<String, dynamic>?> _getUserData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return null;

    final response =
        await Supabase.instance.client
            .from('users')
            .select()
            .eq('id', user.id)
            .single();

    return response;
  }

  @override
  Widget build(BuildContext context) {
    const GreenColor = Color(0xFF064232);
    const backgroundColor = const Color(0xFFFFF5F2);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text('Failed to load user data.'));
          }

          final userData = snapshot.data!;
          final userName = userData['name'] ?? 'No Name';
          final userEmail = userData['email'] ?? 'No Email';

          return Column(
            children: [
              const SizedBox(height: 3),
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: backgroundColor,
                      border: Border.all(color: GreenColor, width: 4),
                    ),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: backgroundColor,
                      //color: GreenColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: GreenColor, width: 2),
                    ),
                    child: const Icon(
                      Icons.image_outlined,
                      size: 20,
                      color: GreenColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              Text(
                userName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: GreenColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                userEmail,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Color(0xFF558B7F),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Column(
                    children: [
                      ProfileItem(
                        icon: Icons.person_outline,
                        text: 'Edit Profile',
                        onTap:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EditProfileView(),
                              ),
                            ),
                      ),
                      const Divider(),
                      ProfileItem(
                        icon: Icons.notifications_none,
                        text: 'Notifications',
                        onTap:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const NotificationsSetting(),
                              ),
                            ),
                      ),
                      const Divider(),
                      ProfileItem(
                        icon: Icons.power_settings_new,
                        text: 'Logout',
                        onTap: onLogout,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ProfileItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onTap;

  const ProfileItem({
    super.key,
    required this.icon,
    required this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const GreenColor = Color(0xFF064232);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          children: [
            Icon(icon, color: GreenColor),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 16, color: GreenColor),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.black54,
            ),
          ],
        ),
      ),
    );
  }
}
