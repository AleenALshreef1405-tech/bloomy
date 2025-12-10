import 'package:bloomy/views/OTP.dart';
import 'package:bloomy/views/login_view.dart';
import 'package:bloomy/widgets/CustomActionButton.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class CreateAccView extends StatefulWidget {
  const CreateAccView({super.key});

  @override
  State<CreateAccView> createState() => _CreateAccViewState();
}

class _CreateAccViewState extends State<CreateAccView> {
  bool _isLoading = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  Future<void> sendOtp() async {
    setState(() => _isLoading = true);

    final name = nameController.text.trim();
    final email = emailController.text.trim();

    try {
      await supabase.auth.signInWithOtp(email: email);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OTP sent to $email')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => VerifyOtp(email: email, name: name)),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending OTP: $error')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F2),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  'assets/images/login.png',
                  height: 180,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Sign Up',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF064232),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Create an account to continue',
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 32),

              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.person, color: Color(0xFF064232)),
                  hintText: 'Name',
                  border: UnderlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.email, color: Color(0xFF064232)),
                  hintText: 'Email',
                  border: UnderlineInputBorder(),
                ),
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: CustomActionButton(
                  text: _isLoading ? 'Sign Up...' : 'Sign Up',
                  onPressed: _isLoading ? null : sendOtp,
                ),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an Account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginView()),
                      );
                    },
                    child: const Text(
                      'Log In',
                      style: TextStyle(color: Color(0xFF064232)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
