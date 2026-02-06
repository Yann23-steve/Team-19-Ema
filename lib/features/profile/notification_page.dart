import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final _messaging = FirebaseMessaging.instance;

  bool _loading = true;

  bool _notificationsEnabled = false; // master switch
  bool _jobAlertsEnabled = true;
  bool _remindersEnabled = true;

  String? _token;

  User? get _user => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadFromFirestore();
  }

  Future<void> _loadFromFirestore() async {
    final user = _user;
    if (user == null) {
      setState(() => _loading = false);
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        _notificationsEnabled = (data['notificationsEnabled'] ?? false) as bool;
        _jobAlertsEnabled = (data['jobAlertsEnabled'] ?? true) as bool;
        _remindersEnabled = (data['remindersEnabled'] ?? true) as bool;
        _token = data['fcmToken'] as String?;
      }
    } catch (_) {
      // ignore: UI will still work
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveToFirestore() async {
    final user = _user;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'notificationsEnabled': _notificationsEnabled,
      'jobAlertsEnabled': _jobAlertsEnabled,
      'remindersEnabled': _remindersEnabled,
      'fcmToken': _token,
      'tokenUpdatedAt': FieldValue.serverTimestamp(),
      'platform': Platform.isAndroid ? 'android' : 'ios',
    }, SetOptions(merge: true));
  }

  Future<bool> _requestPermissionIfNeeded() async {
    // iOS always needs permission, Android 13+ also.
    final settings = await _messaging.getNotificationSettings();

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      return true;
    }

    final res = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    return res.authorizationStatus == AuthorizationStatus.authorized ||
        res.authorizationStatus == AuthorizationStatus.provisional;
  }

  Future<void> _enableNotifications() async {
    setState(() => _loading = true);
    try {
      final granted = await _requestPermissionIfNeeded();

      if (!granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Permission denied. Enable it in settings.")),
          );
        }
        setState(() {
          _notificationsEnabled = false;
          _loading = false;
        });
        await _saveToFirestore();
        return;
      }

      final token = await _messaging.getToken();
      _token = token;

      // écoute les changements de token (important)
      _messaging.onTokenRefresh.listen((t) async {
        _token = t;
        await _saveToFirestore();
      });

      setState(() => _loading = false);
      await _saveToFirestore();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Notifications enabled ✅")),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Something went wrong")),
        );
      }
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _disableNotifications() async {
    setState(() => _loading = true);
    try {
      // On ne peut pas “retirer” la permission depuis l’app,
      // mais on désactive côté app + backend (on retire token)
      _token = null;

      setState(() => _loading = false);
      await _saveToFirestore();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Notifications disabled")),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Something went wrong")),
        );
      }
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _tile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
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
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;

    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body: SafeArea(
        child: user == null
            ? const Center(child: Text("No user logged in"))
            : _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Manage notifications",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              const Text(
                "Choose what you want to receive.",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 18),

              // Master switch
              _tile(
                icon: Icons.notifications_active_outlined,
                iconBg: const Color(0xFFF1FDF7),
                iconColor: const Color(0xFF059669),
                title: "Enable notifications",
                subtitle: _notificationsEnabled
                    ? "You will receive push notifications"
                    : "Disabled (no push notifications)",
                trailing: Switch(
                  value: _notificationsEnabled,
                  onChanged: (v) async {
                    setState(() => _notificationsEnabled = v);

                    if (v) {
                      await _enableNotifications();
                    } else {
                      await _disableNotifications();
                    }
                  },
                ),
              ),

              const SizedBox(height: 14),

              // Job alerts
              _tile(
                icon: Icons.work_outline,
                iconBg: const Color(0xFFEFF3FF),
                iconColor: const Color(0xFF1D4ED8),
                title: "Job alerts",
                subtitle: "New jobs matching your preferences",
                trailing: Switch(
                  value: _jobAlertsEnabled,
                  onChanged: _notificationsEnabled
                      ? (v) async {
                    setState(() => _jobAlertsEnabled = v);
                    await _saveToFirestore();
                  }
                      : null,
                ),
              ),

              const SizedBox(height: 14),

              // Reminders
              _tile(
                icon: Icons.alarm_outlined,
                iconBg: const Color(0xFFEFF3FF),
                iconColor: const Color(0xFF1D4ED8),
                title: "Reminders",
                subtitle: "Don’t forget to apply / follow up",
                trailing: Switch(
                  value: _remindersEnabled,
                  onChanged: _notificationsEnabled
                      ? (v) async {
                    setState(() => _remindersEnabled = v);
                    await _saveToFirestore();
                  }
                      : null,
                ),
              ),

              const SizedBox(height: 18),

              // Token display (debug / admin)
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, color: Color(0xFF1D4ED8)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _notificationsEnabled
                            ? "FCM token saved ✅"
                            : "FCM token not stored (notifications disabled)",
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
