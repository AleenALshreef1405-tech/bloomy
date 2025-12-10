import 'package:bloomy/widgets/MainNavigation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class VerifyOtp extends StatefulWidget {
  final String email;
  final String name;

  const VerifyOtp({Key? key, required this.email, required this.name}) : super(key: key);

  @override
  State<VerifyOtp> createState() => _VerifyOtpState();
}

class _VerifyOtpState extends State<VerifyOtp> {
  String otpCode = "";
  bool isLoading = false;
  bool _showSuccessPopup = false;

  Future<void> verifyOtp() async {
    setState(() => isLoading = true);

    try {
      final res = await Supabase.instance.client.auth.verifyOTP(
        email: widget.email,
        token: otpCode,
        type: OtpType.email,
      );

      final user = res.user;
      if (user != null) {
        await Supabase.instance.client.from('users').upsert({
          'id': user.id,
          'name': widget.name,
          'email': widget.email,
        });
      }

      setState(() => _showSuccessPopup = true);

      Future.delayed(const Duration(seconds: 10), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigation()),
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification failed: ${e.toString()}')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = otpCode.length == 6;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F2),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BackButton(),
                  const SizedBox(height: 24),
                  const Text(
                    'OTP Verification',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF064232),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter the verification code sent to ${widget.email}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color.fromARGB(137, 70, 69, 69),
                    ),
                  ),
                  const SizedBox(height: 32),

                  PinCodeTextField(
                    appContext: context,
                    length: 6,
                    keyboardType: TextInputType.number,
                    animationType: AnimationType.fade,
                    enableActiveFill: true,
                    onChanged: (value) => setState(() => otpCode = value),
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(8),
                      fieldHeight: 55,
                      fieldWidth: 45,
                      inactiveColor: const Color(0xFFC4C4C4),
                      activeColor: const Color(0xFF064232),
                      selectedColor: const Color(0xFF064232),
                      inactiveFillColor: const Color(0xFFECECEC),
                      selectedFillColor: const Color(0xFFFFF5F2),
                      activeFillColor: const Color(0xFFFFF5F2),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: isCompleted ? verifyOtp : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isCompleted
                                  ? const Color(0xFF064232)
                                  : Colors.grey.shade300,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 100,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40),
                              ),
                            ),
                            child: const Text(
                              'Verify',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                  ),
                ],
              ),
            ),
            if (_showSuccessPopup)
              Container(
                color: Colors.black.withOpacity(0.4),
                child: Center(
                  child: Container(
                    height: 300,
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF5F2),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/success.png',
                          height: 100,
                          width: 100,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Email confirmed!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF064232),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Your email has been verified.\nRedirecting to Home...',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 10),
                        const CircularProgressIndicator(
                          color: Color(0xFF064232),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
