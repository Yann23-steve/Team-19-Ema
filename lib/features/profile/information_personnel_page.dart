import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PersonalInformationPage extends StatefulWidget {
  const PersonalInformationPage({super.key});

  @override
  State<PersonalInformationPage> createState() => _PersonalInformationPageState();
}

class _PersonalInformationPageState extends State<PersonalInformationPage> {
  bool _isEditing = false;
  bool _saving = false;
  bool _initialized = false;

  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _streetCtrl = TextEditingController();
  final _streetNumberCtrl = TextEditingController();
  final _postalCodeCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();
  final _birthdayCtrl = TextEditingController();

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _streetCtrl.dispose();
    _streetNumberCtrl.dispose();
    _postalCodeCtrl.dispose();
    _countryCtrl.dispose();
    _birthdayCtrl.dispose();
    super.dispose();
  }

  void _fillControllers(Map<String, dynamic> data, String fallbackEmail) {
    String v(String key) => (data[key] ?? '').toString();

    _firstNameCtrl.text = v('firstName');
    _lastNameCtrl.text = v('lastName');

    final firestoreEmail = v('email').trim();
    _emailCtrl.text = firestoreEmail.isEmpty ? (fallbackEmail.trim()) : firestoreEmail;

    _streetCtrl.text = v('street');
    _streetNumberCtrl.text = v('streetNumber');
    _postalCodeCtrl.text = v('postalCode');
    _countryCtrl.text = v('country');
    _birthdayCtrl.text = v('birthday');
  }

  Future<void> _save(String uid) async {
    setState(() => _saving = true);

    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'firstName': _firstNameCtrl.text.trim(),
        'lastName': _lastNameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'street': _streetCtrl.text.trim(),
        'streetNumber': _streetNumberCtrl.text.trim(),
        'postalCode': _postalCodeCtrl.text.trim(),
        'country': _countryCtrl.text.trim(),
        'birthday': _birthdayCtrl.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      setState(() {
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Informations updated ✅")),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Save failed. Please try again.")),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _safe(String s) {
    final v = s.trim();
    return v.isEmpty ? "-" : v;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("No user logged in")),
      );
    }

    final titleColor = Theme.of(context).textTheme.titleLarge?.color;
    final bodyColor = Theme.of(context).textTheme.bodyLarge?.color;
    final subtitleColor = Theme.of(context).textTheme.bodySmall?.color;

    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
          builder: (context, snapshot) {
            // Tant que Firestore charge => loader (évite init vide)
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.data!.exists) {
              return const Center(child: Text("No profile found."));
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;

            // ✅ IMPORTANT : on initialise SEULEMENT quand on a les data Firestore
            // et on évite d’écraser pendant que l’utilisateur écrit.
            if (!_initialized && !_isEditing) {
              _fillControllers(data, user.email ?? "");
              _initialized = true;
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
                        SizedBox(
                          height: 70,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              children: [
                                const Text(
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
                                    color: titleColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.arrow_back, size: 18, color: subtitleColor),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Personal information",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: titleColor,
                            ),
                          ),
                        ),
                        InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: _saving
                              ? null
                              : () async {
                            if (_isEditing) {
                              await _save(user.uid);
                            } else {
                              setState(() => _isEditing = true);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: _isEditing ? const Color(0xFF4B6BFB) : Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF4B6BFB).withOpacity(_isEditing ? 0.0 : 0.25),
                              ),
                            ),
                            child: _saving
                                ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                                : Text(
                              _isEditing ? "Save" : "Edit",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: _isEditing ? Colors.white : const Color(0xFF4B6BFB),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Your account details from the registration form",
                      style: TextStyle(
                        fontSize: 16,
                        color: subtitleColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 20),

                    _infoCard(
                      context: context,
                      title: "Account",
                      icon: Icons.person_outline,
                      items: [
                        _fieldRow(
                          context: context,
                          label: "First Name",
                          controller: _firstNameCtrl,
                          enabled: _isEditing,
                        ),
                        _fieldRow(
                          context: context,
                          label: "Last Name",
                          controller: _lastNameCtrl,
                          enabled: _isEditing,
                        ),
                        _fieldRow(
                          context: context,
                          label: "Email",
                          controller: _emailCtrl,
                          enabled: _isEditing,
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    _infoCard(
                      context: context,
                      title: "Address",
                      icon: Icons.location_on_outlined,
                      items: [
                        _fieldRow(
                          context: context,
                          label: "Street",
                          controller: _streetCtrl,
                          enabled: _isEditing,
                        ),
                        _fieldRow(
                          context: context,
                          label: "Street Number",
                          controller: _streetNumberCtrl,
                          enabled: _isEditing,
                        ),
                        _fieldRow(
                          context: context,
                          label: "Postal Code",
                          controller: _postalCodeCtrl,
                          enabled: _isEditing,
                          keyboardType: TextInputType.number,
                        ),
                        _fieldRow(
                          context: context,
                          label: "Country",
                          controller: _countryCtrl,
                          enabled: _isEditing,
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    _infoCard(
                      context: context,
                      title: "Other",
                      icon: Icons.calendar_today_outlined,
                      items: [
                        _fieldRow(
                          context: context,
                          label: "Birthday",
                          controller: _birthdayCtrl,
                          enabled: _isEditing,
                        ),
                        _infoRow(
                          context,
                          "UID",
                          _safe((data['uid'] ?? user.uid).toString()),
                          bodyColor,
                          subtitleColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _infoCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Widget> items,
  }) {
    final titleColor = Theme.of(context).textTheme.bodyLarge?.color;
    final subtitleColor = Theme.of(context).textTheme.bodySmall?.color;

    return Container(
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
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF3FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.info_outline, color: Color(0xFF1D4ED8)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                  ),
                ),
              ),
              Icon(icon, color: subtitleColor),
            ],
          ),
          const SizedBox(height: 12),
          ...items,
        ],
      ),
    );
  }

  Widget _infoRow(
      BuildContext context,
      String label,
      String value,
      Color? valueColor,
      Color? labelColor,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: labelColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ si enabled=false => on affiche un Text au lieu d’un TextField
  Widget _fieldRow({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    required bool enabled,
    TextInputType? keyboardType,
  }) {
    final labelColor = Theme.of(context).textTheme.bodySmall?.color;
    final valueColor = Theme.of(context).textTheme.bodyLarge?.color;

    final shown = controller.text.trim().isEmpty ? "-" : controller.text.trim();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: labelColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 6,
            child: enabled
                ? TextField(
              controller: controller,
              enabled: enabled,
              keyboardType: keyboardType,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: valueColor,
              ),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: "-",
                hintStyle: TextStyle(color: labelColor),
              ),
            )
                : Text(
              shown,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
