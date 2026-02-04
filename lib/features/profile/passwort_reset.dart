import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PasswortResetPage extends StatefulWidget {
  const PasswortResetPage({super.key});

  @override
  State<PasswortResetPage> createState() => _PasswortResetPageState();
}

class _PasswortResetPageState extends State<PasswortResetPage> {
  final _formKey = GlobalKey<FormState>();

  final _currentPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  bool _loading = false;
  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;

  @override
  void dispose() {
    _currentPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  String? _validatePassword(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return "Password required";
    if (value.length < 6) return "Min. 6 characters";
    return null;
  }

  Future<void> _changePassword() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No user logged in")),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final currentPw = _currentPasswordCtrl.text.trim();
    final newPw = _newPasswordCtrl.text.trim();
    final confirmPw = _confirmPasswordCtrl.text.trim();

    if (newPw != confirmPw) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      // 1) Re-authentication (important pour updatePassword)
      final email = user.email;
      if (email == null || email.isEmpty) {
        throw FirebaseAuthException(
          code: 'no-email',
          message: 'This account has no email.',
        );
      }

      final credential =
      EmailAuthProvider.credential(email: email, password: currentPw);

      await user.reauthenticateWithCredential(credential);

      // 2) Update password in Firebase Auth
      await user.updatePassword(newPw);

      // 3) Optionnel: refresh token / user
      await user.reload();

      // 4) Save in Firestore (NE PAS enregistrer le mot de passe en clair!)
      // -> On enregistre uniquement un flag / date de changement
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'passwordUpdatedAt': FieldValue.serverTimestamp(),
        'hasCustomPassword': true,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password updated ✅")),
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String msg = "Something went wrong";

      if (e.code == 'wrong-password') msg = "Current password is incorrect";
      if (e.code == 'user-mismatch') msg = "User mismatch";
      if (e.code == 'user-not-found') msg = "User not found";
      if (e.code == 'invalid-credential') msg = "Invalid credentials";
      if (e.code == 'requires-recent-login') {
        msg = "Please login again and retry";
      }
      if (e.code == 'weak-password') msg = "Password too weak (min 6 chars)";
      if (e.code == 'no-email') msg = e.message ?? msg;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Something went wrong")),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Change password"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Update your password",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                const Text(
                  "For security, please enter your current password first.",
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),

                // Current password
                TextFormField(
                  controller: _currentPasswordCtrl,
                  obscureText: !_showCurrent,
                  validator: (v) =>
                  (v == null || v.trim().isEmpty) ? "Required" : null,
                  decoration: InputDecoration(
                    labelText: "Current password",
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _showCurrent = !_showCurrent),
                      icon: Icon(_showCurrent
                          ? Icons.visibility_off
                          : Icons.visibility),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // New password
                TextFormField(
                  controller: _newPasswordCtrl,
                  obscureText: !_showNew,
                  validator: _validatePassword,
                  decoration: InputDecoration(
                    labelText: "New password",
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _showNew = !_showNew),
                      icon:
                      Icon(_showNew ? Icons.visibility_off : Icons.visibility),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Confirm
                TextFormField(
                  controller: _confirmPasswordCtrl,
                  obscureText: !_showConfirm,
                  validator: _validatePassword,
                  decoration: InputDecoration(
                    labelText: "Confirm new password",
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: () =>
                          setState(() => _showConfirm = !_showConfirm),
                      icon: Icon(_showConfirm
                          ? Icons.visibility_off
                          : Icons.visibility),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _changePassword,
                    child: _loading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Text("Save"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
