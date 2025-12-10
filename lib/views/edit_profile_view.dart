import 'dart:io';
import 'package:bloomy/widgets/CustomActionButton.dart';
import 'package:bloomy/widgets/CustomTextField.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final supabase = Supabase.instance.client;

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  File? _profileImageFile;
  final Color primaryColor = const Color(0xFF064232);
  final Color backgroundColor = const Color(0xFFFFF5F2);

  bool loading = false;

  Future<void> _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedImage != null) {
      setState(() {
        _profileImageFile = File(pickedImage.path);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final response =
        await supabase.from('users').select().eq('id', user.id).maybeSingle();

    if (response != null) {
      setState(() {
        fullNameController.text = response['name'] ?? '';
        emailController.text = response['email'] ?? user.email ?? '';
      });
    }
  }

  Future<void> _handleUpdate() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User not logged in.')));
      return;
    }
    setState(() => loading = true);

    try {
      await supabase
          .from('users')
          .update({
            'name': fullNameController.text,
            'email': emailController.text,
          })
          .eq('id', user.id);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: const BackButton(color: Color(0xFF064232)),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Color(0xFF064232),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 48,
                backgroundColor: Color(0xFF064232),
                backgroundImage:
                    _profileImageFile != null
                        ? FileImage(_profileImageFile!)
                        : null,
                       child:
                    _profileImageFile == null
                        ? const Icon(
                          Icons.person,
                          size: 50,
                          color:  Color(0xFFFFF5F2),
                        )
                        : null,
              ),
            ),
            const SizedBox(height: 24),
            CustomTextField(hint: 'Full Name', controller: fullNameController),
            const SizedBox(height: 24),
            CustomTextField(
              hint: 'Email',
              icon: Icons.email_outlined,
              controller: emailController,
            ),
            const SizedBox(height: 30),
            CustomActionButton(text: 'Update', onPressed: _handleUpdate),
          ],
        ),
      ),
    );
  }
}
