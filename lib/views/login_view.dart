import 'package:bloomy/views/create_acc_view.dart';
import 'package:bloomy/widgets/CustomActionButton.dart';
import 'package:bloomy/widgets/MainNavigation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isOtpSent = false;
  bool _isLoading = false;

  final supabase = Supabase.instance.client;

  Future<void> _sendOtp() async {
    setState(() => _isLoading = true);

    try {
      await supabase.auth.signInWithOtp(
        email: _emailController.text.trim(),
      );

      setState(() => _isOtpSent = true);

    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending OTP: $error')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyOtp() async {
    setState(() => _isLoading = true);

    try {
      final response = await supabase.auth.verifyOTP(
        email: _emailController.text.trim(),
        token: _otpController.text.trim(),
        type: OtpType.email,
      );

      if (response.session != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigation()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid code, please try again.')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification error: $error')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget buildUnderlineTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
  }) {
    return Column(
      children: [
        TextFormField(
          controller: controller,
          style: const TextStyle(color: Colors.black87),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.black54),
            prefixIcon: Icon(icon, color: Color(0xFF064232)),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF064232), width: 2),
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black38, width: 1.2),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F2),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                'assets/images/login.png',
                height: 180,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _isOtpSent ? 'Enter OTP' : 'Log In',
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Color(0xFF064232),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _isOtpSent
                  ? 'Enter the code sent to your email'
                  : 'Please sign in to continue',
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 30),

            if (!_isOtpSent)
              buildUnderlineTextField(
                controller: _emailController,
                hintText: 'Email',
                icon: Icons.email,
              ),

            if (_isOtpSent)
              buildUnderlineTextField(
                controller: _otpController,
                hintText: 'Enter OTP Code',
                icon: Icons.lock_open,
              ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: CustomActionButton(
                text: _isOtpSent ? 'Verify Code' : 'Log In',
                onPressed: _isLoading
                    ? null
                    : _isOtpSent
                        ? _verifyOtp
                        : _sendOtp,
              ),
            ),
            const SizedBox(height: 16),
            if (!_isOtpSent)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an Account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CreateAccView()),
                      );
                    },
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(color: Color(0xFF064232)),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
