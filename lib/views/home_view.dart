import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'notifications_view.dart';

final supabase = Supabase.instance.client;

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  String userName = "";

  final List<Map<String, String>> feelings = [
    {"title": "Happiness", "image": "assets/images/happiness.png"},
    {"title": "Gratitude", "image": "assets/images/gratitude.png"},
    {"title": "Calm", "image": "assets/images/calm.png"},
    {"title": "Excitement", "image": "assets/images/excitement.png"},
    {"title": "Sadness", "image": "assets/images/sadness.png"},
    {"title": "Anxiety", "image": "assets/images/anxiety.png"},
  ];

  @override
  void initState() {
    super.initState();
    _loadUser();
    _sendWelcomeNotification();
  }

  Future<void> _loadUser() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final response = await supabase
          .from('users')
          .select('name')
          .eq('id', user.id)
          .maybeSingle();

      setState(() {
        userName = response?['name'] ?? 'Bloomy Friend';
      });
    } catch (e) {
      debugPrint('Error loading user name: $e');
    }
  }

  Future<void> _sendWelcomeNotification() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final existing = await supabase
        .from('notifications')
        .select()
        .eq('user_id', user.id)
        .eq('title', 'Welcome to Bloomy!')
        .maybeSingle();

    if (existing == null) {
      await supabase.from('notifications').insert({
        'user_id': user.id,
        'title': 'Welcome to Bloomy!',
        'body': 'We’re happy to see you here, $userName!',
      });
    }
  }

  Future<void> _addFlowerToGarden(String flowerName, String imagePath) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    await supabase.from('garden_flowers').insert({
      'user_id': user.id,
      'flower_name': flowerName,
      'image_path': imagePath,
    });
  }

  Future<void> _addFlowerNotification(String flowerName) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    await supabase.from('notifications').insert({
      'user_id': user.id,
      'title': 'New Flower Added!',
      'body': 'You added the flower: $flowerName',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F2),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hi, $userName!",
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF064232),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "How do you feel today?",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),

                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationsView(),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF064232),
                          width: 1.5,
                        ),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.notifications_none,
                        color: Color(0xFF064232),
                        size: 26,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Expanded(
                child: GridView.builder(
                  itemCount: feelings.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    final item = feelings[index];
                    return GestureDetector(
                      onTap: () async {
                        await _addFlowerToGarden(
                            item["title"]!, item["image"]!);
                        await _addFlowerNotification(item["title"]!);

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "${item["title"]} added to your garden.",
                              ),
                              backgroundColor: const Color(0xFF064232),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF558B7F),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF064232),
                            width: 3,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 110,
                              width: 110,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFF5F2),
                                shape: BoxShape.circle,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Image.asset(item["image"]!),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              item["title"]!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
