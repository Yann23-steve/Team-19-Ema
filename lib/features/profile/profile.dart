import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

import '../../app/app_theme.dart';
import '../auth/landing_page.dart';
import 'information_personnel_page.dart';
import 'notification_page.dart';
import 'passwort_reset.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? user;

  final ImagePicker _picker = ImagePicker();

  final List<String> _cities = const [
    "Berlin",
    "Frankfurt",
    "Hamburg",
    "Munich",
    "Cologne",
    "Stuttgart",
    "Paris",
    "Lyon",
    "Zurich",
    "Vienna",
  ];

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
  }

  Future<void> _showPhotoPickerSheet() async {
    if (user == null) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text("Choose from gallery"),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickAndSaveToFirestore(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text("Take a photo"),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickAndSaveToFirestore(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text("Cancel"),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickAndSaveToFirestore(ImageSource source) async {
    if (user == null) return;

    try {
      final XFile? picked = await _picker.pickImage(source: source);
      if (picked == null) return;

      final bytes = await File(picked.path).readAsBytes();

      final decoded = img.decodeImage(bytes);
      if (decoded == null) {
        throw Exception("Image decode failed");
      }

      // resize pour respecter la limite Firestore (1MB/doc)
      final resized = img.copyResize(decoded, width: 256);

      // compress jpeg
      final jpgBytes = Uint8List.fromList(img.encodeJpg(resized, quality: 70));

      final base64Str = base64Encode(jpgBytes);

      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
        'photoBase64': base64Str,
        'photoUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile photo saved ✅")),
      );
    } on FirebaseException catch (e) {
      debugPrint("Firestore error: ${e.code} ${e.message}");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Firestore: ${e.code}")),
      );
    } catch (e) {
      debugPrint("Error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not save photo")),
      );
    }
  }

  Future<void> _openPreferredLocationDialog(String currentValue) async {
    if (user == null) return;

    String selected =
    currentValue.trim().isEmpty ? _cities.first : currentValue.trim();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Preferred location"),
          content: DropdownButtonFormField<String>(
            value: _cities.contains(selected) ? selected : _cities.first,
            items: _cities
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) {
              if (v != null) selected = v;
            },
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Choose a city",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user!.uid)
                      .update({'preferredLocation': selected});

                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Location saved ✅")),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Something went wrong")),
                    );
                  }
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("No user logged in")),
      );
    }

    return SafeArea(
      child: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          String fullName = "Your Name";
          String email = "your.email@example.com";
          String preferredLocation = "";

          String photoBase64 = "";

          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;

            final firstName = (data['firstName'] ?? '').toString();
            final lastName = (data['lastName'] ?? '').toString();

            fullName = "$firstName $lastName".trim();
            email = (data['email'] ?? user!.email ?? '').toString();
            preferredLocation = (data['preferredLocation'] ?? '').toString();

            photoBase64 = (data['photoBase64'] ?? '').toString();
          } else {
            email = user!.email ?? "your.email@example.com";
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===== Header JobSuche =====
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        height: 70,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: const [
                              Text(
                                'Job',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4B6BFB),
                                ),
                              ),
                              Text(
                                'Suche',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: const [
                      Text(
                        'Profile',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: const [
                      Text(
                        'Manage your account and preferences',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ===== Profile card =====
                  InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: _showPhotoPickerSheet,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF3FF),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: photoBase64.trim().isNotEmpty
                                  ? Image.memory(
                                base64Decode(photoBase64),
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.person,
                                  color: Color(0xFF1D4ED8),
                                  size: 30,
                                ),
                              )
                                  : const Icon(
                                Icons.person,
                                color: Color(0xFF1D4ED8),
                                size: 30,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  fullName.isEmpty ? "Your Name" : fullName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  email.isEmpty
                                      ? "your.email@example.com"
                                      : email,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Edit profile – coming soon"),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F6FA),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.edit,
                                size: 18,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ===== Quick stats =====
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF3FF),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.bookmark_border,
                                  color: Color(0xFF1D4ED8),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      "3",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      "Saved",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1FDF7),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.send_outlined,
                                  color: Color(0xFF059669),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      "1",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      "Applied",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F6FA),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.work_outline,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      "0",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      "Shifts",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w600,
                                      ),
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

                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: const [
                      Text(
                        "Settings",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // ===== Dark Mode card =====
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F6FA),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.dark_mode_outlined,
                            color: Theme.of(context).iconTheme.color,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Dark Mode",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Change app appearance",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ValueListenableBuilder<ThemeMode>(
                          valueListenable: appThemeMode,
                          builder: (context, mode, _) {
                            final isDark = mode == ThemeMode.dark;

                            return Switch(
                              value: isDark,
                              onChanged: (v) async {
                                await setDarkMode(v);
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  _settingsItem(
                    context: context,
                    icon: Icons.person_outline,
                    iconBg: const Color(0xFFEFF3FF),
                    iconColor: const Color(0xFF1D4ED8),
                    title: "Personal information",
                    subtitle: "Name, email, phone",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PersonalInformationPage(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 14),

                  _settingsItem(
                    context: context,
                    icon: Icons.location_on_outlined,
                    iconBg: const Color(0xFFEFF3FF),
                    iconColor: const Color(0xFF1D4ED8),
                    title: "Preferred location",
                    subtitle: preferredLocation.trim().isEmpty
                        ? "City & remote preferences"
                        : preferredLocation,
                    onTap: () {
                      _openPreferredLocationDialog(preferredLocation);
                    },
                  ),

                  const SizedBox(height: 14),

                  _settingsItem(
                    context: context,
                    icon: Icons.notifications_none,
                    iconBg: const Color(0xFFF1FDF7),
                    iconColor: const Color(0xFF059669),
                    title: "Notifications",
                    subtitle: "Job alerts & reminders",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationsPage(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 14),

                  _settingsItem(
                    context: context,
                    icon: Icons.lock_outline,
                    iconBg: const Color(0xFFEFF3FF),
                    iconColor: const Color(0xFF1D4ED8),
                    title: "Change password",
                    subtitle: "Update your password",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PasswortResetPage(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 14),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6FA),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF1D4ED8).withOpacity(0.20),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.info_outline, color: Color(0xFF1D4ED8)),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "JobSuche v1.0.0",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LandingPage()),
                            (route) => false,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF1F2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFEF4444).withOpacity(0.25),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.logout, color: Color(0xFFEF4444)),
                          SizedBox(width: 12),
                          Text(
                            "Logout",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFEF4444),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _settingsItem({
    required BuildContext context,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap ??
              () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("$title – coming soon"),
                duration: const Duration(seconds: 2),
              ),
            );
          },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
