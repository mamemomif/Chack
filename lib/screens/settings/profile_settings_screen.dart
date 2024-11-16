import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  _ProfileSettingsScreenState createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  DateTime? _selectedBirthDate;
  String? _profileImageUrl;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  File? _profileImageFile;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _nicknameController.text = data['nickname'] ?? '';
          _selectedBirthDate =
              data['birthDate'] != null ? DateTime.parse(data['birthDate']) : null;
          _profileImageUrl = data['profileImage'];
        });
      }
    }
  }

  Future<void> _updateProfileImage() async {
    if (_profileImageFile == null) return;
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final storageRef =
            _storage.ref().child('profile_images/${user.uid}.jpg');
        final uploadTask = await storageRef.putFile(_profileImageFile!);
        final imageUrl = await uploadTask.ref.getDownloadURL();

        // Firestore 업데이트
        await _firestore.collection('users').doc(user.uid).update({
          'profileImage': imageUrl,
        });

        setState(() {
          _profileImageUrl = imageUrl;
        });
      }
    } catch (e) {
      print('Error uploading profile image: $e');
    }
  }

  Future<void> _updateUserData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'nickname': _nicknameController.text,
          'birthDate': _selectedBirthDate?.toIso8601String(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('프로필 정보가 업데이트되었습니다.')),
        );
      }
    } catch (e) {
      print('Error updating user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('프로필 정보 업데이트 중 오류가 발생했습니다.')),
      );
    }
  }

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImageFile = File(pickedFile.path);
      });
      await _updateProfileImage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('프로필 설정')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickProfileImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _profileImageFile != null
                    ? FileImage(_profileImageFile!)
                    : _profileImageUrl != null
                        ? NetworkImage(_profileImageUrl!) as ImageProvider
                        : const AssetImage('assets/default_profile.png'),
                child: _profileImageFile == null && _profileImageUrl == null
                    ? const Icon(Icons.camera_alt, size: 30)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nicknameController,
              decoration: const InputDecoration(labelText: '닉네임'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedBirthDate != null
                        ? '생년월일: ${_selectedBirthDate!.toLocal()}'.split(' ')[0]
                        : '생년월일을 선택해주세요',
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _selectedBirthDate = pickedDate;
                      });
                    }
                  },
                  child: const Text('날짜 선택'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _updateUserData,
              child: const Text('저장'),
            ),
          ],
        ),
      ),
    );
  }
}
