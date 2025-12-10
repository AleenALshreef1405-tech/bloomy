import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class GardenView extends StatefulWidget {
  const GardenView({super.key});

  @override
  State<GardenView> createState() => _GardenViewState();
}

class _GardenViewState extends State<GardenView> {
  List<Map<String, dynamic>> flowers = [];

  @override
  void initState() {
    super.initState();
    _loadFlowers();
  }

  Future<void> _loadFlowers() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final data = await supabase
        .from('garden_flowers')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: true);

    setState(() {
      flowers = List<Map<String, dynamic>>.from(data);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
       Positioned.fill(
      child: Image.asset(
        'assets/images/garden_background.png',
        fit: BoxFit.cover, 
        alignment: Alignment.center,
        ),
      ),

          ...flowers.asMap().entries.map((entry) {
            final i = entry.key;
            final flower = entry.value;

            final top = 100.0 + (i * 80) % 300;
            final left = 50.0 + (i * 120) % 250;

            return Positioned(
              top: top,
              left: left,
              child: Image.asset(
                flower['image_path'],
                width: 80,
                height: 80,
              ),
            );
          }).toList(),

          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white, size: 28),
              onPressed: _loadFlowers,
            ),
          ),
        ],
      ),
    );
  }
}
